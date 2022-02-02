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

}
