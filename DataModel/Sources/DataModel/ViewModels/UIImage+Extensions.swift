//
//  UIImage+Extensions.swift
//  
//
//  Created by Danis Tazetdinov on 01.02.2022.
//

import UIKit

public extension UIImage {
    func resizeToFill(size: CGSize) -> UIImage {
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height

        let aspectRatio = max(aspectWidth, aspectHeight)
        let resultingSize = CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio)

        return UIGraphicsImageRenderer(size: resultingSize).image { ctx in
            self.draw(in: CGRect(origin: .zero, size: resultingSize))
        }
    }

    func resizeToFit(size: CGSize) -> UIImage {
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height

        let aspectRatio = min(aspectWidth, aspectHeight)
        let resultingSize = CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio)

        return UIGraphicsImageRenderer(size: resultingSize).image { ctx in
            self.draw(in: CGRect(origin: .zero, size: resultingSize))
        }
    }

    func heicData(compressionQuality: Double) -> Data? {
        guard
            let cgImage = cgImage,
            let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, "public.heic" as CFString, 1, nil)
        else {
            return nil
        }
        CGImageDestinationAddImage(destination, cgImage, [kCGImageDestinationLossyCompressionQuality: compressionQuality, kCGImagePropertyOrientation: cgImageOrientation.rawValue] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }

    var cgImageOrientation: CGImagePropertyOrientation { .init(imageOrientation) }
}

//extension CGImagePropertyOrientation {
//    init(uiOrientation: UIImage.Orientation) {
//        switch uiOrientation {
//            case .up: self = .up
//            case .upMirrored: self = .upMirrored
//            case .down: self = .down
//            case .downMirrored: self = .downMirrored
//            case .left: self = .left
//            case .leftMirrored: self = .leftMirrored
//            case .right: self = .right
//            case .rightMirrored: self = .rightMirrored
//        @unknown default:
//            fatalError()
//        }
//    }
//}
