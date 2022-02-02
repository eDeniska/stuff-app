//
//  FileStorageManager.swift
//  
//
//  Created by Danis Tazetdinov on 16.01.2022.
//

import Foundation
import Logger
import Combine

public class FileStorageManager: ObservableObject {

    private var storageURL: URL
    private var requiresCoordination = false

    public static let shared = FileStorageManager()

    @Published public var items: [URL] = []

    private let metadataQuery = NSMetadataQuery()
    private var querySubscriber: AnyCancellable?

    private init() {
        storageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if FileManager.default.ubiquityIdentityToken != nil {
            Logger.default.info("iCloud integration is enabled, querying URL...")
            // blocking operation, so using DispatchQueue...
            DispatchQueue.global(qos: .userInitiated).async {
                if let url = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
                    DispatchQueue.main.async {
                        Logger.default.info("iCloud storage URL: \(url)")
                        self.storageURL = url
                        self.requiresCoordination = true
                    }
                } else {
                    Logger.default.error("Could not get iCloud storage URL!")
                }
            }
        }


        let names: [NSNotification.Name] = [.NSMetadataQueryDidFinishGathering, .NSMetadataQueryDidUpdate]
        let publishers = names.map { NotificationCenter.default.publisher(for: $0) }
        querySubscriber = Publishers.MergeMany(publishers).receive(on: DispatchQueue.main).sink { [weak self] notification in
            guard let self = self, notification.object as? NSMetadataQuery === self.metadataQuery else { return }
            self.items = self.readMetadataResults()
        }

        // Set up a metadata query to gather document changes in the iCloud container.
        //
        metadataQuery.notificationBatchingInterval = 1
        metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope, NSMetadataQueryUbiquitousDocumentsScope]
        metadataQuery.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, "*")
        metadataQuery.sortDescriptors = [NSSortDescriptor(key: NSMetadataItemFSNameKey, ascending: true)]
        metadataQuery.start()
        
    }

    deinit {
        guard metadataQuery.isStarted else { return }
        metadataQuery.stop()
    }

    public func urls(withPrefix filePrefix: String) -> [URL] {
        items.filter { $0.lastPathComponent.hasPrefix(filePrefix) }.sorted { $0.absoluteString < $1.absoluteString }
    }

    public func removeItems(withPrefix filePrefix: String) {
        let urls = urls(withPrefix: filePrefix)
        do {
            try urls.forEach {
                try FileManager.default.removeItem(at: $0)
            }
        } catch {
            Logger.default.error("failed to remove items with prefix \(filePrefix): \(error)")
        }
    }

    public func removeItem(at url: URL) {
        do {
                try FileManager.default.removeItem(at: url)
        } catch {
            Logger.default.error("failed to remove items at \(url): \(error)")
        }
    }

    public func rename(at url: URL, to fileName: String) {
        do {
            let destinationURL = storageURL.appendingPathComponent(fileName)
            try FileManager.default.moveItem(at: url, to: destinationURL)
        } catch {
            Logger.default.error("failed to remove items at \(url): \(error)")
        }
    }

    public func saveFile(at url: URL, name: String? = nil) {
        let resultURL = storageURL.appendingPathComponent(name ?? url.lastPathComponent)
        do {
            if requiresCoordination {
                try FileManager.default.setUbiquitous(true, itemAt: url, destinationURL: resultURL)
            } else {
                try FileManager.default.moveItem(at: url, to: resultURL)
            }
        } catch {
            Logger.default.error("Error saving file to \(resultURL): \(error)")
        }
    }

    public func save(data: Data, with name: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            do {
                try data.write(to: tempURL)
                self.saveFile(at: tempURL, name: name)
            } catch {
                Logger.default.error("Error saving data to \(tempURL): \(error)")
            }
        }
    }

    public func loadFile(at url: URL) async throws -> Data {
        let throughiCloud = requiresCoordination
        return try await withCheckedThrowingContinuation { continuation in
            if throughiCloud {
                DispatchQueue.global(qos: .userInitiated).async {
                    let coordinator = NSFileCoordinator()
                    var error: NSError?
                    coordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: &error) { coordinatedURL in
                        continuation.resume(with: Result(catching: { try Data(contentsOf: coordinatedURL) }))
                    }
                    if let error = error {
                        continuation.resume(throwing: error)
                    }
                }
            } else {
                DispatchQueue.global(qos: .userInitiated).async {
                    continuation.resume(with: Result(catching: { try Data(contentsOf: url) }))
                }
            }
        }
    }

    // TODO: clear cache locally, clear cache via iCloud

    public func loadCachedFile(with name: String) async throws -> Data? {
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(name) else {
            return nil
        }
        return try await withUnsafeThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(with: Result(catching: { try Data(contentsOf: url) }))
            }
        }
    }

    public func cache(data: Data, with name: String) async throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        guard let resultURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(name) else {
            // TODO: should throw here
            return
        }
        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try data.write(to: tempURL)
                    try FileManager.default.moveItem(at: tempURL, to: resultURL)
                    continuation.resume()
                } catch {
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }

    public func cachedContents(for identifier: String, modifyForCache: ((Data) async -> (Data))?) async -> Data? {
        guard let url = urls(withPrefix: identifier).first else {
            return nil
        }
        do {
            if let data = try? await loadCachedFile(with: url.lastPathComponent) {
                Logger.default.info("cache - got cached data")
                return data
            }
            Logger.default.info("cache - no cached data")
            var data = try await loadFile(at: url)
            Logger.default.info("cache - loaded regular file")
            if let modifyForCache = modifyForCache {
                Logger.default.info("cache - ready to modify")
                data = await modifyForCache(data)
            }
            Logger.default.info("cache - ready to save")
            try await cache(data: data, with: url.lastPathComponent)
            Logger.default.info("cache - saved")
            return data
        } catch {
            Logger.default.error("Error loading cached icon for \(identifier): \(error)")
            return nil
        }
    }

}

extension FileStorageManager {

    private func urls(from metadataItems: [NSMetadataItem]) -> [URL] {
        let validItems = metadataItems.filter { item in
            guard let _ = item.value(forAttribute: NSMetadataItemURLKey) as? URL,
                  item.value(forAttribute: NSMetadataItemFSNameKey) != nil else { return false }

            return true
        }

        return validItems.compactMap { $0.value(forAttribute: NSMetadataItemURLKey) as? URL }
    }

    private func readMetadataResults() -> [URL] {
        var result = [URL]()
        metadataQuery.disableUpdates()
        if let metadatItems = metadataQuery.results as? [NSMetadataItem] {
            result = urls(from: metadatItems)
        }
        metadataQuery.enableUpdates()
        return result
    }
}
