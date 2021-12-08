//
//  PlaceListView.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import DataModel

public struct PlaceListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\ItemPlace.title)
                         ],
        animation: .default)

    private var places: FetchedResults<ItemPlace>
    @State private var searchText: String = ""

    public init() {
    }

    public var body: some View {
        NavigationView {
            List {
                ForEach(places) { place in
                    NavigationLink {
                        PlaceListElement(place: place)
                    } label: {
                        PlaceListElement(place: place)
                    }
                }
                .onDelete { indexSets in
                    withAnimation {
                        indexSets.map { places[$0] }.forEach(viewContext.delete)

                        do {
                            try viewContext.save()
                        } catch {
                            // Replace this implementation with code to handle the error appropriately.
                            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: Text("Search for items..."))
            .navigationTitle("Places")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .tabItem {
            Label("Places", systemImage: "building.2")
        }
    }
}
