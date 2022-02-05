//
//  ChecklistPickerView.swift
//  
//
//  Created by Danis Tazetdinov on 05.02.2022.
//

import SwiftUI
import DataModel
import CoreData
import Combine

struct ChecklistPickerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @FetchRequest(sortDescriptors: [SortDescriptor(\Checklist.title)],animation: .default)
    private var checklists: FetchedResults<Checklist>

    @State private var searchText: String = ""

    @Binding private var checklist: Checklist?
    @ObservedObject private var item: Item

    init(checklist: Binding<Checklist?>, for item: Item) {
        self._checklist = checklist
        self.item = item
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(checklists) { checklistElement in
                        Button {
                            checklist = checklistElement
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                ChecklistListElement(checklist: checklistElement)
                                Spacer()
                                if checklistElement == checklist {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .disabled(checklistElement.entries?.compactMap { ($0 as? ChecklistEntry)?.item }.contains(item) ?? false )
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        indexSet.map { checklists[$0] }.forEach(viewContext.delete)
                        viewContext.saveOrRollback()
                    }
                }
                Section {
                    Button {
                        checklist = nil
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Text("No checklist selected")
                            Spacer()
                            if checklist == nil {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .buttonStyle(.plain)
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
            .navigationTitle("Checklists")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}
