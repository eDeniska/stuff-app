//
//  ItemChecklistsAssignmentView.swift
//  
//
//  Created by Danis Tazetdinov on 05.02.2022.
//

import SwiftUI
import DataModel
import CoreData
import Combine
import Localization

struct ItemChecklistsAssignmentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @FetchRequest(sortDescriptors: [SortDescriptor(\Checklist.title)],animation: .default)
    private var checklists: FetchedResults<Checklist>

    @State private var searchText: String = ""

    @ObservedObject private var item: Item

    @State private var checked: Set<Checklist>

    init(item: Item) {
        self.item = item
        _checked = State(wrappedValue: Set(Checklist.checklists(for: item)))
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(checklists) { checklistElement in
                        Button {
                            if checked.contains(checklistElement) {
                                checked.remove(checklistElement)
                            } else {
                                checked.insert(checklistElement)
                            }
                        } label: {
                            HStack {
                                ChecklistListElement(checklist: checklistElement)
                                Spacer()
                                if checked.contains(checklistElement) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        indexSet.map { checklists[$0] }.forEach(viewContext.delete)
                        viewContext.saveOrRollback()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: Text(L10n.ChecklistsList.searchPlaceholder.localized))
            .onChange(of: searchText) { newValue in
                let text = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if text.isEmpty {
                    checklists.nsPredicate = nil
                } else {
                    checklists.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                        NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Checklist.title), text),
                        NSPredicate(format: "ANY %K CONTAINS[cd] %@", #keyPath(Checklist.entries.title), text),
                        NSPredicate(format: "ANY %K CONTAINS[cd] %@", #keyPath(Checklist.entries.item.title), text),
                        NSPredicate(format: "ANY %K CONTAINS[cd] %@", #keyPath(Checklist.entries.item.details), text),
                        NSPredicate(format: "ANY %K CONTAINS[cd] %@", #keyPath(Checklist.entries.item.place.title), text),
                        NSPredicate(format: "ANY %K CONTAINS[cd] %@", #keyPath(Checklist.entries.item.category.title), text),
                    ])
                }
            }
            .navigationTitle(L10n.ItemAssignment.addItemToChecklistsTitle.localized(with: item.title))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text(L10n.Common.buttonCancel.localized)
                    }
                    .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        item.updateChecklists(checked)
                        viewContext.saveOrRollback()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text(L10n.Common.buttonSave.localized)
                            .bold()
                    }
                    .keyboardShortcut("S", modifiers: [.command])
                }
            }
        }
    }
}
