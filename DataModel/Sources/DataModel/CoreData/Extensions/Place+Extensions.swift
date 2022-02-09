//
//  Place+Extensions.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import CoreData

public extension ItemPlace {

    @discardableResult
    static func place(title: String, icon: String, in context: NSManagedObjectContext) -> ItemPlace {
        let entry = ItemPlace(context: context)
        entry.title = title
        entry.icon = icon
        entry.identifier = UUID()
        return entry
    }

    static func places(for item: Item) -> [ItemPlace] {
        guard let context = item.managedObjectContext else {
            return []
        }
        let request = ItemPlace.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ItemPlace.title), ascending: true)]
        request.predicate = NSPredicate(format: "ANY %K == %@", #keyPath(ItemPlace.items), item)
        return (try? context.fetch(request)) ?? []
    }

    static func place(with url: URL, in context: NSManagedObjectContext) -> ItemPlace? {
        guard let objectId = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url),
              let place = try? context.existingObject(with: objectId) as? ItemPlace else {
            return nil
        }
        return place
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
