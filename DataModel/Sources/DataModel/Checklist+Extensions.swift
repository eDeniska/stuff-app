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
        entry.title = title
        entry.icon = icon
        entry.lastModified = Date()
        return entry
    }

    static func available(for item: Item) -> [Checklist] {
        guard let context = item.managedObjectContext else {
            return []
        }
        let request = Checklist.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Checklist.lastModified), ascending: false)]
        request.predicate = NSPredicate(format: "SUBQUERY(\(#keyPath(Checklist.entries)), $e, $e.item == %@).@count == 0", item)
        return (try? context.fetch(request)) ?? []
    }

}
