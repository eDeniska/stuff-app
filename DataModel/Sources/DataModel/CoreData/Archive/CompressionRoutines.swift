//
//  CompressionRoutines.swift
//  
//
//  Created by Danis Tazetdinov on 18.02.2022.
//

import Foundation
import AppleArchive
import System
import Logger

public struct CompressionRoutines {

    public enum Errors: LocalizedError {
        case couldNotOpenArchive
        case incorrectPath
        case streamOperationFailed

        public var errorDescription: String? {
            switch self {
            case .couldNotOpenArchive:
                return "Could not open archive file."

            case .incorrectPath:
                return "Incorrect path for archive data."

            case .streamOperationFailed:
                return "Data processing failed due to internal error."
            }
        }
    }

    public static func compress(source: URL, to url: URL) throws {
        guard let archiveFilePath = FilePath(url), let sourceFilePath = FilePath(source) else {
            throw Errors.incorrectPath
        }

        guard let writeFileStream = ArchiveByteStream.fileStream(path: archiveFilePath,
                                                                 mode: .writeOnly,
                                                                 options: [ .create ],
                                                                 permissions: [ .groupRead, .otherRead, .ownerRead, .ownerWrite ]) else {
            throw Errors.streamOperationFailed
        }
        defer {
            try? writeFileStream.close()
        }

        guard let compressStream = ArchiveByteStream.compressionStream(using: .lzfse,
                                                                       writingTo: writeFileStream) else {
            throw Errors.streamOperationFailed
        }
        defer {
            try? compressStream.close()
        }

        guard let encodeStream = ArchiveStream.encodeStream(writingTo: compressStream) else {
            throw Errors.streamOperationFailed
        }
        defer {
            try? encodeStream.close()
        }

        try encodeStream.writeDirectoryContents(archiveFrom: sourceFilePath, keySet: .defaultForArchive)
    }

    public static func decompress(source: URL, to url: URL) throws {
        let coordinator = NSFileCoordinator()
        var error: NSError?
        var innerError: Error?
        coordinator.coordinate(readingItemAt: source, options: .withoutChanges, error: &error) { coordinatedURL in

            guard coordinatedURL.startAccessingSecurityScopedResource() else {
                innerError = Errors.couldNotOpenArchive
                return

            }
            defer {
                coordinatedURL.stopAccessingSecurityScopedResource()
            }


            guard let decompressFilePath = FilePath(url), let sourceFilePath = FilePath(coordinatedURL) else {
                innerError = Errors.incorrectPath
                return
            }

            guard let readFileStream = ArchiveByteStream.fileStream(path: sourceFilePath,
                                                                    mode: .readOnly,
                                                                    options: [ ],
                                                                    permissions: [ .groupRead, .otherRead, .ownerRead, .ownerWrite ]) else {
                innerError = Errors.streamOperationFailed
                return
            }
            defer {
                try? readFileStream.close()
            }

            guard let decompressStream = ArchiveByteStream.decompressionStream(readingFrom: readFileStream) else {
                innerError = Errors.streamOperationFailed
                return
            }

            defer {
                try? decompressStream.close()
            }

            guard let decodeStream = ArchiveStream.decodeStream(readingFrom: decompressStream) else {
                innerError = Errors.streamOperationFailed
                return
            }

            defer {
                try? decodeStream.close()
            }

            do {
                if !FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                }
                
                guard let extractStream = ArchiveStream.extractStream(extractingTo: decompressFilePath,
                                                                      flags: [ .ignoreOperationNotPermitted ]) else {
                    innerError = Errors.streamOperationFailed
                    return
                }
                defer {
                    try? extractStream.close()
                }
                
                let totalBytes = try ArchiveStream.process(readingFrom: decodeStream, writingTo: extractStream)
                Logger.default.debug("processed \(totalBytes) bytes.")
            } catch {
                innerError = error
            }
        }
        if let error = error {
            throw error
        }
        if let innerError = innerError {
            throw innerError
        }
    }
}
