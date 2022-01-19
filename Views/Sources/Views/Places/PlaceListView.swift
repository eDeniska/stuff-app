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
        animation: .default) private var places: FetchedResults<ItemPlace>

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
                        viewContext.saveOrRollback()
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
