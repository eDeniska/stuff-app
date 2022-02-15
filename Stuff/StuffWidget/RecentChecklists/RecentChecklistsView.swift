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


struct RecentChecklistsView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
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
                if widgetFamily != .systemSmall && row.entries > 0 {
                    Text(L10n.Common.numberOfEntries.localized(with: row.entries))
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
            }
            .font(.footnote)
            .padding(.vertical, 2)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if widgetFamily == .systemSmall {
                    Spacer(minLength: 0)
                    Text(L10n.RecentChecklists.viewTitle.localized)
                    Spacer(minLength: 0)
                } else {
                    Text(L10n.RecentChecklists.viewTitle.localized)
                    Spacer()
                    Link(destination: WidgetURLHandler.createChecklistURL()) {
                        Text(L10n.RecentChecklists.addButton.localized)
                    }
                    .foregroundColor(Color("AccentColor"))
                }
            }
            .font(.subheadline)
            .padding([.top, .horizontal])
            .padding(.bottom, 8)
            if entry.needsSync {
                Text(L10n.RecentChecklists.openAppToSync.localized)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.bottom)
            } else if entry.rows.isEmpty {
                Text(L10n.RecentChecklists.noChecklists.localized)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.bottom)
            } else {
                Divider()
                ForEach(entry.rows) { row in
                    VStack(spacing: 0) {
                        if entry.isPlaceholder {
                            link(row: row)
                                .redacted(reason: .placeholder)
                        } else {
                            link(row: row)
                        }
                        Divider()
                    }
                }
                .padding(.horizontal, widgetFamily == .systemSmall ? 8 : 12)
                .privacySensitive()
                Spacer()
                if dynamicTypeSize <= .large {
                    HStack(spacing: 0) {
                        Spacer()
                        Text(L10n.RecentChecklists.totalNumberOfChecklists.localized(with: entry.totalChecklists))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
        }
    }
}

