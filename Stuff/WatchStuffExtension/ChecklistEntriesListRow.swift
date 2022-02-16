//
//  ChecklistEntriesListRow.swift
//  WatchStuffExtension
//
//  Created by Danis Tazetdinov on 16.02.2022.
//

import Foundation
import SwiftUI
import DataModel
import Localization

struct ChecklistEntriesListRow: View {
    @ObservedObject private var entry: ChecklistEntry

    @State private var isChecked: Bool

    init(entry: ChecklistEntry) {
        self.entry = entry
        _isChecked = State(wrappedValue: entry.isChecked)
    }

    var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            HStack(alignment: .center) {
                if let image = entry.item?.thumbnail {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 32, height: 32)
                        .cornerRadius(4)
                } else {
                    Image(systemName: entry.icon ?? "list.bullet")
                        .font(.body)
                        .frame(width: 32, height: 32, alignment: .center)
                        .foregroundColor(.accentColor)
                }
                VStack(alignment: .leading) {
                    HStack {
                    Text(entry.item?.title ?? entry.title)
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .font(.body)
                        Spacer()
                    }
                    if let place = entry.item?.place?.title {
                        Text(place)
                            .truncationMode(.tail)
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(idealWidth: .infinity, maxWidth: .infinity)
                Image(systemName: isChecked ? "checkmark.circle" : "circle")
                    .resizable()
                    .frame(width: 22, height: 22)
            }
        }
        .onChange(of: entry.isChecked) { newValue in
            isChecked = newValue
        }
        .onChange(of: isChecked) { newValue in
            entry.checklist?.lastModified = .now
            entry.isChecked = newValue
            entry.updateSortOrder()
            entry.managedObjectContext?.saveOrRollback()
        }
    }
}
