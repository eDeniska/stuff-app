//
//  PlaceListElement.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import DataModel

struct PlaceListElement: View {
    private let place: ItemPlace

    public init(place: ItemPlace) {
        self.place = place
    }

    public var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "building")
            VStack(alignment: .leading) {
                Text(place.title ?? "Unnamed")
                    .truncationMode(.tail)
                    .lineLimit(1)
                    .font(.subheadline)
                if let count = place.items?.count, count > 0 {
                    Text("\(count) item(s)")
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
