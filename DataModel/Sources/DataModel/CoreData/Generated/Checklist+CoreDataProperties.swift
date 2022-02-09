//
//  Checklist+CoreDataProperties.swift
//  
//
//  Created by Danis Tazetdinov on 07.02.2022.
//
//

import Foundation
import CoreData


extension Checklist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Checklist> {
        return NSFetchRequest<Checklist>(entityName: "Checklist")
    }

    @NSManaged public var details: String?
    @NSManaged public var icon: String?
    @NSManaged public var lastModified: Date
    @NSManaged public var title: String
    @NSManaged public var entries: Set<ChecklistEntry>

}

extension Checklist: Identifiable { }
