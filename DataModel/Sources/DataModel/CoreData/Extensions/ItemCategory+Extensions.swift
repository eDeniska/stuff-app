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
                        category.order = Int64(appCategory.sortOrder)
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
}
