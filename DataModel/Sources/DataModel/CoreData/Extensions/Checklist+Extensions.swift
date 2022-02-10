//
//  Checklist+Extensions.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import CoreData

public extension Checklist {

    @discardableResult
    static func checklist(title: String, icon: String, in context: NSManagedObjectContext) -> Checklist {
        let entry = Checklist(context: context)
        entry.identifier = UUID()
        entry.title = title
        entry.icon = icon
        entry.lastModified = Date()
        return entry
    }

    static func checklist(with url: URL, in context: NSManagedObjectContext) -> Checklist? {
        guard let objectId = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url),
              let checklist = try? context.existingObject(with: objectId) as? Checklist else {
            return nil
        }
        return checklist
    }
    
    static func checklist(with identifier: UUID, in context: NSManagedObjectContext) -> Checklist? {
        let request = Checklist.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Checklist.identifier), identifier as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    static func isEmpty(in context: NSManagedObjectContext) -> Bool {
        let request = Checklist.fetchRequest()
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) == 0
    }

    static func checklists(for item: Item) -> [Checklist] {
        guard let context = item.managedObjectContext else {
            return []
        }
        let request = Checklist.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Checklist.lastModified), ascending: false)]
        request.predicate = NSPredicate(format: "ANY \(#keyPath(Checklist.entries.item)) == %@", item)
        return (try? context.fetch(request)) ?? []
    }


    static func available(for item: Item) -> [Checklist] {
        guard let context = item.managedObjectContext else {
            return []
        }
        let request = Checklist.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Checklist.lastModified), ascending: false)]
        request.predicate = NSPredicate(format: "SUBQUERY(\(#keyPath(Checklist.entries)), $e, $e.\(#keyPath(ChecklistEntry.item)) == %@).@count == 0", item)
        return (try? context.fetch(request)) ?? []
    }

    func availableItems() -> [Item] {
        guard let context = managedObjectContext else {
            return []
        }
        let request = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Item.title), ascending: false)]
        request.predicate = NSPredicate(format: "SUBQUERY(\(#keyPath(Item.checklistEntries)), $e, $e.\(#keyPath(ChecklistEntry.checklist)) == %@).@count == 0", self)
        return (try? context.fetch(request)) ?? []
    }

    func updateItems(_ items: Set<Item>) {
        guard let context = managedObjectContext else {
            return
        }
        var pendingItems = items

        for existing in entries {
            guard let existingItem = existing.item else {
                continue
            }
            if pendingItems.contains(existingItem) {
                pendingItems.remove(existingItem)
            } else {
                context.delete(existing)
            }
        }

        for added in pendingItems {
            added.add(to: self)
        }
    }
}
