//
//  Place+Extensions.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import CoreData
import Logger

public extension ItemPlace {

    @discardableResult
    static func place(title: String, icon: String, in context: NSManagedObjectContext) -> ItemPlace {
        let entry = ItemPlace(context: context)
        entry.title = title
        entry.icon = icon
        entry.identifier = UUID()
        return entry
    }

    static func all(in context: NSManagedObjectContext) -> [ItemPlace] {
        let request = ItemPlace.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ItemPlace.title), ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            Logger.default.error("could lot load places: \(error)")
            return []
        }
    }

    static func place(with url: URL, in context: NSManagedObjectContext) -> ItemPlace? {
        guard let objectId = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url),
              let place = try? context.existingObject(with: objectId) as? ItemPlace else {
            return nil
        }
        return place
    }

    static func place(with identifier: UUID, in context: NSManagedObjectContext) -> ItemPlace? {
        let request = ItemPlace.fetchRequest()
        request.predicate = .equalsTo(keyPath: #keyPath(ItemPlace.identifier), object: identifier as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    func updateItems(_ updatedItems: Set<Item>) {
        var pendingItems = updatedItems

        for existing in items {
            if pendingItems.contains(existing) {
                pendingItems.remove(existing)
            } else {
                existing.place = nil
            }
        }

        for added in pendingItems {
            added.place = self
        }
    }

}
