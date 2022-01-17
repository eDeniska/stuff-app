//
//  PlacePicker.swift
//  
//
//  Created by Danis Tazetdinov on 17.01.2022.
//

import SwiftUI
import DataModel
import Logger
import CoreData

struct PlacePicker: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\ItemPlace.title)
                         ],
        animation: .default) private var places: FetchedResults<ItemPlace>

    @State private var searchText: String = ""

    @Binding var place: ItemPlace?
    
    var body: some View {
        List {
            ForEach(places) { placeElement in
                Button {
                    place = placeElement
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        PlaceListElement(place: placeElement)
                        Spacer()
                        if placeElement == place {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: Text("Search for items..."))
        .navigationTitle("Places")    }
}
