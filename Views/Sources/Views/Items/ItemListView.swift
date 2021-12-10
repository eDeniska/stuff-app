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

                                do {
                                    try viewContext.save()
                                } catch {
                                    // Replace this implementation with code to handle the error appropriately.
                                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                    let nsError = error as NSError
                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                }
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
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .tabItem {
            Label("Items", systemImage: "menucard")
        }
    }

    @State private var lastCategory: ItemCategory?
    @State private var lastPlace: ItemPlace?

    private func category() -> ItemCategory? {
        guard (0..<5).randomElement() == 0 else {
            return lastCategory
        }
        let newItem = ItemCategory(context: viewContext)
        newItem.identifier = UUID()
        newItem.title = "\(newItem.identifier!.uuidString)"
        lastCategory = newItem
        return newItem
    }

    private func place() -> ItemPlace? {
        guard (0..<5).randomElement() == 0 else {
            return lastPlace
        }
        let newItem = ItemPlace(context: viewContext)
        newItem.identifier = UUID()
        newItem.title = "\(newItem.identifier!.uuidString)"
        lastPlace = newItem
        return newItem
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.identifier = UUID()
            newItem.title = "\(newItem.identifier!.uuidString)"
            newItem.lastModified = Date()
            newItem.category = category()
            newItem.place = place()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
