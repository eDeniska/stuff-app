//
//  File.swift
//  
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import Foundation
import CoreData
import Logger

public extension ItemCategory {
    static func performHousekeeping(in context: NSManagedObjectContext) {
        let request = Self.fetchRequest()
        do {
            let categories = try context.fetch(request)
            for category in categories {
                if let appCategoryString = category.appCategory {
                    if let appCategory = AppCategory(rawValue: appCategoryString) {
                        if category.title != appCategory.localizedTitle {
                            category.title = appCategory.localizedTitle
                        }
                        let newOrder = Int64(appCategory.sortOrder)
                        if category.order != newOrder {
                            category.order = newOrder
                        }
                    } else {
                        // invalid app category
                        category.appCategory = nil
                        category.order = 0
                    }
                } else {
                    category.order = 0
                }
            }
        } catch {
            Logger.default.error("could not fetch categories: \(error)")
        }
    }

    static func all(in context: NSManagedObjectContext) -> [ItemCategory] {
        let request = ItemCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ItemCategory.title), ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            Logger.default.error("could lot load items: \(error)")
            return []
        }
    }


    static func category(with identifier: UUID, in context: NSManagedObjectContext) -> ItemCategory? {
        let request = ItemCategory.fetchRequest()
        request.predicate = .equalsTo(keyPath: #keyPath(ItemCategory.identifier), object: identifier as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}
