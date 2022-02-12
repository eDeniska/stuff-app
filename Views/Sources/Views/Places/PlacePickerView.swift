//
//  PlacePickerView.swift
//  
//
//  Created by Danis Tazetdinov on 17.01.2022.
//

import SwiftUI
import DataModel
import Logger
import CoreData
import Localization

struct PlacePickerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\ItemPlace.title)],animation: .default)
    private var places: FetchedResults<ItemPlace>
    
    @State private var searchText: String = ""
    
    @Binding var place: ItemPlace?
    
    var body: some View {
        PhoneNavigationView {
            List {
                Section {
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
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        indexSet.map { places[$0] }.forEach(viewContext.delete)
                        viewContext.saveOrRollback()
                    }
                }
                Section {
                    Button {
                        place = nil
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Text(L10n.PlacesList.noPlaceAssigned.localized)
                            Spacer()
                            if place == nil {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: Text(L10n.PlacesList.searchPlaceholder.localized))
            .onChange(of: searchText) { newValue in
                let text = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if text.isEmpty {
                    places.nsPredicate = nil
                } else {
                    places.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:
                                                                [#keyPath(ItemPlace.title)].map { keyPath in
                        NSPredicate(format: "%K CONTAINS[cd] %@", keyPath, text)
                    })
                }
            }
            .navigationTitle(L10n.PlacesList.listTitle.localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text(L10n.Common.buttonCancel.localized)
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
    }
}
