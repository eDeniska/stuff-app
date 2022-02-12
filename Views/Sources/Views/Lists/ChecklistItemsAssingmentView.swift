//
//  ChecklistItemsAssingmentView.swift
//  
//
//  Created by Danis Tazetdinov on 07.02.2022.
//

import SwiftUI
import DataModel
import Combine
import CoreData
import Localization

struct ChecklistItemsAssingmentView: View {

    @ObservedObject private var checklist: Checklist

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @SectionedFetchRequest(
        sectionIdentifier: \Item.categoryTitle,
        sortDescriptors: [
            SortDescriptor(\Item.category?.order, order: .reverse),
            SortDescriptor(\Item.category?.title),
            SortDescriptor(\Item.lastModified)
                         ],
        animation: .default)
    private var items: SectionedFetchResults<String, Item>

    @State private var checked: Set<Item>

    @State private var searchText: String = ""

    private func title(for sectionIdentifier: SectionedFetchResults<String, Item>.Section.ID) -> String {
        sectionIdentifier.isEmpty ? L10n.Category.unnamedCategory.localized : sectionIdentifier
    }

    init(checklist: Checklist) {
        self.checklist = checklist
        _checked = State(wrappedValue: Set(checklist.entries.compactMap(\.item)))
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { section in
                    Section(header: Text(title(for: section.id))) {
                        ForEach(section) { item in
                            Button {
                                if checked.contains(item) {
                                    checked.remove(item)
                                } else {
                                    checked.insert(item)
                                }
                            } label: {
                                ItemListElement(item: item, isChecked: checked.contains(item))
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
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
            .searchable(text: $searchText, prompt: Text(L10n.ChecklistsList.filterItemsPlaceholder.localized))
            .navigationTitle(L10n.ChecklistsList.assignItemsToTitle.localized(with: checklist.title))
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
                        checklist.updateItems(checked)
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
