//
//  ItemListView.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import CoreData
import DataModel

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

    public var body: some View {
        NavigationView {
            List {
                ForEach(items) { section in
                    Section(header: Text(title(for: section.id))) {
                        ForEach(section) { item in
                            NavigationLink {
                                ItemDetailsView(item: item)
                            } label: {
                                ItemListElement(item: item)
                            }
                        }
                        .onDelete { indexSets in
                            withAnimation {
                                indexSets.map { section[$0] }.forEach(viewContext.delete)
                                viewContext.saveOrRollback()
                            }

                        }
                    }
                }
            }
            .onChange(of: searchText) { newValue in
                if newValue.isEmpty {
                    items.nsPredicate = nil

                } else {
                    let titlePredicate = NSPredicate(format: "title contains[cd] %@", newValue)
                    let detailsPredicate = NSPredicate(format: "details contains[cd] %@", newValue)
                    let categoryPredicate = NSPredicate(format: "category.title contains[cd] %@", newValue)
                    let placePredicate = NSPredicate(format: "place.title contains[cd] %@", newValue)

                    items.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, detailsPredicate, categoryPredicate, placePredicate])
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
            Label("Items", systemImage: "menucard")
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
