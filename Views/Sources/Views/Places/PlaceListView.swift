//
//  PlaceListView.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import DataModel
import Combine
import CoreData
import Localization

struct PlaceListRow: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var place: ItemPlace
    @State private var showDeleteConfirmation = false
    @State private var showItemAssignment = false

    @State private var itemsUnavailable = true

    @State private var detailsOpen = false

    private func element() -> some View {
        NavigationLink(isActive: $detailsOpen) {
            PlaceDetailsView(place: place)
        } label: {
            PlaceListElement(place: place)
        }
        .contextMenu {
            Button {
                showItemAssignment = true
            } label: {
                Label(L10n.PlacesList.placeItemsButton.localized, systemImage: "text.badge.plus") // TODO: consider other icon
            }
            .disabled(itemsUnavailable)
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(L10n.Common.buttonDeleteEllipsis.localized, systemImage: "trash")
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(L10n.Common.buttonDeleteEllipsis.localized, systemImage: "trash")
            }
            Button {
                showItemAssignment = true
            } label: {
                Label(L10n.PlacesList.placeItemsButton.localized, systemImage: "text.badge.plus") // TODO: consider other icon
            }
            .tint(.indigo)
            .disabled(itemsUnavailable)
        }
        .confirmationDialog(L10n.PlacesList.shouldDeletePlace.localized(with: place.title), isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(role: .destructive) {
                viewContext.delete(place)
                viewContext.saveOrRollback()
            } label: {
                Text(L10n.Common.buttonDelete.localized)
            }
            .keyboardShortcut(.defaultAction)
            Button(role: .cancel) {
            } label: {
                Text(L10n.Common.buttonCancel.localized)
            }
            .keyboardShortcut(.cancelAction)
        }
        .sheet(isPresented: $showItemAssignment) {
            PlaceItemsAssingmentView(place: place)
        }
        .onAppear {
            itemsUnavailable = Item.isEmpty(in: viewContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: nil).receive(on: DispatchQueue.main)) { _ in
            itemsUnavailable = Item.isEmpty(in: viewContext)
        }
    }

    var body: some View {
        if itemsUnavailable {
            element()
        } else {
            element()
        }
    }
}

public struct PlaceListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\ItemPlace.title)
                         ],
        animation: .default) private var places: FetchedResults<ItemPlace>

    @State private var searchText: String = ""
    @State private var shouldAddNew = false

    @Binding private var selectedPlace: ItemPlace?

    public init(selectedPlace: Binding<ItemPlace?>) {
        _selectedPlace = selectedPlace
    }

    public var body: some View {
        NavigationView {
            List {
                ForEach(places) { place in
                    PlaceListRow(place: place)
                }
                .onDelete { indexSets in
                    withAnimation {
                        indexSets.map { places[$0] }.forEach(viewContext.delete)
                        viewContext.saveOrRollback()
                    }
                }
            }
            .background {
                NavigationLink(isActive: Binding { selectedPlace != nil } set: {
                    if !$0 { selectedPlace = nil }
                }) {
                    if let selectedPlace = selectedPlace {
                        PlaceDetailsView(place: selectedPlace)
                    }
                } label: {
                    EmptyView()
                }
                .hidden()
            }
            .sheet(isPresented: $shouldAddNew) {
                NewPlaceView(createdPlace: $selectedPlace)
            }
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
            .onReceive(NotificationCenter.default.publisher(for: .newPlaceRequest, object: nil).receive(on: DispatchQueue.main)) { _ in
                selectedPlace = nil
                shouldAddNew = true
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        selectedPlace = nil
                        shouldAddNew = true
                    } label: {
                        Label(L10n.PlacesList.addPlaceButton.localized, systemImage: "plus")
                    }
                }
            }
            PlaceDetailsWelcomeView()
        }
        .tabItem {
            Label(L10n.PlacesList.listTitle.localized, systemImage: "house")
        }
    }
}
