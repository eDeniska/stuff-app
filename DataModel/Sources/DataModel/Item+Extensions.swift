//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import CoreData
import Logger

public extension Item {
    @objc var categoryTitle: String {
        category?.title ?? ""
    }

    func delete() {
        managedObjectContext?.delete(self)
        managedObjectContext?.saveOrRollback()
    }
}
