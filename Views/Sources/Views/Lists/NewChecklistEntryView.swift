//
//  NewChecklistEntryView.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import DataModel
import Localization

// TODO: add option to edit entry info?..

public struct NewChecklistEntryView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @ObservedObject private var checklist: Checklist

    private var items: FetchedResults<Item> { itemsRequest.wrappedValue }
    private var itemsRequest: FetchRequest<Item>

    @State private var title: String = ""
    @State private var selectedIcon: String? = nil
    private let gridItemLayout = [GridItem(.adaptive(minimum: 80))]

    init(checklist: Checklist) {
        self.checklist = checklist
        itemsRequest = FetchRequest(entity: Item.entity(),
                                    sortDescriptors: [NSSortDescriptor(key: #keyPath(Item.title), ascending: true)],
                                    predicate: Self.excludePredicate(checklist: checklist),
                                    animation: .default)
    }

    private static func excludePredicate(checklist: Checklist) -> NSPredicate {
        NSPredicate(format: "SUBQUERY(\(#keyPath(Item.checklistEntries)), $e, $e.\(#keyPath(ChecklistEntry.checklist)) == %@).@count == 0", checklist)
    }

    private func updatePredicate(with text: String) {
        if text.isEmpty {
            items.nsPredicate = Self.excludePredicate(checklist: checklist)
        } else {
            let searchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:
                                                        [#keyPath(Item.title),
                                                         #keyPath(Item.details),
                                                         #keyPath(Item.place.title),
                                                         #keyPath(Item.category.title)].map { keyPath in
                NSPredicate(format: "%K CONTAINS[cd] %@", keyPath, text)
            })
            items.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [searchPredicate, Self.excludePredicate(checklist: checklist)])
        }
    }

    private func save(item: Item) {
        item.add(to: checklist)
        viewContext.refresh(checklist, mergeChanges: true)
        viewContext.saveOrRollback()
    }

    private func save(title: String) {
        let entry = ChecklistEntry(context: viewContext)
        entry.checklist = checklist
        entry.title = title
        entry.icon = selectedIcon ?? checklist.icon
        entry.updateSortOrder()
        viewContext.refresh(checklist, mergeChanges: true)
        viewContext.saveOrRollback()
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submit() {
        guard !trimmedTitle.isEmpty else {
            return
        }
        save(title: trimmedTitle)
        presentationMode.wrappedValue.dismiss()
    }

    public var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(L10n.NewChecklistEnty.titlePlaceholder.localized, text: $title)
                        .onSubmit(submit)
                } header: {
                    Text(L10n.NewChecklistEnty.titleSectionTitle.localized)
                }

                if !items.isEmpty {
                    Section {
                        ForEach(items) { item in
                            Button {
                                save(item: item)
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                ItemListElement(item: item, displayCategory: true)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text(L10n.NewChecklistEnty.suggestedItemsSectionTitle.localized)
                    }
                }

                Section {
                    LazyVGrid(columns: gridItemLayout) {
                        ForEach(AppCategory.allCases) { category in
                            Button {
                                selectedIcon = category.iconName
                            } label: {
                                Image(systemName: category.iconName)
                                    .font(.title3)
                                    .padding()
                                    .frame(width: 60, height: 60, alignment: .center)
                                    .overlay(category.iconName == selectedIcon ? RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor) : nil)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .id(category)
                        }
                    }
                } header: {
                    Text(L10n.NewChecklistEnty.customIcon.localized)
                }
            }
            .navigationTitle(L10n.NewChecklistEnty.title.localized)
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
                    Button(action: submit) {
                        Text(L10n.Common.buttonSave.localized)
                            .bold()
                    }
                    .keyboardShortcut("S", modifiers: [.command])
                    .disabled(trimmedTitle.isEmpty)
                }
            }
            .onChange(of: title) { newValue in
                updatePredicate(with: newValue.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }
}
