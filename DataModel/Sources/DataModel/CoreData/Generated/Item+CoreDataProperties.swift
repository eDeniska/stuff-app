//
//  Item+CoreDataProperties.swift
//  
//
//  Created by Danis Tazetdinov on 07.02.2022.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var color: String?
    @NSManaged public var condition: String?
    @NSManaged public var details: String
    @NSManaged public var identifier: UUID
    @NSManaged public var isLost: Bool
    @NSManaged public var lastModified: Date
    @NSManaged public var thumbnailData: Data?
    @NSManaged public var title: String
    @NSManaged public var category: ItemCategory?
    @NSManaged public var checklistEntries: Set<ChecklistEntry>
    @NSManaged public var place: ItemPlace?

}

extension Item: Identifiable { }
