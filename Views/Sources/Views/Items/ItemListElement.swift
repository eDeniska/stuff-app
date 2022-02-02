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

    public init(item: Item) {
        self.item = item
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
                if let place = item.place?.title {
                    Text(place)
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func iconName() -> String {
        guard let appCategory = item.category?.appCategory, let category = AppCategory(rawValue: appCategory) else {
            return AppCategory.other.iconName
        }
        return category.iconName
    }
}

