//
//  CategoryPickerView.swift
//  
//
//  Created by Danis Tazetdinov on 13.01.2022.
//

import SwiftUI
import Combine
import CoreData
import DataModel
import Logger


class CategoryDataSource: ObservableObject {
    @Published private(set) var categories: [DisplayedCategory]
    private let persistentController: PersistenceController

    init(persistentController: PersistenceController) {
        self.persistentController = persistentController
        let fetchRequest = ItemCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(ItemCategory.appCategory)) == nil")
        let customCategories = (try? persistentController.container.viewContext.fetch(fetchRequest)) ?? []

        categories = customCategories.compactMap { custom in
            guard let title = custom.title else { return nil }
            return .custom(title)
        }
        categories += AppCategory.allCases.map { .predefined($0) }
    }

}

public struct CategoryPickerView: View {

    @Binding var category: DisplayedCategory

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\ItemCategory.title)
                         ],
        predicate: NSPredicate(format: "\(#keyPath(ItemCategory.appCategory)) == nil"),
        animation: .default)
    private var customCategories: FetchedResults<ItemCategory>

    @State private var text: String = ""

    private func isNewCategory() -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return false
        }
        return !(customCategories.contains { $0.title == trimmed } || AppCategory.allCases.map(\.localizedTitle).contains { $0 == trimmed })
    }

    public var body: some View {
        PhoneNavigationView {
            Form {
                Section {
                    TextField("Category", text: $text)
                    if isNewCategory() {
                        Button {
                            // creating category object before saving context
                            _ = category.itemCategory(in: viewContext)
                            presentationMode.wrappedValue.dismiss()
                            Logger.default.info("create new and dismiss")
                        } label: {
                            Text("Create category '\(text.trimmingCharacters(in: .whitespacesAndNewlines))'")
                        }
                    }
                }
                
                Section {
                    ForEach(customCategories) { customCategory in
                        Button {
                            category = .custom(customCategory.title ?? "")
                            viewContext.saveOrRollback()
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Text(customCategory.title ?? "")
                                Spacer()
                                if case let .custom(categoryTitle) = category, categoryTitle == customCategory.title {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.map { customCategories[$0] }.forEach(viewContext.delete)
                        viewContext.saveOrRollback()
                    }
                    ForEach(AppCategory.allCases, id: \.self) { appCategory in
                        Button {
                            category = .predefined(appCategory)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Label(appCategory.localizedTitle, systemImage: appCategory.iconName)
                                Spacer()
                                if case let .predefined(selectedCategory) = category, appCategory == selectedCategory {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .onChange(of: text) { [text] newValue in
                let newTitle = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                guard newTitle != text else {
                    return
                }
                if let appCategory = AppCategory.allCases.first(where: { $0.localizedTitle == newTitle }) {
                    category = .predefined(appCategory)
                } else {
                    category = .custom(newTitle)
                }
            }
            .onChange(of: category) { newValue in
                text = newValue.title
            }
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

struct CategoryPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPickerView(category: .constant(.predefined(.other)))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


