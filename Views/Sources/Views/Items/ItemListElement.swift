//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import DataModel
import Combine

public struct ItemListElement: View {
    @ObservedObject private var item: Item

    public init(item: Item) {
        self._item = ObservedObject(wrappedValue: item)
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
