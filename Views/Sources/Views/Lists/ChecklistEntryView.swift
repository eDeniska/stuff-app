//
//  ChecklistEntryView.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import CoreData
import DataModel

struct ChecklistEntryView: View {
    @ObservedObject private var entry: ChecklistEntry

    @State private var isChecked: Bool

    init(entry: ChecklistEntry) {
        self.entry = entry
        _isChecked = State(wrappedValue: entry.isChecked)
    }

    var body: some View {
        Toggle(isOn: $isChecked) {
            HStack(alignment: .center) {
                if let image = entry.item?.thumbnail {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .cornerRadius(4)
                } else {
                    Image(systemName: entry.icon ?? "list.bullet")
                        .frame(width: 40, height: 40, alignment: .center)
                }
                VStack(alignment: .leading) {
                    Text(entry.item?.title ?? entry.title ?? "Unnamed")
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .font(.body)
                    if let place = entry.item?.place?.title {
                        Text(place)
                            .truncationMode(.tail)
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
        }
        .toggleStyle(ChecklistToggleStyle())
        .onChange(of: entry.isChecked) { newValue in
            isChecked = newValue
        }
        .onChange(of: isChecked) { newValue in
            entry.isChecked = newValue
            entry.updateSortOrder()
            entry.managedObjectContext?.saveOrRollback()
        }
    }
}
