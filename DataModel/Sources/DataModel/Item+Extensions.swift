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
}
