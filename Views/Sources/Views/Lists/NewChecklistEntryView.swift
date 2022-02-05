//
//  NewChecklistEntryView.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import DataModel

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
        guard text != title.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }

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

    enum FocusedField: Hashable {
        case title
    }

    @FocusState private var focusedField: FocusedField?

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
                    TextField("Title", text: $title)
                        .focused($focusedField, equals: .title)
                        .onSubmit(submit)
                } header: {
                    Text("Title")
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
                        Text("Suggested items")
                    }
                }

                Section {
                    LazyVGrid(columns: gridItemLayout) {
                        ForEach(ChecklistIcon.allCases) { icon in
                            Button {
                                selectedIcon = icon.rawValue
                            } label: {
                                Image(systemName: icon.rawValue)
                                    .font(.title3)
                                    .padding()
                                    .frame(width: 60, height: 60, alignment: .center)
                                    .overlay(icon.rawValue == selectedIcon ? RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor) : nil)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .id(icon)
                        }
                    }
                } header: {
                    Text("Icon")
                }
            }
            .navigationTitle("Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: submit) {
                        Text("Save")
                            .bold()
                    }
                    .disabled(trimmedTitle.isEmpty)
                }
            }
            .task {
                try? await Task.sleep(nanoseconds: 590000000)
                focusedField = .title
            }
            .onChange(of: title) { newValue in
                updatePredicate(with: newValue.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }
}
