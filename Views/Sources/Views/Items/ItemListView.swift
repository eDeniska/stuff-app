//
//  ItemListView.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import CoreData
import DataModel

// TODO: need proper empty list view for items and places

struct ItemListRow: View {

    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: Item

    @State private var assignedChecklist: Checklist? = nil
    @State private var showChecklistPicker = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationLink {
            ItemDetailsView(item: item)
        } label: {
            ItemListElement(item: item)
        }
        .contextMenu {
            Button {
                showChecklistPicker = true
            } label: {
                Label("Add to checklists...", systemImage: "text.badge.plus")
            }
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
                Label("Delete", systemImage: "trash")
            }
            Button {
                showChecklistPicker = true
            } label: {
                Label("Add to checklists...", systemImage: "text.badge.plus")
            }
            .tint(.indigo)
        }
        .confirmationDialog("Delete \(item.title ?? "Unnamed item")?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(role: .destructive) {
                viewContext.delete(item)
                viewContext.saveOrRollback()
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        }
        .sheet(isPresented: $showChecklistPicker) {
            if let assignedChecklist = assignedChecklist {
                // TODO: assign to item
                item.add(to: assignedChecklist)
                viewContext.saveOrRollback()
            }
            assignedChecklist = nil
        } content: {
            ChecklistAssignmentView(item: item)
        }

    }
}

public struct ItemListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @SectionedFetchRequest(
        sectionIdentifier: \Item.categoryTitle,
        sortDescriptors: [
            SortDescriptor(\Item.category?.title),
            SortDescriptor(\Item.lastModified)
                         ],
        animation: .default)
    private var items: SectionedFetchResults<String, Item>


    @State private var searchText: String = ""
    @State private var showNewItemForm = false

    public init() {
    }

    func title(for sectionIdentifier: SectionedFetchResults<String, Item>.Section.ID) -> String {
        if sectionIdentifier.isEmpty {
            return "<Unnamed>"
        } else {
            return sectionIdentifier
        }
    }

    private func availableChecklists(for item: Item, in checklists: FetchedResults<ChecklistEntry>) -> [Checklist] {
        Checklist.available(for: item)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        showNewItemForm = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            ItemDetailsWelcomeView {
                showNewItemForm = true
            }
        }
        .tabItem {
            Label("Items", systemImage: "tag")
        }
        .navigationViewStyle(.columns)
        .sheet(isPresented: $showNewItemForm) {
            NavigationView {
                ItemDetailsView(item: nil)
            }
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
