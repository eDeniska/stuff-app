//
//  ChecklistEntry+CoreDataProperties.swift
//  
//
//  Created by Danis Tazetdinov on 07.02.2022.
//
//

import Foundation
import CoreData


extension ChecklistEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChecklistEntry> {
        return NSFetchRequest<ChecklistEntry>(entityName: "ChecklistEntry")
    }

    @NSManaged public var icon: String?
    @NSManaged public var order: Int64
    @NSManaged public var title: String
    @NSManaged public var isChecked: Bool
    @NSManaged public var checklist: Checklist?
    @NSManaged public var item: Item?

}

extension ChecklistEntry: Identifiable { }
