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

struct ContentView: View {

    var body: some View {
        TabView {
            ItemListView()
            PlaceListView()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
