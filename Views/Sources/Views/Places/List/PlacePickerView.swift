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
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\ItemPlace.title)],animation: .default)
    private var places: FetchedResults<ItemPlace>
    
    @State private var searchText: String = ""
    @State private var shouldAddNew = false

    @Binding var place: ItemPlace?
    let itemTitle: String

    @State private var createdPlace: ItemPlace? = nil
    
    var body: some View {
        PhoneNavigationView {
            List {
                Section {
                    ForEach(places) { placeElement in
                        Button {
                            place = placeElement
                            dismiss()
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
                        dismiss()
                    } label: {
                        HStack {
                            Text(L10n.PlacesList.noPlaceAssigned.localized)
                            Spacer()
                            if place == nil {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                if !UIDevice.current.isPhone {
                    // iPad and Mac do not have navigation bar visible
                    Section {
                        Button {
                            shouldAddNew = true
                        } label: {
                            HStack {
                                Text(L10n.PlacesList.addNewPlaceButton.localized)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                    }
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
                            .contains(keyPath: keyPath, text: text)
                    })
                }
            }
            .navigationTitle(itemTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                             L10n.PlacesList.listTitle.localized :
                             L10n.PlacesList.placeForItem.localized(with: itemTitle)
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text(L10n.Common.buttonCancel.localized)
                    }
                    .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        shouldAddNew = true
                    } label: {
                        Label(L10n.PlacesList.addPlaceButton.localized, systemImage: "plus")
                            .contentShape(Rectangle())
                            .frame(height: 96, alignment: .trailing)
                    }
                }
            }
            .sheet(isPresented: $shouldAddNew) {
                NewPlaceView(createdPlace: $createdPlace)
            }

        }
    }
}
