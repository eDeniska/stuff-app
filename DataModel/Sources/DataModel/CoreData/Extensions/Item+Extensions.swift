//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import CoreData
import Logger

#if canImport(UIKit)
import UIKit
#endif

public extension Item {
    @objc var categoryTitle: String {
        category?.title ?? ""
    }

    @objc var placeTitle: String {
        place?.title ?? ""
    }

    @objc var conditionTitle: String {
        ItemCondition(storedValue: condition).fullLocalizedTitle
    }

#if canImport(UIKit)
    var thumbnail: UIImage? {
        guard let data = thumbnailData else {
            return nil
        }
        return UIImage(data: data)
    }
#endif

    static func all(in context: NSManagedObjectContext) -> [Item] {
        let request = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Item.title), ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            Logger.default.error("could lot load items: \(error)")
            return []
        }
    }

    
    static func item(with url: URL, in context: NSManagedObjectContext) -> Item? {
        guard let objectId = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url),
              let item = try? context.existingObject(with: objectId) as? Item else {
            return nil
        }
        return item
    }

    static func item(with identifier: UUID, in context: NSManagedObjectContext) -> Item? {
        let request = Item.fetchRequest()
        request.predicate = .equalsTo(keyPath: #keyPath(Item.identifier), object: identifier as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    static func isEmpty(in context: NSManagedObjectContext) -> Bool {
        let request = Item.fetchRequest()
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) == 0
    }

    func delete() {
        managedObjectContext?.delete(self)
        managedObjectContext?.saveOrRollback()
    }

    func isListed(in checklist: Checklist) -> Bool {
        checklist.entries.compactMap(\.item).contains(self)
    }

    func checklists() -> [Checklist] {
        Checklist.checklists(for: self)
    }

    func add(to checklist: Checklist) {
        guard !isListed(in: checklist), let context = managedObjectContext else {
            return
        }
        let entry = ChecklistEntry(context: context)
        entry.title = title
        if let appCategoryString = category?.appCategory, let appCategory = AppCategory(rawValue: appCategoryString) {
            entry.icon = appCategory.iconName
        } else {
            entry.icon = checklist.icon
        }
        entry.item = self
        entry.checklist = checklist
        entry.updateSortOrder()
    }

    func updateChecklists(_ checklists: Set<Checklist>) {
        guard let context = managedObjectContext else {
            return
        }
        var pendingChecklists = checklists
        // remove missing checklists
        for existing in checklistEntries {
            guard let existingChecklist = existing.checklist else {
                continue
            }
            if pendingChecklists.contains(existingChecklist) {
                pendingChecklists.remove(existingChecklist)
            } else {
                context.delete(existing)
            }
        }
        for added in pendingChecklists {
            add(to: added)
        }
    }

    func images() -> [URL] {
        FileStorageManager.shared.urls(withPrefix: identifier.uuidString)
    }
    
    static func performHousekeeping(in context: NSManagedObjectContext) {
        let request = Self.fetchRequest()
        do {
            let items = try context.fetch(request)
            for item in items {
                let condition = ItemCondition(storedValue: item.condition)
                if item.condition != condition.rawValue {
                    item.condition = condition.rawValue
                }
            }
        } catch {
            Logger.default.error("could not fetch items: \(error)")
        }
    }
}
