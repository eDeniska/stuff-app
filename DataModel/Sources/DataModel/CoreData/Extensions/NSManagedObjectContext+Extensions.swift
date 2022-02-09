//
//  NSManagedObjectContext+Extensions.swift
//  
//
//  Created by Danis Tazetdinov on 19.01.2022.
//

import CoreData
import Logger

public extension NSManagedObjectContext {
    func saveOrRollback() {
        do {
            try save()
        } catch {
            rollback()
            Logger.default.error("rollback on error saving context: \(error)")
        }
    }

    func saveOrReset() {
        do {
            try save()
        } catch {
            reset()
            Logger.default.error("reset on error saving context: \(error)")
        }
    }
}
