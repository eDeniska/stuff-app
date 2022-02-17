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
                Label(L10n.ChecklistsList.addItemsButton.localized, systemImage: "text.badge.plus")
            }
            .disabled(itemsUnavailable)
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(L10n.Common.buttonDeleteEllipsis.localized, systemImage: "trash")
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(L10n.Common.buttonDeleteEllipsis.localized, systemImage: "trash")
            }
            Button {
                showItemAssignment = true
            } label: {
                Label(L10n.ChecklistsList.addItemsButton.localized, systemImage: "text.badge.plus")
            }
            .tint(.indigo)
            .disabled(itemsUnavailable)
        }
        .confirmationDialog(L10n.ChecklistsList.shouldDeleteChecklist.localized(with: checklist.title), isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(role: .destructive) {
                viewContext.delete(checklist)
                viewContext.saveOrRollback()
            } label: {
                Text(L10n.Common.buttonDelete.localized)
            }
            .keyboardShortcut(.defaultAction)
            Button(role: .cancel) {
            } label: {
                Text(L10n.Common.buttonCancel.localized)
            }
            .keyboardShortcut(.cancelAction)
        }
        .sheet(isPresented: $showItemAssignment) {
            ChecklistItemsAssingmentView(checklist: checklist)
        }
        .onAppear {
            itemsUnavailable = Item.isEmpty(in: viewContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: nil).receive(on: DispatchQueue.main)) { _ in
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        selectedChecklist = nil
                        shouldAddNew = true
                    } label: {
                        Label(L10n.ChecklistsList.addChecklistButton.localized, systemImage: "plus")
                    }
                }
            }
            ChecklistListWelcomeView()
        }
        .tabItem {
            Label(L10n.ChecklistsList.listTitle.localized, systemImage: "list.bullet.rectangle")
        }
    }
}
