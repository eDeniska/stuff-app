//
//  ContentView.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 07.12.2021.
//

import SwiftUI
import CoreData
import Views
import DataModel

// TODO: add option to export and import data
// TODO: add option to share checklists
// TODO: add option to make reminders out of checklists

// TODO: add onSubmit actions for text fields where appropriate

// TODO: add keyboard commands



struct ContentView: View {

    var body: some View {
        if UIDevice.current.isMac {
            MacContentView()
        } else {
            TabView {
                ItemListView()
                PlaceListView()
                ChecklistListView()
                //            // TODO: consider removing settings altogether
                if !UIDevice.current.isMac {
                    NavigationView {
                        Text("Settings")
                            .navigationTitle("Settings")
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
