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

    
    private let folderPrefix: String = {
#if DEBUG
        return "debug"
#else
        return ""
#endif
    }()
    
    private lazy var storageURL: URL = {
        Logger.default.info("iCloud integration is \(requiresCoordination), querying URL...")
        if requiresCoordination, var url = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
            if !folderPrefix.isEmpty {
                url.appendPathComponent(folderPrefix)
                do {
                    if !FileManager.default.fileExists(atPath: url.path) {
                        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                    }
                } catch {
                    Logger.default.error("could not create directory for files: \(error)")
                }
            }
            Logger.default.info("iCloud storage URL: \(url)")
            return url
        } else {
            Logger.default.error("Could not get iCloud storage URL or coordination is disabled!")
            requiresCoordination = false
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    }()

    private var requiresCoordination: Bool

    public static let shared = FileStorageManager()

    @Published public var items: [URL] = []

    private let metadataQuery: NSMetadataQuery
    private var querySubscriber: AnyCancellable?

    // file failes to run on Apple Watch on NSMetadataQuery

    private init() {
        requiresCoordination = FileManager.default.ubiquityIdentityToken != nil

        metadataQuery = NSMetadataQuery()

        let names: [NSNotification.Name] = [.NSMetadataQueryDidFinishGathering, .NSMetadataQueryDidUpdate]
        let publishers = names.map { NotificationCenter.default.publisher(for: $0) }
        querySubscriber = Publishers.MergeMany(publishers).receive(on: DispatchQueue.main).sink { [weak self] notification in
            guard let self = self, notification.object as? NSMetadataQuery === self.metadataQuery else { return }
            self.items = self.readMetadataResults()
            Logger.default.info("got items: \(self.items)")
        }

        // Set up a metadata query to gather document changes in the iCloud container.
        metadataQuery.notificationBatchingInterval = 1
        metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope, NSMetadataQueryUbiquitousDocumentsScope]
        metadataQuery.predicate = .like(keyPath: NSMetadataItemFSNameKey, text: "*")
        metadataQuery.sortDescriptors = [NSSortDescriptor(key: NSMetadataItemFSNameKey, ascending: true)]
        metadataQuery.start()
    }

    deinit {
        guard metadataQuery.isStarted else { return }
        metadataQuery.stop()
    }

    public func initialize() {
    }

    public func urls(withPrefix filePrefix: String) -> [URL] {
        items.filter { $0.lastPathComponent.hasPrefix(filePrefix) }.sorted { $0.absoluteString < $1.absoluteString }
    }

    public func removeItems(withPrefix filePrefix: String) {
        let urls = urls(withPrefix: filePrefix)
        urls.forEach(removeItem)
    }

    public func removeItem(at url: URL) {
        do {
            if requiresCoordination {
                let coordinator = NSFileCoordinator()
                var error: NSError?
                var deleteError: Error?
                coordinator.coordinate(writingItemAt: url, options: .forDeleting, error: &error) { coordinatedURL in
                    do {
                        try FileManager.default.removeItem(at: coordinatedURL)
                    } catch {
                        deleteError = error
                    }
                }
                if let error = error {
                    throw error
                }
                if let error = deleteError {
                    throw error
                }
            } else {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            Logger.default.error("failed to remove items at \(url): \(error)")
        }
    }

    public func rename(at url: URL, to fileName: String) {
        let destinationURL = storageURL.appendingPathComponent(fileName)
        do {
            if requiresCoordination {
                let coordinator = NSFileCoordinator()
                var error: NSError?
                var moveError: Error?
                coordinator.coordinate(writingItemAt: url, options: .forMoving, error: &error) { coordinatedURL in
                    do {
                        try FileManager.default.moveItem(at: coordinatedURL, to: destinationURL)
                    } catch {
                        moveError = error
                    }
                }
                if let error = error {
                    throw error
                }
                if let error = moveError {
                    throw error
                }
            } else {
                try FileManager.default.moveItem(at: url, to: destinationURL)
            }
        } catch {
            Logger.default.error("failed to move items from \(url) to \(destinationURL): \(error)")
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

    public func copyFile(at url: URL, to destinationURL: URL) throws {
        if requiresCoordination {
            let coordinator = NSFileCoordinator()
            var coordinatorError: NSError?
            var thrownError: Error?
            coordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: &coordinatorError) { coordinatedURL in
                do {
                    try FileManager.default.copyItem(at: coordinatedURL, to: destinationURL)
                } catch {
                    thrownError = error

                }
            }
            if let error = coordinatorError {
                throw error
            }
            if let error = thrownError {
                throw error
            }
        } else {
            try FileManager.default.copyItem(at: url, to: destinationURL)
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
