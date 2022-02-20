//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 18.02.2022.
//

import Foundation
import CoreData
import Logger

public struct Archive: Codable {

    private enum Constants {
        static let imagesFolder = "images"
        static let dataFile = "stuff.json"
    }
    
    struct Item: Codable {
        var color: String?
        var condition: String?
        var details: String
        var identifier: UUID
        var isLost: Bool
        var lastModified: Date
        var title: String
        var categoryIdentifier: UUID?
        var placeIdentifier: UUID?
    }
    
    struct Place: Codable {
        var icon: String
        var identifier: UUID
        var title: String
    }
    
    struct Category: Codable {
        var appCategory: String?
        var icon: String
        var identifier: UUID
        var order: Int
        var title: String
    }

    struct Checklist: Codable {

        struct Entry: Codable {
            var icon: String?
            var order: Int
            var title: String
            var isChecked: Bool
            var itemIdentifier: UUID?
        }

        var details: String?
        var identifier: UUID
        var icon: String?
        var lastModified: Date
        var title: String
        var entries: [Entry]
    }

    var items: [Item]
    var places: [Place]
    var categories: [Category]
    var checklists: [Checklist]
}

extension Archive.Item {
    init(item: Item) {
        condition = item.condition
        details = item.details
        identifier = item.identifier
        isLost = item.isLost
        lastModified = item.lastModified
        title = item.title
        categoryIdentifier = item.category?.identifier
        placeIdentifier = item.place?.identifier
    }

    @discardableResult
    func item(in context: NSManagedObjectContext) -> Item {
        let item: Item
        if let existingItem = Item.item(with: identifier, in: context) {
            item = existingItem
        } else {
            item = Item(context: context)
            item.identifier = identifier
        }
        item.details = details
        item.condition = ItemCondition(storedValue: condition).rawValue
        item.isLost = isLost
        item.lastModified = lastModified
        item.title = title
        if let categoryIdentifier = categoryIdentifier {
            item.category = .category(with: categoryIdentifier, in: context)
        }
        if let placeIdentifier = placeIdentifier {
            item.place = .place(with: placeIdentifier, in: context)
        }
        return item
    }
}

extension Archive.Place {
    init(place: ItemPlace) {
        icon = place.icon
        identifier = place.identifier
        title = place.title
    }

    @discardableResult
    func place(in context: NSManagedObjectContext) -> ItemPlace {
        let place: ItemPlace
        if let existingPlace = ItemPlace.place(with: identifier, in: context) {
            place = existingPlace
        } else {
            place = ItemPlace(context: context)
            place.identifier = identifier
        }
        place.icon = icon
        place.identifier = identifier
        place.title = title

        return place
    }
}

extension Archive.Category {
    init(category: ItemCategory) {
        appCategory = category.appCategory
        icon = category.icon
        identifier = category.identifier
        order = Int(category.order)
        title = category.title
    }

    @discardableResult
    func category(in context: NSManagedObjectContext) -> ItemCategory {
        let category: ItemCategory
        if let existingCategory = ItemCategory.category(with: identifier, in: context) {
            category = existingCategory
        } else {
            category = ItemCategory(context: context)
            category.identifier = identifier
        }
        category.icon = icon
        category.identifier = identifier
        category.title = title
        category.order = Int64(order)
        category.appCategory = appCategory

        return category
    }
}

extension Archive.Checklist.Entry {
    init(entry: ChecklistEntry) {
        icon = entry.icon
        order = Int(entry.order)
        title = entry.title
        isChecked = entry.isChecked
    }

    @discardableResult
    func entry(in context: NSManagedObjectContext) -> ChecklistEntry {
        let entry = ChecklistEntry(context: context)
        entry.icon = icon
        entry.order = Int64(order)
        entry.title = title
        entry.isChecked = isChecked
        return entry
    }
}

extension Archive.Checklist {
    init(checklist: Checklist) {
        details = checklist.details
        identifier = checklist.identifier
        icon = checklist.icon
        lastModified = checklist.lastModified
        title = checklist.title
        entries = checklist.entries.map { Entry(entry: $0) }
    }

    @discardableResult
    func checklist(in context: NSManagedObjectContext) -> Checklist {
        let checklist: Checklist
        if let existingChecklist = Checklist.checklist(with: identifier, in: context) {
            checklist = existingChecklist
            checklist.entries.forEach(context.delete)
        } else {
            checklist = Checklist(context: context)
            checklist.identifier = identifier
        }
        checklist.details = details
        checklist.identifier = identifier
        checklist.icon = icon
        checklist.lastModified = lastModified
        checklist.title = title
        entries.forEach { entry in
            let checklistEntry = entry.entry(in: context)
            checklistEntry.checklist = checklist
            checklistEntry.updateSortOrder()
        }

        return checklist
    }
}

// MARK: - Export
public extension Archive {
    init(context: NSManagedObjectContext) {
        items = DataModel.Item.all(in: context).map { Archive.Item(item: $0) }
        places = ItemPlace.all(in: context).map { Archive.Place(place: $0) }
        categories = ItemCategory.all(in: context).map { Archive.Category(category: $0) }
        checklists = DataModel.Checklist.all(in: context).map { Archive.Checklist(checklist: $0) }
    }

    func saveArchive() throws -> URL {
        let folderName = UUID().uuidString
        let rootFolder = FileManager.default.temporaryDirectory.appendingPathComponent(folderName)

        let archiveFile = rootFolder.appendingPathComponent(Constants.dataFile)
        let imagesFolder = rootFolder.appendingPathComponent(Constants.imagesFolder)

        try FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true)

        let data = try JSONEncoder().encode(self)
        try data.write(to: archiveFile, options: .atomic)

        try Self.saveFiles(to: imagesFolder)

        return rootFolder
    }

    private static func saveFiles(to url: URL) throws {
        Logger.default.info("total \(FileStorageManager.shared.items.count) item(s) in container.")
        try FileStorageManager.shared.items.forEach { fileURL in
            let fileName = fileURL.lastPathComponent
            guard !fileName.starts(with: ".") else {
                return
            }
            var isDirectory = ObjCBool(false)
            guard FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory), !isDirectory.boolValue else {
                return
            }
            Logger.default.info("copying \(fileURL) to \(url.appendingPathComponent(fileName))")
            try FileStorageManager.shared.copyFile(at: fileURL, to: url.appendingPathComponent(fileName))
        }
    }
}

// MARK: - Import
public extension Archive {

    init(url: URL) throws {
        let archiveFile = url.appendingPathComponent(Constants.dataFile)
        let imagesFollder = url.appendingPathComponent(Constants.imagesFolder)

        try Self.extractFiles(from: imagesFollder)
        self = try JSONDecoder().decode(Self.self, from: try Data(contentsOf: archiveFile))
    }

    func extract(to context: NSManagedObjectContext) {
        places.forEach { $0.place(in: context) }
        categories.forEach { $0.category(in: context) }
        items.forEach { $0.item(in: context) }
        checklists.forEach { $0.checklist(in: context) }
    }

    private static func extractFiles(from url: URL) throws {
        let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey], options: [])
        urls.forEach { fileURL in
            FileStorageManager.shared.removeItems(withPrefix: fileURL.lastPathComponent)
            FileStorageManager.shared.saveFile(at: fileURL, name: fileURL.lastPathComponent)
        }
    }
}
