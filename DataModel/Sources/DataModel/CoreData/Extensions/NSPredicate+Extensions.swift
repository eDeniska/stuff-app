//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 17.02.2022.
//

import Foundation

public extension NSPredicate {
    static func contains(keyPath: String, text: String) -> NSPredicate {
        NSPredicate(format: "%K CONTAINS[cd] %@", keyPath, text)
    }

    static func like(keyPath: String, text: String) -> NSPredicate {
        NSPredicate(format: "%K LIKE %@", keyPath, text)
    }

    static func anyContains(keyPath: String, text: String) -> NSPredicate {
        NSPredicate(format: "ANY %K CONTAINS[cd] %@", keyPath, text)
    }

    static func isNil(keyPath: String) -> NSPredicate {
        NSPredicate(format: "%K == nil", keyPath)
    }

    static func equalsTo(keyPath: String, object: CVarArg) -> NSPredicate {
        NSPredicate(format: "%K == %@", keyPath, object)
    }

    static func anyEqualsTo(keyPath: String, object: CVarArg) -> NSPredicate {
        NSPredicate(format: "ANY %K == %@", keyPath, object)
    }

}
