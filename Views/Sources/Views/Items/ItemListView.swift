//
//  ItemListView.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import CoreData
import DataModel

struct ItemListRow: View {

    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: Item

    @State private var showChecklistAssignment = false
    @State private var showDeleteConfirmation = false

    @State private var checklistsUnavailable = false

    @State private var detailsOpen = false

    private func element() -> some View {
        NavigationLink(isActive: $detailsOpen) {
            ItemDetailsView(item: item)
        } label: {
            ItemListElement(item: item)
        }
        .contextMenu {
            Button {
                showChecklistAssignment = true
            } label: {
                Label("Add to checklists...", systemImage: "text.badge.plus")
            }
            .disabled(checklistsUnavailable)
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete...", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete...", systemImage: "trash")
            }
            Button {
                showChecklistAssignment = true
            } label: {
                Label("Add to checklists...", systemImage: "text.badge.plus")
            }
            .tint(.indigo)
            .disabled(checklistsUnavailable)
        }
        .confirmationDialog("Delete \(item.title)?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(role: .destructive) {
                viewContext.delete(item)
                viewContext.saveOrRollback()
            } label: {
                Text("Delete")
            }
            .keyboardShortcut(.defaultAction)
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
            .keyboardShortcut(.cancelAction)
        }
        .sheet(isPresented: $showChecklistAssignment) {
            ItemChecklistsAssignmentView(item: item)
        }
        .onAppear {
            checklistsUnavailable = Checklist.isEmpty(in: viewContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: nil)) { _ in
            checklistsUnavailable = Checklist.isEmpty(in: viewContext)
        }
    }

    var body: some View {
        // due to bug in SwifUI context menu handling, we have to re-create view each time
        if checklistsUnavailable {
            element()
        } else {
            element()
        }
    }
}

public struct ItemListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @SectionedFetchRequest(
        sectionIdentifier: \Item.categoryTitle,
        sortDescriptors: [
            SortDescriptor(\Item.category?.order, order: .reverse),
            SortDescriptor(\Item.category?.title),
            SortDescriptor(\Item.lastModified)
                         ],
        animation: .default)
    private var items: SectionedFetchResults<String, Item>

    @State private var searchText: String = ""
    @State private var showNewItemForm = false

    @Binding private var selectedItem: Item?

    public init(selectedItem: Binding<Item?>) {
        _selectedItem = selectedItem
    }

    private func title(for sectionIdentifier: SectionedFetchResults<String, Item>.Section.ID) -> String {
        sectionIdentifier.isEmpty ? "<Unnamed>" : sectionIdentifier
    }

    public var body: some View {
        NavigationView {
            List {
                ForEach(items) { section in
                    Section(header: Text(title(for: section.id))) {
                        ForEach(section) { item in
                            ItemListRow(item: item)
                        }
                        .onDelete { indexSets in
                            // this one is used by edit mode seemingly
                            withAnimation {
                                indexSets.map { section[$0] }.forEach(viewContext.delete)
                                viewContext.saveOrRollback()
                            }
                        }
                    }
                }
            }
            .background {
                NavigationLink(isActive: Binding { selectedItem != nil } set: {
                    if !$0 { selectedItem = nil }
                }) {
                    ItemDetailsView(item: selectedItem)
                } label: {
                    EmptyView()
                }
                .hidden()
            }
            .onReceive(NotificationCenter.default.publisher(for: .newItemRequest, object: nil)) { _ in
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
                        NSPredicate(format: "%K CONTAINS[cd] %@", keyPath, text)
                    })
                }
            }
            .searchable(text: $searchText, prompt: Text("Search for items..."))
            .navigationTitle("Items")
            .sheet(isPresented: $showNewItemForm) {
                NavigationView {
                    ItemDetailsView(item: $selectedItem)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        selectedItem = nil
                        showNewItemForm = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            ItemDetailsWelcomeView()
        }
        .tabItem {
            Label("Items", systemImage: "tag")
        }
        .navigationViewStyle(.columns)
    }
}
