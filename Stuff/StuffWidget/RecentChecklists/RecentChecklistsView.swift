//
//  RecentChecklistsView.swift
//  Stuff
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import Foundation
import SwiftUI
import DataModel
import WidgetKit
import Localization

// TODO: show total number of checklists

struct ListLabelStyle: LabelStyle {
    @ScaledMetric var padding: CGFloat = 6

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: "rectangle")
                .hidden()
                .padding(padding)
                .overlay(
                    configuration.icon
//                        .foregroundColor(.accentColor)
                        .foregroundColor(Color("AccentColor"))
                )
            configuration.title
        }
    }
}

extension LabelStyle where Self == DefaultLabelStyle {
    static var listLabelStyle: ListLabelStyle {
        ListLabelStyle()
    }
}

struct StuffWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    var entry: RecentChecklistsEntry
    
    @ViewBuilder
    private func link(row: ChecklistRow) -> some View {
        Link(destination: row.url) {
            HStack {
                Label(row.title, systemImage: row.icon)
                    .labelStyle(.listLabelStyle)
                    .truncationMode(.tail)
                    .lineLimit(1)
                Spacer()
                if widgetFamily != .systemSmall {
                    Text(L10n.Common.numberOfEntries.localized(with: row.entries))
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .font(.headline)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(L10n.RecentChecklists.viewTitle.localized)
                if widgetFamily != .systemSmall {
                    Spacer()
                    Link(destination: WidgetURLHandler.createChecklistURL()) {
                        Text(L10n.RecentChecklists.addButton.localized)
                    }
                    .foregroundColor(Color("AccentColor"))
//                    .foregroundColor(.accentColor)
                }
            }
            .font(.title3)
            .padding()
            if entry.rows.isEmpty {
                Text(L10n.RecentChecklists.noChecklists.localized)
                    .font(.title)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.bottom)
            } else {
                ForEach(Array(entry.rows.enumerated()), id: \.1) { index, row in
                    VStack(spacing: 0) {
                        if entry.isPlaceholder {
                            link(row: row)
                                .redacted(reason: .placeholder)
                        } else {
                            link(row: row)
                        }
                        if index != entry.rows.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 8)
                Spacer()
            }
        }
    }
}

