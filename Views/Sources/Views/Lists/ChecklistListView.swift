//
//  ChecklistListView.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import DataModel
import CoreData

struct ChecklistListRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var checklist: Checklist

    @State private var showDeleteConfirmation = false
    @State private var showItemAssignment = false

    @State private var itemsUnavailable = false

    @State private var detailsOpen = false

    private func element() -> some View {
        NavigationLink(isActive: $detailsOpen) {
            ChecklistEntryListView(checklist: checklist)
        } label: {
            ChecklistListElement(checklist: checklist)
        }
        .contextMenu {
            Button {
                showItemAssignment = true
            } label: {
                Label("Add items...", systemImage: "text.badge.plus")
            }
            .disabled(itemsUnavailable)
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete...", systemImage: "trash")
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete...", systemImage: "trash")
            }
            Button {
                showItemAssignment = true
            } label: {
                Label("Add items...", systemImage: "text.badge.plus")
            }
            .tint(.indigo)
            .disabled(itemsUnavailable)
        }
        .confirmationDialog("Delete \(checklist.title)?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(role: .destructive) {
                viewContext.delete(checklist)
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
        .sheet(isPresented: $showItemAssignment) {
            ChecklistItemsAssingmentView(checklist: checklist)
        }
        .onAppear {
            itemsUnavailable = Item.isEmpty(in: viewContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: nil)) { _ in
            itemsUnavailable = Item.isEmpty(in: viewContext)
        }
        .onChange(of: checklist) { newValue in
            if checklist.isFault || checklist.isDeleted {
                detailsOpen = false
            }
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

public struct ChecklistListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\Checklist.title)
                         ],
        animation: .default)
    private var lists: FetchedResults<Checklist>

    @State private var searchText: String = ""
    @State private var shouldAddNew = false

    @Binding private var selectedChecklist: Checklist?

    public init(selectedChecklist: Binding<Checklist?>) {
        _selectedChecklist = selectedChecklist
    }

    public var body: some View {
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
                        NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Checklist.title), text),
                        NSPredicate(format: "ANY %K CONTAINS[cd] %@", #keyPath(Checklist.entries.title), text),
                        NSPredicate(format: "ANY %K CONTAINS[cd] %@", #keyPath(Checklist.entries.item.title), text),
                        NSPredicate(format: "ANY %K CONTAINS[cd] %@", #keyPath(Checklist.entries.item.details), text),
                        NSPredicate(format: "ANY %K CONTAINS[cd] %@", #keyPath(Checklist.entries.item.place.title), text),
                        NSPredicate(format: "ANY %K CONTAINS[cd] %@", #keyPath(Checklist.entries.item.category.title), text),
                    ])
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .newChecklistRequest, object: nil)) { _ in
                selectedChecklist = nil
                shouldAddNew = true
            }
            .searchable(text: $searchText, prompt: Text("Search for checklists..."))
            .navigationTitle("Checklists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        selectedChecklist = nil
                        shouldAddNew = true
                    } label: {
                        Label("Add Checklist", systemImage: "plus")
                    }
                }
            }
            ChecklistListWelcomeView()
        }
        .tabItem {
            Label("Checklists", systemImage: "list.bullet.rectangle")
        }
    }
}
