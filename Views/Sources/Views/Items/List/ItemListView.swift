//
//  ItemListView.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import CoreData
import DataModel
import Localization
import AVFoundation
import Intents
import Logger

public struct ItemListView: View {
    
    enum GroupingType: String, Hashable, Identifiable, CaseIterable {
        case byCategory
        case byPlace
        case byCondition
        
        var id: Self {
            self
        }
        
        var localizedTitle: String {
            switch self {
            case .byCategory:
                return L10n.ItemsList.Grouping.byCategory.localized
            case .byPlace:
                return L10n.ItemsList.Grouping.byPlace.localized
            case .byCondition:
                return L10n.ItemsList.Grouping.byCondition.localized
            }
        }
    }
    
    @SceneStorage("itemGroupingType") private var groupingType: GroupingType = .byCategory
    @Binding private var selectedItem: Item?

    public init(selectedItem: Binding<Item?>) {
        _selectedItem = selectedItem
    }

    public var body: some View {
        ItemListViewInternal(selectedItem: $selectedItem, groupingType: $groupingType)
    }
}

struct ItemListViewInternal: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var searchText: String = ""
    @State private var showNewItemForm = false
    @State private var showItemCapture = false

    @Binding private var selectedItem: Item?
    @Binding private var groupingType: ItemListView.GroupingType

    private var itemsRequest: SectionedFetchRequest<String, Item>
    private var items: SectionedFetchResults<String, Item> { itemsRequest.wrappedValue }

    init(selectedItem: Binding<Item?>, groupingType: Binding<ItemListView.GroupingType>) {
        _selectedItem = selectedItem
        _groupingType = groupingType
        switch groupingType.wrappedValue {
        case .byPlace:
            itemsRequest = SectionedFetchRequest(entity: Item.entity(),
                                                 sectionIdentifier: \Item.placeTitle,
                                                 sortDescriptors: [
                                                    NSSortDescriptor(key: #keyPath(Item.place.title), ascending: true),
                                                    NSSortDescriptor(key: #keyPath(Item.title), ascending: true)],
                                                 predicate: nil,
                                                 animation: .default)
        case .byCondition:
            itemsRequest = SectionedFetchRequest(entity: Item.entity(),
                                                 sectionIdentifier: \Item.conditionTitle,
                                                 sortDescriptors: [
                                                    NSSortDescriptor(key: #keyPath(Item.condition), ascending: false),
                                                    NSSortDescriptor(key: #keyPath(Item.title), ascending: true)],
                                                 predicate: nil,
                                                 animation: .default)
        case .byCategory:
            itemsRequest = SectionedFetchRequest(entity: Item.entity(),
                                                 sectionIdentifier: \Item.categoryTitle,
                                                 sortDescriptors: [
                                                    NSSortDescriptor(key: #keyPath(Item.category.order), ascending: false),
                                                    NSSortDescriptor(key: #keyPath(Item.category.title), ascending: true),
                                                    NSSortDescriptor(key: #keyPath(Item.title), ascending: true)],
                                                 predicate: nil,
                                                 animation: .default)
        }
    }
    
    private func switchGrouping(to grouping: ItemListView.GroupingType) {
        switch grouping {
        case .byPlace:
            itemsRequest.projectedValue.wrappedValue.sectionIdentifier = \Item.placeTitle
            itemsRequest.projectedValue.wrappedValue.nsSortDescriptors = [
                NSSortDescriptor(key: #keyPath(Item.place.title), ascending: true),
                NSSortDescriptor(key: #keyPath(Item.title), ascending: true)]
        case .byCondition:
            itemsRequest.projectedValue.wrappedValue.sectionIdentifier = \Item.conditionTitle
            itemsRequest.projectedValue.wrappedValue.nsSortDescriptors = [
                NSSortDescriptor(key: #keyPath(Item.condition), ascending: false),
                NSSortDescriptor(key: #keyPath(Item.title), ascending: true)]

        case .byCategory:
            itemsRequest.projectedValue.wrappedValue.sectionIdentifier = \Item.categoryTitle
            itemsRequest.projectedValue.wrappedValue.nsSortDescriptors = [
                NSSortDescriptor(key: #keyPath(Item.category.order), ascending: false),
                NSSortDescriptor(key: #keyPath(Item.category.title), ascending: true),
                NSSortDescriptor(key: #keyPath(Item.title), ascending: true)]
        }
    }

    private func title(for sectionIdentifier: String) -> String {
        if sectionIdentifier.isEmpty {
            switch groupingType {
            case .byPlace:
                return L10n.ItemDetails.noPlaceIsSet.localized
                
            case .byCondition:
                return L10n.ItemCondition.unknown.localized
                
            case .byCategory:
                return L10n.Category.unnamedCategory.localized
            }
        } else {
            return sectionIdentifier
        }
    }
    
    // this is workaround for section title not being updated on place title editing
    // this fix does not solve the sorting issue, items need to be re-sorted again
    // grouping needs to be togged in order to refresh the view
    private func title(for section: SectionedFetchResults<String, Item>.Element) -> String {
        switch groupingType {
        case .byPlace:
            let title = section.first?.place?.title ?? ""
            return title.isEmpty ? L10n.ItemDetails.noPlaceIsSet.localized : title
            
        case .byCondition:
            return section.id.isEmpty ? L10n.ItemCondition.unknown.localized : section.id
            
        case .byCategory:
            return section.id.isEmpty ? L10n.Category.unnamedCategory.localized : section.id
        }

    }

    private func cameraAccessDisallowed() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) != .authorized && AVCaptureDevice.authorizationStatus(for: .video) != .notDetermined
    }

    public var body: some View {
        NavigationView {
            List {
                ForEach(items) { section in
                    Section {
                        ForEach(section) { item in
                            ItemListRow(item: item,
                                        displayPlace: groupingType != .byPlace,
                                        displayCategory: groupingType != .byCategory,
                                        displayCondition: groupingType != .byCondition)
                        }
                        .onDelete { indexSets in
                            // this one is used by edit mode seemingly
                            withAnimation {
                                indexSets.map { section[$0] }.forEach {
                                    $0.removeImages()
                                    viewContext.delete($0)
                                }
                                viewContext.saveOrRollback()
                            }
                        }
                    } header: {
                        Text(title(for: section))
                    }
                }
            }
            .background {
                VStack {
                    NavigationLink(isActive: Binding { selectedItem != nil } set: { if !$0 { selectedItem = nil } }) {
                        ItemDetailsView(item: selectedItem)
                    } label: {
                        EmptyView()
                    }
                    .hidden()
                    ItemCaptureView(createdItem: $selectedItem, startItemCapture: $showItemCapture)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .newItemRequest, object: nil).receive(on: DispatchQueue.main)) { _ in
                selectedItem = nil
                showNewItemForm = true
            }
            .onChange(of: searchText) { newValue in
                let text = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if text.isEmpty {
                    items.nsPredicate = nil
                } else {
                    items.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:
                                                                [#keyPath(Item.title),
                                                                 #keyPath(Item.details),
                                                                 #keyPath(Item.place.title),
                                                                 #keyPath(Item.category.title)].map { keyPath in
                            .contains(keyPath: keyPath, text: text)
                    })
                }
            }
            .userActivity(UserActivityRegistry.ItemsView.activityType) { activity in
                activity.title = L10n.ItemsList.listTitle.localized
                activity.isEligibleForHandoff = true
                activity.isEligibleForPrediction = true
            }
            .searchable(text: $searchText, prompt: Text(L10n.ItemsList.searchPlaceholder.localized))
            .navigationTitle(L10n.ItemsList.listTitle.localized)
            .sheet(isPresented: $showNewItemForm) {
                NavigationView {
                    ItemDetailsView(item: $selectedItem)
                }
            }
            .onChange(of: groupingType) { newValue in
                switchGrouping(to: newValue)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        selectedItem = nil
                        showItemCapture = true
                    } label: {
                        Label(L10n.ItemDetails.takePhotoTitle.localized, systemImage: "camera")
                    }
                    .disabled(cameraAccessDisallowed())
                    Button {
                        itemsRequest.update()
                        selectedItem = nil
                        showNewItemForm = true
                    } label: {
                        Label(L10n.ItemsList.addItemButton.localized, systemImage: "plus")
                    }
                    Menu {
                        Picker(selection: $groupingType) {
                            ForEach(ItemListView.GroupingType.allCases) { grouping in
                                Text(grouping.localizedTitle)
                                    .tag(grouping)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.inline)
                    } label: {
                        Label(L10n.ItemsList.menu.localized, systemImage: "ellipsis.circle")
                    }
                    .menuStyle(.borderlessButton)
                }
            }
            ItemDetailsWelcomeView()
        }
        .tabItem {
            Label(L10n.ItemsList.listTitle.localized, systemImage: "tag")
        }
        .navigationViewStyle(.columns)
    }
}
