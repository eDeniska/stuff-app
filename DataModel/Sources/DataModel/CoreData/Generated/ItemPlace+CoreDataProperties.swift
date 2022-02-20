//
//  ItemPlace+CoreDataProperties.swift
//  
//
//  Created by Danis Tazetdinov on 07.02.2022.
//
//

import Foundation
import CoreData


extension ItemPlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemPlace> {
        return NSFetchRequest<ItemPlace>(entityName: "ItemPlace")
    }

    @NSManaged public var icon: String
    @NSManaged public var identifier: UUID
    @NSManaged public var title: String
    @NSManaged public var itemsCount: Int64
    @NSManaged public var items: Set<Item>

}

extension ItemPlace: Identifiable { }
