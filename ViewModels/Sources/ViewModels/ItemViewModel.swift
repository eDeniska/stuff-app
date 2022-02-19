//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 16.01.2022.
//

import Foundation
import Combine
import CoreData
import UIKit
import Logger
import ImageRecognizer
import Localization
import DataModel

@MainActor
public class ItemViewModel: ObservableObject {
    private let item: Item?
    private let fileStorageManager = FileStorageManager.shared

    @Published public private(set) var images: [ImageData] {
        didSet {
            Task {
                for image in images {
                    await image.buildImage()
                }
            }
        }
    }

    @Published public var title: String
    @Published public var details: String
    @Published public var category: DisplayedCategory
    @Published public var place: ItemPlace?
    @Published public var condition: ItemCondition
    @Published public var isLost: Bool
    @Published public var checklists: [Checklist]

    public var thumbnail: UIImage? {
        item?.thumbnail
    }

    private let imagePredictor = ImagePredictor()

    private var monitorCancellable: AnyCancellable?

    public init(item: Item?) {
        self.item = item

        title = item?.title ?? ""
        details = item?.details ?? ""

        if let item = item {
            checklists = Checklist.available(for: item)
        } else {
            checklists = []
        }


        if let appCategoryString = item?.category?.appCategory, let appCategory = AppCategory(rawValue: appCategoryString) {
            category = .predefined(appCategory)
        } else if let categoryString = item?.category?.title {
            category = .custom(categoryString)
        } else {
            category = .predefined(.other)
        }
        condition = ItemCondition(storedValue: item?.condition)
        place = item?.place
        isLost = item?.isLost ?? false
        images = []
        if let identifier = item?.identifier {
            reloadImages(for: identifier)

            monitorCancellable = fileStorageManager.$items.receive(on: DispatchQueue.main).sink { [weak self] urls in
                guard let self = self else {
                    return
                }
                self.reloadImages(for: identifier)
            }
        }
    }

    private func reloadImages(for identifier: UUID) {
        let filtered = fileStorageManager.urls(withPrefix: identifier.uuidString)

        Task {
            var loadedImages: [ImageData] = []
            for url in filtered {
                do {
                    loadedImages.append(ImageData(imageData: try await fileStorageManager.loadFile(at: url), url: url))
                } catch {
                    Logger.default.error("could not load image: \(error)")
                }
            }
            images = loadedImages
        }
    }

    public func predict() async {
        Logger.default.info("starting predictions...")
        var predictedText = ""
        let predictions: [ItemPrediction] = await withTaskGroup(of: [ItemPrediction].self) { group in
            for image in images {
                group.addTask {
                    let predictions = try? await self.imagePredictor.makePredictions(for: image.image)
                    Logger.default.info("got predictions: \(predictions ?? [])...")
                    return predictions ?? []
                }
            }

            return await group.reduce(into: [ItemPrediction]()) { partialResult, results in
                partialResult += results
            }
        }

        predictedText.append(contentsOf: "filtered results:\n")
        let aggregated = predictions.aggregate()
        for prediction in aggregated where prediction.confidence > 0.15 {
            predictedText.append("\(prediction.detectedItem.description) [[ \(prediction.prediction) ]] (\(prediction.confidence))\n")
        }
        Logger.default.info("got predicted:\n\(predictedText)")

        if let predicted = aggregated.first, title.isEmpty {
            title = predicted.detectedItem.localizedTitle
            category = .predefined(predicted.detectedItem.category)
        }
    }

    public func removeImage(with id: String) {
        images.removeAll { $0.id == id }
    }

    public func addImage(_ image: UIImage) {
        guard let data = image.heicData(compressionQuality: 0.9) ?? image.jpegData(compressionQuality: 0.9) else {
            Logger.default.error("could not get data for image image: \(image)")
            return
        }
        images.append(ImageData(imageData: data))
    }

    public func addImages(_ addedImages: [UIImage]) {
        images.append(contentsOf: addedImages
                        .compactMap { $0.heicData(compressionQuality: 0.9) ?? $0.jpegData(compressionQuality: 0.9) }
                        .map { ImageData(imageData: $0, url: nil) })
    }

    public func add(to checklist: Checklist) {
        item?.add(to: checklist)
        item?.managedObjectContext?.saveOrRollback()
    }

    public func save(in context: NSManagedObjectContext) -> Item {
        let identifier: UUID
        let newItem: Item

        if let item = item {
            identifier = item.identifier
            newItem = item
        } else {
            identifier = UUID()
            newItem = Item(context: context)
        }
        newItem.lastModified = .now
        newItem.identifier = identifier
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            newItem.title = L10n.Item.unnamed.localized
        } else {
            newItem.title = trimmed
        }
        newItem.details = details.trimmingCharacters(in: .whitespacesAndNewlines)
        newItem.category = category.itemCategory(in: context)
        newItem.condition = condition.rawValue
        newItem.isLost = isLost
        newItem.place = place
        newItem.thumbnailData = thumbnailData()

        // TODO: will need to save color properly
        newItem.color = ""

        // find images that need deletion
        let existingImages = Set(fileStorageManager.urls(withPrefix: identifier.uuidString))
        let updatedImages = Set(images.compactMap(\.url))
        existingImages.subtracting(updatedImages).forEach { fileStorageManager.removeItem(at: $0) }

        for (index, image) in images.enumerated() {
            let indexString = "\(index)"
            let fileName = identifier.uuidString + "-" + String(repeating: "0", count: 10 - indexString.count) + indexString
            // we can only remove existing files and can't reorder them
            // therefore we will never overwrite existing images with new data
            // if we are to support reordering, this approach should be revised - could use two-pass on array
            if let url = image.url {
                if url.lastPathComponent != fileName {
                    fileStorageManager.rename(at: url, to: fileName)
                }
            } else {
                fileStorageManager.save(data: image.imageData, with: fileName)
            }
        }
        return newItem
    }

    public func reset() {
        title = item?.title ?? ""
        details = item?.details ?? ""

        if let appCategoryString = item?.category?.appCategory, let appCategory = AppCategory(rawValue: appCategoryString) {
            category = .predefined(appCategory)
        } else if let categoryString = item?.category?.title {
            category = .custom(categoryString)
        } else {
            category = .predefined(.other)
        }
        condition = ItemCondition(storedValue: item?.condition)
        place = item?.place
        isLost = item?.isLost ?? false
        images = []
        if let identifier = item?.identifier {
            reloadImages(for: identifier)
        }
    }

    private func thumbnailData() -> Data? {
        guard let image = images.first?.image.resizeToFill(size: CGSize(width: 300, height: 300)) else {
            return nil
        }
        return image.heicData(compressionQuality: 0.9) ?? image.jpegData(compressionQuality: 0.9)
    }
}

