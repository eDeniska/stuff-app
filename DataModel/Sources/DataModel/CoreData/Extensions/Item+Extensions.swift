//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import CoreData
import Logger
import UIKit

public extension Item {
    @objc var categoryTitle: String {
        category?.title ?? ""
    }

    var thumbnail: UIImage? {
        guard let data = thumbnailData else {
            return nil
        }
        return UIImage(data: data)
    }

    static func item(with url: URL, in context: NSManagedObjectContext) -> Item? {
        guard let objectId = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url),
              let item = try? context.existingObject(with: objectId) as? Item else {
            return nil
        }
        return item
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
}
