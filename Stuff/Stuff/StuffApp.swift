//
//  StuffApp.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 07.12.2021.
//

import SwiftUI
import DataModel

@main
struct StuffApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
