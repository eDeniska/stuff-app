//
//  PlaceListElement.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import DataModel
import Localization
import Logger

struct PlaceListElement: View {
    @ObservedObject private var place: ItemPlace

    public init(place: ItemPlace) {
        self.place = place
    }

    public var body: some View {
        HStack(alignment: .center) {
            Image(systemName: place.icon.isEmpty ? "house" : place.icon)
                .frame(width: 40, height: 40, alignment: .center)
            VStack(alignment: .leading) {
                Text(place.title)
                    .truncationMode(.tail)
                    .lineLimit(1)
                    .font(.body)
                if let count = place.items.count, count > 0 {
                    Text(L10n.Common.numberOfItems.localized(with: count))
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
