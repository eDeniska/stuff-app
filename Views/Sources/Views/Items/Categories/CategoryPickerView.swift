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
import Localization
import ViewModels

public struct CategoryPickerView: View {

    @Binding var category: DisplayedCategory
    let itemTitle: String

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\ItemCategory.title)
                         ],
        predicate: .isNil(keyPath: #keyPath(ItemCategory.appCategory)),
        animation: .default)
    private var customCategories: FetchedResults<ItemCategory>

    @State private var selectedIcon = AppCategory.other.iconName

    private let gridItemLayout = [GridItem(.adaptive(minimum: 80))]

    @State private var text: String = ""

    private var trimmedTitle: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func isNewCategory() -> Bool {
        guard !trimmedTitle.isEmpty else {
            return false
        }
        return !(customCategories.contains { $0.title == trimmedTitle } || AppCategory.allCases.map(\.localizedTitle).contains { $0 == trimmedTitle })
    }

    public var body: some View {
        PhoneNavigationView {
            Form {
                Section {
                    TextField(L10n.Category.sectionTitle.localized, text: $text)
                    if isNewCategory() {
                        Button {
                            // creating category object before saving context
                            category = .custom(trimmedTitle)
                            let objCategory = category.itemCategory(in: viewContext)
                            objCategory.icon = selectedIcon
                            presentationMode.wrappedValue.dismiss()
                            Logger.default.info("create new and dismiss")
                        } label: {
                            Text(L10n.Category.createCategoryNamed.localized(with: trimmedTitle))
                        }
                    }
                }
                if isNewCategory() {
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
                                .id(category.iconName)
                            }
                        }
                    } header: {
                        Text(L10n.Category.customIcon.localized)
                    }
                }
                
                Section {
                    ForEach(customCategories) { customCategory in
                        Button {
                            category = .custom(customCategory.title)
                            viewContext.saveOrRollback()
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Text(customCategory.title)
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
            .navigationTitle(itemTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                             L10n.Category.title.localized :
                             L10n.Category.categoryForItem.localized(with: itemTitle)
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text(L10n.Common.buttonCancel.localized)
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
//            .onChange(of: text) { [text] newValue in
//                let newTitle = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                guard newTitle != text else {
//                    return
//                }
////                if let appCategory = AppCategory.allCases.first(where: { $0.localizedTitle == newTitle }) {
////                    category = .predefined(appCategory)
////                } else {
////                    category = .custom(newTitle)
////                }
//            }
            .onChange(of: category) { newValue in
                if text.trimmingCharacters(in: .whitespacesAndNewlines) != newValue.title {
                    text = newValue.title
                }
            }
        }
    }
}
