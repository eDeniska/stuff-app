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

// TODO: add "lists" feature - compose lists of existing items (prepare to pack things for trip, for example)
// TODO: add checked status for list item
// TODO: add option to export data
// TODO: add option to share lists
// TODO: add option to make reminders out of lists

struct ContentView: View {

    var body: some View {
        TabView {
            ItemListView()
            PlaceListView()
            // TODO: consider dropping TabView altogether
            // TODO: consider removing settings altogether
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
