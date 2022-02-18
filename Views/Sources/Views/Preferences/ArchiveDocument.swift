//
//  ArchiveDocument.swift
//  
//
//  Created by Danis Tazetdinov on 18.02.2022.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import AppleArchive

public struct ArchiveDocument: FileDocument {
    public static let readableContentTypes = [UTType.appleArchive]

    private let fileWrapper: FileWrapper

    public init(url: URL) throws {
        fileWrapper = try FileWrapper(url: url, options: [])
    }

    public init(configuration: ReadConfiguration) throws {
        fileWrapper = configuration.file
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        fileWrapper
    }


}
