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


public struct PlaceListView: View {

    enum SortType: String, Hashable, Identifiable, CaseIterable {
        case byTitle
        case byItemsCount

        var id: Self {
            self
        }
        
        var localizedTitle: String {
            switch self {
            case .byTitle:
                return L10n.PlacesList.Sort.byTitle.localized
            case .byItemsCount:
                return L10n.PlacesList.Sort.byItemsCount.localized
            }
        }
    }
    
    @SceneStorage("placeSortType") private var sortType: SortType = .byTitle

    @Binding private var selectedPlace: ItemPlace?

    public init(selectedPlace: Binding<ItemPlace?>) {
        _selectedPlace = selectedPlace
    }
    
    public var body: some View {
        PlaceListViewInternal(selectedPlace: $selectedPlace, sortType: $sortType)
    }
}

struct PlaceListViewInternal: View {
    @Environment(\.managedObjectContext) private var viewContext

    private var placesRequest: FetchRequest<ItemPlace>
    private var places: FetchedResults<ItemPlace> { placesRequest.wrappedValue }

    @State private var searchText: String = ""
    @State private var shouldAddNew = false

    @Binding private var selectedPlace: ItemPlace?
    @Binding private var sortType: PlaceListView.SortType


    init(selectedPlace: Binding<ItemPlace?>, sortType: Binding<PlaceListView.SortType>) {
        _selectedPlace = selectedPlace
        _sortType = sortType
        let sortDescriptors: [NSSortDescriptor]
        switch sortType.wrappedValue {
        case .byTitle:
            sortDescriptors = [NSSortDescriptor(key: #keyPath(ItemPlace.title), ascending: true)]
        case .byItemsCount:
            sortDescriptors = [NSSortDescriptor(key: #keyPath(ItemPlace.itemsCount), ascending: false)]
        }
        placesRequest = FetchRequest(entity: ItemPlace.entity(),
                                     sortDescriptors: sortDescriptors,
                                     predicate: nil,
                                     animation: .default)
    }

    private func updateSortType(sortType: PlaceListView.SortType) {
        switch sortType {
        case .byTitle:
            placesRequest.wrappedValue.nsSortDescriptors = [NSSortDescriptor(key: #keyPath(ItemPlace.title), ascending: true)]
        case .byItemsCount:
            placesRequest.wrappedValue.nsSortDescriptors = [NSSortDescriptor(key: #keyPath(ItemPlace.itemsCount), ascending: false)]
        }
    }

    var body: some View {
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
            .userActivity(UserActivityRegistry.PlacesView.activityType) { activity in
                activity.title = L10n.PlacesList.listTitle.localized
                activity.isEligibleForHandoff = true
                activity.isEligibleForPrediction = true
            }
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
            .navigationTitle(L10n.PlacesList.listTitle.localized)
            .onReceive(NotificationCenter.default.publisher(for: .newPlaceRequest, object: nil).receive(on: DispatchQueue.main)) { _ in
                selectedPlace = nil
                shouldAddNew = true
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        selectedPlace = nil
                        shouldAddNew = true
                    } label: {
                        Label(L10n.PlacesList.addPlaceButton.localized, systemImage: "plus")
                            .contentShape(Rectangle())
                            .frame(height: 96, alignment: .trailing)
                    }
                    Menu {
                        Picker(selection: $sortType) {
                            ForEach(PlaceListView.SortType.allCases) { sort in
                                Text(sort.localizedTitle)
                                    .tag(sort)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.inline)
                    } label: {
                        Label(L10n.PlacesList.menu.localized, systemImage: "ellipsis.circle")
                    }
                    .menuStyle(.borderlessButton)
                }
            }
            PlaceDetailsWelcomeView()
        }
        .tabItem {
            Label(L10n.PlacesList.listTitle.localized, systemImage: "house")
        }
    }
}
