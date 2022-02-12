//
//  ChecklistEntryView.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import CoreData
import DataModel
import Localization

struct ChecklistEntryView: View {
    @ObservedObject private var entry: ChecklistEntry

    @State private var isChecked: Bool
    @State private var itemDetailsPresented = false

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
                    Text(entry.item?.title ?? entry.title)
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
        .contextMenu {
            if entry.item != nil {
                Button {
                    itemDetailsPresented = true
                } label: {
                    Label(L10n.ChecklistDetails.itemDetailsButton.localized, systemImage: "tag")
                }
            }
            if isChecked {
                Button {
                    isChecked.toggle()
                } label: {
                    Label(L10n.ChecklistDetails.markAsUnchecked.localized, systemImage: "circle")
                }
            } else {
                Button {
                    isChecked.toggle()
                } label: {
                    Label(L10n.ChecklistDetails.markAsChecked.localized, systemImage: "checkmark.circle")
                }
            }
        }
        .sheet(isPresented: $itemDetailsPresented) {
            if let item = entry.item {
                NavigationView {
                    ItemDetailsView(item: item, hasDismissButton: true)
                }
            }
        }
        .onChange(of: entry.isChecked) { newValue in
            isChecked = newValue
        }
        .onChange(of: isChecked) { newValue in
            entry.isChecked = newValue
            entry.updateSortOrder()
            entry.managedObjectContext?.saveOrRollback()
        }
        // TODO: verify mark checked/unchecked as leading swipe action
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                isChecked.toggle()
            } label: {
                if isChecked {
                    Label(L10n.ChecklistDetails.markAsUnchecked.localized, systemImage: "circle")
                } else {
                    Label(L10n.ChecklistDetails.markAsChecked.localized, systemImage: "checkmark.circle")
                }
            }
            .tint(.blue)
        }
    }
}
