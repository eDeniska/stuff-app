//
//  PlaceItemsAssingmentView.swift
//  
//
//  Created by Danis Tazetdinov on 08.02.2022.
//

import SwiftUI
import DataModel
import CoreData
import Logger
import Localization

struct PlaceItemsAssingmentView: View {

    @ObservedObject private var place: ItemPlace

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

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

    init(place: ItemPlace) {
        self.place = place
        _checked = State(wrappedValue: place.items)
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
                                ItemListElement(item: item, displayPlace: false, isChecked: checked.contains(item))
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
                                                                 #keyPath(Item.category.title)].map { keyPath in
                            .contains(keyPath: keyPath, text: text)
                    })
                }
            }
            .searchable(text: $searchText, prompt:  Text(L10n.PlacesList.filterItemsPlaceholder.localized))
            .navigationTitle(L10n.PlacesList.placeItemsToTitle.localized(with: place.title))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text(L10n.Common.buttonCancel.localized)
                    }
                    .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        place.updateItems(checked)
                        viewContext.saveOrRollback()
                        dismiss()
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
