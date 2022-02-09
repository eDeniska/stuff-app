//
//  ItemCategory+CoreDataProperties.swift
//  
//
//  Created by Danis Tazetdinov on 07.02.2022.
//
//

import Foundation
import CoreData


extension ItemCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemCategory> {
        return NSFetchRequest<ItemCategory>(entityName: "ItemCategory")
    }

    @NSManaged public var appCategory: String?
    @NSManaged public var icon: String
    @NSManaged public var identifier: UUID
    @NSManaged public var order: Int64
    @NSManaged public var title: String
    @NSManaged public var items: Set<Item>

}

extension ItemCategory: Identifiable { }
