//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import CoreData
import Logger
import UIKit

public extension Item {
    @objc var categoryTitle: String {
        category?.title ?? ""
    }

    var thumbnail: UIImage? {
        guard let data = thumbnailData else {
            return nil
        }
        return UIImage(data: data)
    }

    func delete() {
        managedObjectContext?.delete(self)
        managedObjectContext?.saveOrRollback()
    }

    func isListed(in checklist: Checklist) -> Bool {
        checklist.entries?.compactMap { ($0 as? ChecklistEntry)?.item }.contains(self) ?? false
    }

    func add(to checklist: Checklist) {
        guard !isListed(in: checklist), let context = managedObjectContext else {
            return
        }
        let entry = ChecklistEntry(context: context)
        entry.title = title ?? ""
        if let appCategoryString = category?.appCategory, let appCategory = AppCategory(rawValue: appCategoryString) {
            entry.icon = appCategory.iconName
        } else {
            entry.icon = checklist.icon
        }
        entry.item = self
        entry.checklist = checklist
        entry.updateSortOrder()
    }
}
