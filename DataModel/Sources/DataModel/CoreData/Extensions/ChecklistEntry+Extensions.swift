//
//  ChecklistEntry+Extensions.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import CoreData
import Logger

public extension ChecklistEntry {

    func updateSortOrder() {
        guard let checklist = checklist else {
            return
        }
        let request = ChecklistEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ChecklistEntry.order), ascending: false)]
        request.predicate = .equalsTo(keyPath: #keyPath(ChecklistEntry.checklist), object: checklist)
        request.fetchLimit = 1
        let maxOrder = (try? managedObjectContext?.fetch(request).first?.order) ?? 0
//        Logger.default.debug("got max order = \(maxOrder)")
        order = maxOrder + 1
    }

}
