//
//  ChecklistAssignmentView.swift
//  
//
//  Created by Danis Tazetdinov on 05.02.2022.
//

import SwiftUI
import DataModel
import CoreData
import Combine

struct ChecklistAssignmentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @FetchRequest(sortDescriptors: [SortDescriptor(\Checklist.title)],animation: .default)
    private var checklists: FetchedResults<Checklist>

    @State private var searchText: String = ""

    @ObservedObject private var item: Item

    @State private var checked: Set<Checklist>

    init(item: Item) {
        self.item = item
        _checked = State(wrappedValue: Set(Checklist.checkilists(for: item)))
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
            .searchable(text: $searchText, prompt: Text("Search for checklists..."))
            .onChange(of: searchText) { newValue in
                let text = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if text.isEmpty {
                    checklists.nsPredicate = nil
                } else {
                    checklists.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                        NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Checklist.title), text),
                        NSPredicate(format: "ANY entries.title CONTAINS[cd] %@", text),
                        NSPredicate(format: "ANY entries.item.title CONTAINS[cd] %@", text),
                        NSPredicate(format: "ANY entries.item.details CONTAINS[cd] %@", text),
                        NSPredicate(format: "ANY entries.item.place.title CONTAINS[cd] %@", text),
                        NSPredicate(format: "ANY entries.item.category.title CONTAINS[cd] %@", text),
                    ])
                }
            }
            .navigationTitle("Add \(item.title ?? "Unnamed item") to checklists")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        item.updateChecklists(checked)
                        viewContext.saveOrRollback()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                            .bold()
                    }
                }
            }
        }
    }
}
