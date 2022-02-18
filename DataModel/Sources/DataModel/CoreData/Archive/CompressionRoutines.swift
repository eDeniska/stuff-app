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
        case incorrectPath
        case streamOperationFailed

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
        guard let decompressFilePath = FilePath(url), let sourceFilePath = FilePath(source) else {
            throw Errors.incorrectPath
        }

        guard let readFileStream = ArchiveByteStream.fileStream(path: sourceFilePath,
                                                                mode: .readOnly,
                                                                options: [ ],
                                                                permissions: [ .groupRead, .otherRead, .ownerRead, .ownerWrite ]) else {
            throw Errors.streamOperationFailed
        }
        defer {
            try? readFileStream.close()
        }

        guard let decompressStream = ArchiveByteStream.decompressionStream(readingFrom: readFileStream) else {
            throw Errors.streamOperationFailed
        }

        defer {
            try? decompressStream.close()
        }

        guard let decodeStream = ArchiveStream.decodeStream(readingFrom: decompressStream) else {
            throw Errors.streamOperationFailed
        }

        defer {
            try? decodeStream.close()
        }

        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }

        guard let extractStream = ArchiveStream.extractStream(extractingTo: decompressFilePath,
                                                              flags: [ .ignoreOperationNotPermitted ]) else {
            throw Errors.streamOperationFailed
        }
        defer {
            try? extractStream.close()
        }

        let totalBytes = try ArchiveStream.process(readingFrom: decodeStream, writingTo: extractStream)
        Logger.default.debug("processed \(totalBytes) bytes.")
    }
}
