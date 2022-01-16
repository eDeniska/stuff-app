//
//  ImageData.swift
//  
//
//  Created by Danis Tazetdinov on 16.01.2022.
//

import Foundation
import UIKit

public struct ImageData: Identifiable {
    public let id: UUID
    let imageData: Data

    init(imageData: Data) {
        self.imageData = imageData
        id = UUID()
    }

    public func image() async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInteractive).async {
                continuation.resume(returning: UIImage(data: imageData)?.preparingForDisplay())
            }
        }
    }
}

extension Array where Element == ImageData {
    public func collect() async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: [UIImage].self) { group in
            for imageData in self {
                group.addTask {
                    if let image = await imageData.image() {
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
