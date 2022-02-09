//
//  DisplayedCategory.swift
//  
//
//  Created by Danis Tazetdinov on 16.01.2022.
//

import Foundation
import CoreData

public enum DisplayedCategory: Equatable {

    // TODO: ensure category title is not empty

    case custom(String)
    case predefined(AppCategory)

    public var title: String {
        switch self {
        case .custom(let title):
            return title.trimmingCharacters(in: .whitespacesAndNewlines)

        case .predefined(let appCategory):
            return appCategory.rawValue
        }
    }

    public func itemCategory(in context: NSManagedObjectContext) -> ItemCategory {
        // first - try to find existing category, if not found, create entry accordingly
        switch self {
        case .custom(let title):
            let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
            let fetchRequest = ItemCategory.fetchRequest()
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(ItemCategory.title)) == %@", trimmed)
            if let existing = (try? context.fetch(fetchRequest))?.first {
                existing.order = 0
                return existing
            } else {
                let newCategory = ItemCategory(context: context)
                newCategory.title = trimmed
                newCategory.identifier = UUID()
                newCategory.order = 0
                newCategory.icon = "list.bullet"
                return newCategory
            }

        case .predefined(let category):
            let fetchRequest = ItemCategory.fetchRequest()
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(ItemCategory.appCategory)) == %@", category.rawValue)
            if let existing = (try? context.fetch(fetchRequest))?.first {
                existing.order = Int64(category.sortOrder)
                return existing
            } else {
                let newCategory = ItemCategory(context: context)
                newCategory.appCategory = category.rawValue
                newCategory.title = category.rawValue
                newCategory.icon = category.iconName
                newCategory.order = Int64(category.sortOrder)
                newCategory.identifier = UUID()
                return newCategory
            }
        }
    }
}
