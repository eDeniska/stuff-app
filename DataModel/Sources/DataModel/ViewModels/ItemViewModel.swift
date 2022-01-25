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

@MainActor
public class ItemViewModel: ObservableObject {
    private let item: Item?
    private let fileStorageManager = FileStorageManager.shared

    @Published public private(set) var images: [UIImage]

    private var imageRecords: [ImageData] {
        didSet {
            Task {
                var rebuiltImages: [UIImage] = []
                for imageRecord in imageRecords {
                    if let image = await imageRecord.image() {
                        rebuiltImages.append(image)
                    }
                }
                images = rebuiltImages
            }
        }
    }

    @Published public var title: String
    @Published public var details: String
    @Published public var category: DisplayedCategory
    @Published public var place: ItemPlace?
    @Published public var condition: ItemCondition
    @Published public var isLost: Bool

    private let imagePredictor = ImagePredictor()

    private var monitorCancellable: AnyCancellable?

    public init(item: Item?) {
        self.item = item

        title = item?.title ?? ""
        details = item?.details ?? ""

        if let appCategoryString = item?.category?.appCategory, let appCategory = AppCategory(rawValue: appCategoryString) {
            category = .predefined(appCategory)
        } else if let categoryString = item?.category?.title {
            category = .custom(categoryString)
        } else {
            category = .predefined(.other)
        }
        if let conditionString = item?.condition, let itemCondition = ItemCondition(rawValue: conditionString) {
            condition = itemCondition
        } else {
            condition = .unknown
        }
        place = item?.place
        isLost = item?.isLost ?? false
        images = []
        imageRecords = []
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
            imageRecords = loadedImages
        }
    }

    public func predict() async {
        Logger.default.info("starting predictions...")
        var predictedText = ""
        let predictions: [ItemPrediction] = await withTaskGroup(of: [ItemPrediction].self) { group in
            for image in images {
                group.addTask {
                    let predictions = try? await self.imagePredictor.makePredictions(for: image)
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
            title = predicted.detectedItem.rawValue
            category = .predefined(predicted.detectedItem.category)
        }
    }

    public func removeImage(at index: Int) {
        imageRecords.remove(at: index)
    }

    public func addImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            Logger.default.error("could not get data for image image: \(image)")
            return
        }
        imageRecords.append(ImageData(imageData: data))
    }

    public func addImages(_ images: [UIImage]) {
        imageRecords.append(contentsOf: images
                                .compactMap { $0.jpegData(compressionQuality: 0.9) }
                                .map { ImageData(imageData: $0, url: nil) })
    }

    public func save(in context: NSManagedObjectContext) {
        let identifier: UUID
        let newItem: Item

        if let item = item {
            identifier = item.identifier ?? UUID()
            newItem = item
        } else {
            identifier = UUID()
            newItem = Item(context: context)
        }
        newItem.lastModified = .now
        newItem.identifier = identifier
        newItem.title = title
        newItem.details = details
        newItem.category = category.itemCategory(in: context)
        newItem.condition = condition.rawValue
        newItem.isLost = isLost
        newItem.place = place

        // TODO: will need to save color properly
        newItem.color = ""

        // find images that need deletion
        let existingImages = Set(fileStorageManager.urls(withPrefix: identifier.uuidString))
        let updatedImages = Set(imageRecords.compactMap(\.url))
        existingImages.subtracting(updatedImages).forEach { fileStorageManager.removeItem(at: $0) }

        fileStorageManager.removeItems(withPrefix: identifier.uuidString)
        for (index, image) in imageRecords.enumerated() {
            let indexString = "\(index)"
            let fileName = String(repeating: "0", count: 10 - indexString.count) + indexString
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
        if let conditionString = item?.condition, let itemCondition = ItemCondition(rawValue: conditionString) {
            condition = itemCondition
        } else {
            condition = .unknown
        }
        place = item?.place
        isLost = item?.isLost ?? false
        images = []
        imageRecords = []
        if let identifier = item?.identifier {
            reloadImages(for: identifier)
        }
    }
}
