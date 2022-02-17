//
//  Checklist+Extensions.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import CoreData
import Logger

public extension Checklist {

    @discardableResult
    static func checklist(title: String, icon: String, in context: NSManagedObjectContext) -> Checklist {
        let entry = Checklist(context: context)
        entry.identifier = UUID()
        entry.title = title
        entry.icon = icon
        entry.lastModified = .now
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
        request.predicate = .equalsTo(keyPath: #keyPath(Checklist.identifier), object: identifier as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    static func isEmpty(in context: NSManagedObjectContext) -> Bool {
        let request = Checklist.fetchRequest()
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) == 0
    }

    static func count(in context: NSManagedObjectContext) -> Int {
        let request = Checklist.fetchRequest()
        return (try? context.count(for: request)) ?? 0
    }

    static func recentChecklists(limit: Int = 10, in context: NSManagedObjectContext) -> [Checklist] {
        let request = Checklist.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Checklist.lastModified), ascending: false)]
        request.fetchLimit = limit
        do {
            return try context.fetch(request)
        } catch {
            Logger.default.error("could lot load checklists: \(error)")
            return []
        }
    }

    static func all(in context: NSManagedObjectContext) -> [Checklist] {
        let request = Checklist.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Checklist.lastModified), ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            Logger.default.error("could lot load checklists: \(error)")
            return []
        }
    }

    static func checklists(for item: Item) -> [Checklist] {
        guard let context = item.managedObjectContext else {
            return []
        }
        let request = Checklist.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Checklist.lastModified), ascending: false)]
        request.predicate = .anyEqualsTo(keyPath: #keyPath(Checklist.entries.item), object: item)
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
        var isModified = false
        var pendingItems = items

        for existing in entries {
            guard let existingItem = existing.item else {
                continue
            }
            if pendingItems.contains(existingItem) {
                pendingItems.remove(existingItem)
            } else {
                isModified = true
                context.delete(existing)
            }
        }

        for added in pendingItems {
            added.add(to: self)
        }
        isModified = isModified || !pendingItems.isEmpty
        if isModified {
            lastModified = .now
        }
    }
}
