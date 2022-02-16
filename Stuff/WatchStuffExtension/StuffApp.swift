//
//  StuffApp.swift
//  WatchStuff WatchKit Extension
//
//  Created by Danis Tazetdinov on 16.02.2022.
//

import SwiftUI
import DataModel

@main
struct StuffApp: App {
    private let container = PersistenceController.sharedLocal.container
    
    var body: some Scene {
        WindowGroup {
            ChecklistsListView()
                .environment(\.managedObjectContext, container.viewContext)
        }
    }
}
