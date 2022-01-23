//
//  StuffMacApp.swift
//  StuffMac
//
//  Created by Danis Tazetdinov on 23.01.2022.
//

import SwiftUI
import DataModel

@main
struct StuffMacApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
