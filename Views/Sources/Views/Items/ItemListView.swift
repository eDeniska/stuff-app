//
//  ItemListView.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import CoreData
import DataModel

// TODO: need proper emtpy list view for items and places

struct ItemListChecklists: View {

    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: Item

    // TODO: this request does not update automatically
    // TODO: we could display list picker as a sheet

    @State private var assignedChecklist: Checklist? = nil
    @State private var showChecklistPicker = false

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
                Label("Add to checklist...", systemImage: "text.badge.plus")
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
            ChecklistPickerView(checklist: $assignedChecklist, for: item)
        }

    }
}

struct ItemListChecklistRowView: View {
    @ObservedObject var checklist: Checklist
    @ObservedObject var item: Item

    var body: some View {
        Button {
//            itemDetails.add(to: checklist)
        } label: {
            Label(checklist.title ?? "", systemImage: checklist.icon ?? "list.bullet.rectangle")
        }
        .disabled(checklist.entries?.compactMap { ($0 as? ChecklistEntry)?.item }.contains(item) ?? false)
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
                            ItemListChecklists(item: item)
////                            .swipeActions(edge: .leading) {
////                                ItemListChecklists(item: item)
////                                    .tint(.blue) // TODO: find proper tint
////                            }
//                            .swipeActions(edge: .trailing) {
//                                Button(role: .destructive) {
//                                    viewContext.delete(item)
//                                    viewContext.saveOrRollback()
//                                } label: {
//                                    Label("Delete", systemImage: "trash")
//                                }
//    //                            Button {
//    //
//    //                            } label: {
//    //                                Label("Flag", systemImage: "flag")
//    //                            }
//    //                            .tint(Color.accentColor)
//                            }
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
        .onAppear {
            print(FileStorageManager.shared.urls(withPrefix: "S"))
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
