//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 18.02.2022.
//

import SwiftUI
import CoreData
import Logger
import DataModel

private struct PersistentContainerKey: EnvironmentKey {
    static let defaultValue: NSPersistentContainer = PersistenceController.shared.container
}

public extension EnvironmentValues {
    var persistentContainer: NSPersistentContainer {
        get { self[PersistentContainerKey.self] }
        set { self[PersistentContainerKey.self] = newValue }
    }
}


