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
    
    @Environment(\.managedObjectContext) private var viewContext

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
        .toggleStyle(.checklist)
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
            Button(role: .destructive) {
                entry.checklist?.lastModified = .now
                viewContext.delete(entry)
                viewContext.saveOrRollback()
            } label: {
                Label(L10n.Common.buttonDelete.localized, systemImage: "trash")
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
            entry.checklist?.lastModified = .now
            entry.isChecked = newValue
            entry.updateSortOrder()
            entry.managedObjectContext?.saveOrRollback()
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                isChecked.toggle()
            } label: {
                if isChecked {
                    Label(L10n.ChecklistDetails.markAsUnchecked.localized, systemImage: "arrow.counterclockwise.circle")
                } else {
                    Label(L10n.ChecklistDetails.markAsChecked.localized, systemImage: "checkmark.circle")
                }
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                entry.checklist?.lastModified = .now
                viewContext.delete(entry)
                viewContext.saveOrRollback()
            } label: {
                Label(L10n.Common.buttonDelete.localized, systemImage: "trash")
            }
        }
    }
}
