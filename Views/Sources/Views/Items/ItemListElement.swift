//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import DataModel
import Combine
import UIKit
import Logger

public struct ItemListElement: View {
    @ObservedObject private var item: Item

    @ObservedObject private var fileStorageManager = FileStorageManager.shared

    @State private var image: UIImage? = nil

    public init(item: Item) {
        self.item = item
    }

    public var body: some View {
        HStack(alignment: .center) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .cornerRadius(4)
                    .padding(4)
            } else {
                Image(systemName: iconName())
                    .font(.title)
                    .frame(width: 40, height: 40)
                    .padding(4)
            }
            VStack(alignment: .leading) {
                Text(item.title ?? "Unnamed")
                    .truncationMode(.tail)
                    .lineLimit(1)
                    .font(.body)
                if let place = item.place?.title {
                    Text(place)
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .task {
                await updateImage()
            }
        }
        .onChange(of: fileStorageManager.items) { _ in
            Task {
                await updateImage()
            }
        }

    }

    private func iconName() -> String {
        guard let appCategory = item.category?.appCategory, let category = AppCategory(rawValue: appCategory) else {
            return AppCategory.other.iconName
        }
        return category.iconName
    }

    private func updateImage() async {
        if let identifier = item.identifier?.uuidString, image == nil {
                let imageData = await fileStorageManager.cachedContents(for: identifier) { data in
                    await withUnsafeContinuation { continuation in
                        DispatchQueue.global(qos: .userInitiated).async {
                            guard let image = UIImage(data: data) else {
                                continuation.resume(with: .success(data))
                                return
                            }
                            let icon = image.resizeToFill(size: CGSize(width: 300, height: 300))
                            guard let iconData = icon.jpegData(compressionQuality: 0.9) else {
                                continuation.resume(with: .success(data))
                                return
                            }

                            continuation.resume(with: .success(iconData))
                        }
                    }
                }
                if let data = imageData, let newImage = UIImage(data: data) {
                    image = newImage
                }
        }
    }
}

extension UIImage {
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

}
