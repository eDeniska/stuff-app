//
//  ImageData.swift
//  
//
//  Created by Danis Tazetdinov on 16.01.2022.
//

import Foundation
import UIKit
import DataModel

public class ImageData: Identifiable, Equatable {
    public static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        lhs.id == rhs.id
    }

    public let id: String
    let imageData: Data
    let url: URL?

    private var backingImage: UIImage?


    public var suggestedName: String {
        url?.lastPathComponent ?? id
    }

    public var image: UIImage {
        if backingImage == nil {
            backingImage =  UIImage(data: imageData)?.preparingForDisplay()
        }
        return backingImage ?? UIImage()
    }

    init(imageData: Data, url: URL? = nil) {
        self.imageData = imageData
        self.url = url
        id = url?.absoluteString ?? UUID().uuidString
    }

    @discardableResult
    public func buildImage() async -> UIImage? {
        if let backingImage = backingImage {
            return backingImage
        }
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInteractive).async {
                continuation.resume(returning: UIImage(data: self.imageData)?.preparingForDisplay())
            }
        }
    }
}

extension Array where Element == ImageData {
    public func collect() async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: [UIImage].self) { group in
            for imageData in self {
                group.addTask {
                    if let image = await imageData.buildImage() {
                        return [image]
                    } else {
                        return []
                    }
                }
            }

            return try await group.reduce(into: []) { partialResult, images in
                partialResult += images
            }
        }
    }
}
