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

}
