//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import DataModel
import Combine
import UIKit
import Logger

public struct ItemListElement: View {
    @ObservedObject private var item: Item
    private let displayCategory: Bool

    public init(item: Item, displayCategory: Bool = false) {
        self.item = item
        self.displayCategory = displayCategory
    }

    public var body: some View {
        HStack(alignment: .center) {
            if let image = item.thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .cornerRadius(4)
                    .padding(4)
            } else {
                Image(systemName: iconName())
                    .font(.title)
                    .frame(width: 40, height: 40)
                    .padding(4)
            }
            VStack(alignment: .leading) {
                Text(item.title ?? "Unnamed")
                    .truncationMode(.tail)
                    .lineLimit(1)
                    .font(.body)

                if let detailsLine = detailsLine() {
                    Text(detailsLine)
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func detailsLine() -> String? {
        var components: [String] = []

        if displayCategory {
            components.append(item.categoryTitle)
        }

        if let place = item.place?.title {
            components.append(place)
        }

        guard !components.isEmpty else {
            return nil
        }

        return components.joined(separator: ", ")
    }

    private func iconName() -> String {
        guard let appCategory = item.category?.appCategory, let category = AppCategory(rawValue: appCategory) else {
            return AppCategory.other.iconName
        }
        return category.iconName
    }
}

