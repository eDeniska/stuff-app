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

    private let imagePredictor = ImagePredictor()

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
        images = []
        imageRecords = []
        if let identifier = item?.identifier {
            Task {
                let urls = fileStorageManager.urls(withPrefix: identifier.uuidString).sorted { $0.absoluteString < $1.absoluteString }

                var loadedImages: [ImageData] = []
                for url in urls {
                    do {
                        loadedImages.append(ImageData(imageData: try await fileStorageManager.loadFile(at: url)))
                    } catch {
                        Logger.default.log(.error, "could not load image: \(error)")
                    }
                }
                imageRecords = loadedImages
            }

        }
    }

    public func predict() async {
        Logger.default.log(.info, "starting predictions...")
        var predictedText = ""
        let predictions: [ItemPrediction] = await withTaskGroup(of: [ItemPrediction].self) { group in
            for image in images {
                group.addTask {
                    let predictions = try? await self.imagePredictor.makePredictions(for: image)
                    Logger.default.log(.info, "got predictions: \(predictions ?? [])...")
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
        Logger.default.log(.info, "got predicted:\n\(predictedText)")

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
            Logger.default.log(.error, "could not get data for image image: \(image)")
            return
        }
        imageRecords.append(ImageData(imageData: data))
    }

    public func addImages(_ images: [UIImage]) {
        imageRecords.append(contentsOf: images
                                .compactMap { $0.jpegData(compressionQuality: 0.9) }
                                .map(ImageData.init(imageData:)))
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
        newItem.identifier = identifier
        newItem.title = title
        newItem.details = details
        newItem.category = category.itemCategory(in: context)

        // TODO: will need to save condition, color, isLosd properly
        newItem.condition = ""
        newItem.color = ""
        newItem.isLost = false
        newItem.lastModified = .now

        // TODO: need to save/show place

        fileStorageManager.removeItems(withPrefix: identifier.uuidString)
        for (index, image) in imageRecords.enumerated() {
            let indexString = "\(index)"
            let padded = indexString.padding(toLength: 10 - indexString.count, withPad: "0", startingAt: 0)
            fileStorageManager.save(data: image.imageData, with: "\(identifier.uuidString)-\(padded).jpg")
        }
    }
}
