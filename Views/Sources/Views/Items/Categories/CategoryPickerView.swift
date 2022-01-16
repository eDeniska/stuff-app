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

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\ItemCategory.title)
                         ],
        predicate: NSPredicate(format: "\(#keyPath(ItemCategory.appCategory)) == nil"),
        animation: .default) private var customCategories: FetchedResults<ItemCategory>

    @State private var text: String = ""

    public var body: some View {
        Section {
            TextField("Category", text: $text)
            ForEach(customCategories) { customCategory in
                Button {
                    category = .custom(customCategory.title ?? "")
                } label: {
                    HStack {
                        Text(customCategory.title ?? "")
                        Spacer()
                        if case let .custom(categoryTitle) = category, categoryTitle == customCategory.title {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            ForEach(AppCategory.allCases) { appCategory in
                Button {
                    category = .predefined(appCategory)
                } label: {
                    HStack {
                        Label(appCategory.rawValue, systemImage: appCategory.iconName)
                        Spacer()
                        if case let .predefined(selectedCategory) = category, appCategory == selectedCategory {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Category")
        }
        .onChange(of: text) { [text] newValue in
            let newTitle = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard newTitle != text else {
                return
            }
            category = .custom(newTitle)
        }
        .onChange(of: category) { newValue in
            text = newValue.title
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


