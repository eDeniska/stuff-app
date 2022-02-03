//
//  ChecklistListView.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import DataModel
import CoreData

public struct ChecklistListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\Checklist.title)
                         ],
        animation: .default) private var lists: FetchedResults<Checklist>

    @State private var searchText: String = ""
    @State private var shouldAddNew = false

    public init() {
    }

    public var body: some View {
        NavigationView {
            List {
                ForEach(lists) { list in
                    NavigationLink {
                        ChecklistEntryListView(checklist: list)
                    } label: {
                        ChecklistListElement(checklist: list)
                    }
                }
                .onDelete { indexSets in
                    withAnimation {
                        indexSets.map { lists[$0] }.forEach(viewContext.delete)
                        viewContext.saveOrRollback()
                    }
                }
            }
            .sheet(isPresented: $shouldAddNew) {
                NewChecklistView()
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
                        NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Checklist.title), text),
                        NSPredicate(format: "ANY entries.title CONTAINS[cd] %@", text),
                        NSPredicate(format: "ANY entries.item.title CONTAINS[cd] %@", text),
                        NSPredicate(format: "ANY entries.item.details CONTAINS[cd] %@", text),
                        NSPredicate(format: "ANY entries.item.place.title CONTAINS[cd] %@", text),
                        NSPredicate(format: "ANY entries.item.category.title CONTAINS[cd] %@", text),
                    ])
                }
            }
            .searchable(text: $searchText, prompt: Text("Search for checklists..."))
            .navigationTitle("Checklists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        shouldAddNew = true
                    } label: {
                        Label("Add Checklist", systemImage: "plus")
                    }
                }
            }
            PlaceDetailsWelcomeView {
                shouldAddNew = true
            }
        }
        .tabItem {
            Label("Checklists", systemImage: "list.bullet.rectangle")
        }
    }
}
