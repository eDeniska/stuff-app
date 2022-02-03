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
    @State private var shouldAddNew = false

    public init() {
    }

    public var body: some View {
        NavigationView {
            List {
                ForEach(places) { place in
                    NavigationLink {
                        PlaceDetailsView(place: place)
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
            .sheet(isPresented: $shouldAddNew) {
                NewPlaceView()
                    .onDisappear {
                        shouldAddNew = false
                    }
            }
            .searchable(text: $searchText, prompt: Text("Search for places..."))
            .navigationTitle("Places")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        shouldAddNew = true
                    } label: {
                        Label("Add Place", systemImage: "plus")
                    }
                }
            }
            PlaceDetailsWelcomeView {
                shouldAddNew = true
            }
            // TODO: add actual search for places
        }
        .tabItem {
            Label("Places", systemImage: "house")
        }
    }
}
