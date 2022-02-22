//
//  ChecklistListView.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import DataModel
import CoreData
import Localization

public struct ChecklistListView: View {
    
    enum SortType: String, Hashable, Identifiable, CaseIterable {
        case byTitle
        case byEntriesCount
        case byLastModified

        var id: Self {
            self
        }
        
        var localizedTitle: String {
            switch self {
            case .byTitle:
                return L10n.ChecklistsList.Sort.byTitle.localized
            case .byEntriesCount:
                return L10n.ChecklistsList.Sort.byEntriesCount.localized
            case .byLastModified:
                return L10n.ChecklistsList.Sort.byLastModified.localized
            }
        }
    }
    
    @SceneStorage("checklistSortType") private var sortType: SortType = .byTitle

    @Binding private var selectedChecklist: Checklist?

    public init(selectedChecklist: Binding<Checklist?>) {
        _selectedChecklist = selectedChecklist
    }
    
    public var body: some View {
        ChecklistListViewInternal(selectedChecklist: $selectedChecklist, sortType: $sortType)
    }

}

struct ChecklistListViewInternal: View {
    @Environment(\.managedObjectContext) private var viewContext

    private var listsRequest: FetchRequest<Checklist>
    private var lists: FetchedResults<Checklist> { listsRequest.wrappedValue }

    @State private var searchText: String = ""
    @State private var shouldAddNew = false

    @Binding private var selectedChecklist: Checklist?
    @Binding private var sortType: ChecklistListView.SortType

    init(selectedChecklist: Binding<Checklist?>, sortType: Binding<ChecklistListView.SortType>) {
        _selectedChecklist = selectedChecklist
        _sortType = sortType
        let sortDescriptors: [NSSortDescriptor]
        switch sortType.wrappedValue {
        case .byTitle:
            sortDescriptors = [NSSortDescriptor(key: #keyPath(Checklist.title), ascending: true)]
        case .byEntriesCount:
            sortDescriptors = [NSSortDescriptor(key: #keyPath(Checklist.entriesCount), ascending: false)]
        case .byLastModified:
            sortDescriptors = [NSSortDescriptor(key: #keyPath(Checklist.lastModified), ascending: false)]
        }
        listsRequest = FetchRequest(entity: Checklist.entity(),
                                    sortDescriptors: sortDescriptors,
                                    predicate: nil,
                                    animation: .default)
    }
    
    private func updateSortType(sortType: ChecklistListView.SortType) {
        switch sortType {
        case .byTitle:
            listsRequest.wrappedValue.nsSortDescriptors = [NSSortDescriptor(key: #keyPath(Checklist.title), ascending: true)]
        case .byEntriesCount:
            listsRequest.wrappedValue.nsSortDescriptors = [NSSortDescriptor(key: #keyPath(Checklist.entriesCount), ascending: false)]
        case .byLastModified:
            listsRequest.wrappedValue.nsSortDescriptors = [NSSortDescriptor(key: #keyPath(Checklist.lastModified), ascending: false)]
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(lists) { list in
                    ChecklistListRow(checklist: list)
                }
                .onDelete { indexSets in
                    withAnimation {
                        indexSets.map { lists[$0] }.forEach(viewContext.delete)
                        viewContext.saveOrRollback()
                    }
                }
            }
            .background {
                NavigationLink(isActive: Binding { selectedChecklist != nil } set: {
                    if !$0 { selectedChecklist = nil }
                }) {
                    if let selectedChecklist = selectedChecklist {
                        ChecklistEntryListView(checklist: selectedChecklist)
                    }
                } label: {
                    EmptyView()
                }
                .hidden()
            }
            .sheet(isPresented: $shouldAddNew) {
                NewChecklistView(createdChecklist: $selectedChecklist)
                    .onDisappear {
                        shouldAddNew = false
                    }
            }
            .onChange(of: searchText) { newValue in
                let text = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if text.isEmpty {
                    lists.nsPredicate = nil
                } else {
                    lists.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                        .contains(keyPath: #keyPath(Checklist.title), text: text),
                        .anyContains(keyPath: #keyPath(Checklist.entries.title), text: text),
                        .anyContains(keyPath: #keyPath(Checklist.entries.item.title), text: text),
                        .anyContains(keyPath: #keyPath(Checklist.entries.item.details), text: text),
                        .anyContains(keyPath: #keyPath(Checklist.entries.item.place.title), text: text),
                        .anyContains(keyPath: #keyPath(Checklist.entries.item.category.title), text: text),
                    ])
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .newChecklistRequest, object: nil).receive(on: DispatchQueue.main)) { _ in
                selectedChecklist = nil
                shouldAddNew = true
            }
            .userActivity(UserActivityRegistry.ChecklistsView.activityType) { activity in
                activity.title = L10n.ChecklistsList.listTitle.localized
                activity.isEligibleForHandoff = true
                activity.isEligibleForPrediction = true
            }
            .searchable(text: $searchText, prompt: Text(L10n.ChecklistsList.searchPlaceholder.localized))
            .navigationTitle(L10n.ChecklistsList.listTitle.localized)
            .onChange(of: sortType) { newValue in
                updateSortType(sortType: newValue)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        selectedChecklist = nil
                        shouldAddNew = true
                    } label: {
                        Label(L10n.ChecklistsList.addChecklistButton.localized, systemImage: "plus")
                            .contentShape(Rectangle())
                            .frame(height: 96, alignment: .trailing)
                    }
                    Menu {
                        Picker(selection: $sortType) {
                            ForEach(ChecklistListView.SortType.allCases) { sort in
                                Text(sort.localizedTitle)
                                    .tag(sort)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.inline)
                    } label: {
                        Label(L10n.ChecklistsList.menu.localized, systemImage: "ellipsis.circle")
                    }
                    .menuStyle(.borderlessButton)
                }
            }
            ChecklistListWelcomeView()
        }
        .tabItem {
            Label(L10n.ChecklistsList.listTitle.localized, systemImage: "list.bullet.rectangle")
        }
    }
}
