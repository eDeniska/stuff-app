//
//  FileStorageManager.swift
//  
//
//  Created by Danis Tazetdinov on 16.01.2022.
//

import Foundation
import Logger

public class FileStorageManager {

    private var storageURL: URL
    private var requiresCoordination = false

    public static let shared = FileStorageManager()

    private init() {
        storageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if FileManager.default.ubiquityIdentityToken != nil {
            Logger.default.log(.info, "iCloud integration is enabled, querying URL...")
            // blocking operation, so using DispatchQueue...
            DispatchQueue.global(qos: .userInitiated).async {
                if let url = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
                    DispatchQueue.main.async {
                        Logger.default.log(.info, "iCloud storage URL: \(url)")
                        self.storageURL = url
                        self.requiresCoordination = true
                    }
                } else {
                    Logger.default.log(.error, "Could not get iCloud storage URL!")
                }
            }
        }
    }

    public func urls(withPrefix filePrefix: String) -> [URL] {
        do {
            let allURLs = try FileManager.default.contentsOfDirectory(at: storageURL, includingPropertiesForKeys: [.nameKey], options: [.skipsHiddenFiles])
            return allURLs.filter { $0.lastPathComponent.hasPrefix(filePrefix) }
        } catch {
            Logger.default.log(.error, "Error enumerating files in \(storageURL): \(error)")
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
            Logger.default.log(.error, "failed to remove items with prefix \(filePrefix): \(error)")
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
            Logger.default.log(.error, "Error saving file to \(resultURL): \(error)")
        }
    }

    public func save(data: Data, with name: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            do {
                try data.write(to: tempURL)
                self.saveFile(at: tempURL)
            } catch {
                Logger.default.log(.error, "Error saving data to \(tempURL): \(error)")
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
