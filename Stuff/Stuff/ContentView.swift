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

    @Binding var selectedItem: Item?
    @Binding var selectedPlace: ItemPlace?
    @Binding var selectedChecklist: Checklist?
    @SceneStorage("selectedTab") private var selected = 0

    var body: some View {
        if UIDevice.current.isMac {
            MacContentView(selectedItem: $selectedItem, selectedPlace: $selectedPlace, selectedChecklist: $selectedChecklist)
        } else {
            TabView(selection: $selected) {
                ItemListView(selectedItem: $selectedItem)
                    .tag(0)
                PlaceListView(selectedPlace: $selectedPlace)
                    .tag(1)
                ChecklistListView(selectedChecklist: $selectedChecklist)
                    .tag(2)
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
            .onChange(of: selectedItem) { newValue in
                if newValue != nil {
                    selected = 0
                }
            }
            .onChange(of: selectedPlace) { newValue in
                if newValue != nil {
                    selected = 1
                }
            }
            .onChange(of: selectedChecklist) { newValue in
                if newValue != nil {
                    selected = 2
                }
            }
        }
    }
}
