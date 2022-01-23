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
        metadataQuery.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, "*.*")
        metadataQuery.sortDescriptors = [NSSortDescriptor(key: NSMetadataItemFSNameKey, ascending: true)]
        metadataQuery.start()
        
    }

    deinit {
        guard metadataQuery.isStarted else { return }
        metadataQuery.stop()
    }

    public func urls(withPrefix filePrefix: String) -> [URL] {
        do {
            let allURLs = try FileManager.default.contentsOfDirectory(at: storageURL, includingPropertiesForKeys: [.nameKey], options: [.skipsHiddenFiles])
            return allURLs.filter { $0.lastPathComponent.hasPrefix(filePrefix) }
        } catch {
            Logger.default.error("Error enumerating files in \(storageURL): \(error)")
            return []
        }
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

    public func saveFile(at url: URL) {
        let resultURL = storageURL.appendingPathComponent(url.lastPathComponent)
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
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            do {
                try data.write(to: tempURL)
                self.saveFile(at: tempURL)
            } catch {
                Logger.default.error("Error saving data to \(tempURL): \(error)")
            }
        }
    }

    public func loadFile(at url: URL) async throws -> Data {
        let throughiCloud = requiresCoordination
        return try await withCheckedThrowingContinuation { contination in
            if throughiCloud {
                DispatchQueue.global(qos: .userInitiated).async {
                    let coordinator = NSFileCoordinator()
                    var error: NSError?
                    coordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: &error) { coordinatedURL in
                        contination.resume(with: Result(catching: { try Data(contentsOf: coordinatedURL) }))
                    }
                    if let error = error {
                        contination.resume(throwing: error)
                    }
                }
            } else {
                DispatchQueue.global(qos: .userInitiated).async {
                    contination.resume(with: Result(catching: { try Data(contentsOf: url) }))
                }
            }
        }
    }
}

extension FileStorageManager {

    private func urls(from nsMetataItems: [NSMetadataItem]) -> [URL] {
        let validItems = nsMetataItems.filter { item in
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
