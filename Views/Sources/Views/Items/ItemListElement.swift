//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import DataModel

public struct ItemListElement: View {
    private let item: Item

    public init(item: Item) {
        self.item = item
    }

    public var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "cup.and.saucer")
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
}
