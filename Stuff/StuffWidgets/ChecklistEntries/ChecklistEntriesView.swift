//
//  ChecklistEntriesView.swift
//  StuffWidgetsExtension
//
//  Created by Danis Tazetdinov on 15.02.2022.
//

import Foundation
import SwiftUI
import DataModel
import WidgetKit
import Localization

struct ChecklistEntriesView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var entry: ChecklistEntriesEntry

    @ViewBuilder
    private func item(row: ChecklistEntriesRow) -> some View {
        HStack(alignment: .center) {
            if let image = row.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .clipped()
                    .cornerRadius(4)
            } else {
                Image(systemName: row.icon)
                    .frame(width: 24, height: 24, alignment: .center)
                    .foregroundColor(Color("AccentColor"))
            }
            VStack(alignment: .leading) {
                Text(row.title)
                    .truncationMode(.tail)
                    .lineLimit(1)
            }
            Spacer()
            if widgetFamily != .systemSmall {
                Image(systemName: row.checked ? "checkmark.circle" : "circle")
                    .foregroundColor(Color("AccentColor"))
            }
        }
        .font(.footnote)
        .padding(.vertical, 4)
    }

    private func content(for details: ChecklistEntriesDetails, isPlaceholder: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                Label(details.title, systemImage: details.icon)
                    .foregroundColor(Color("AccentColor"))
                Spacer(minLength: 0)
            }
            .font(.subheadline)
            .padding([.top, .horizontal])
            .padding(.bottom, 8)
            if details.rows.isEmpty {
                Text(L10n.ChecklistEntries.noEntries.localized)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.bottom)
            } else {
                Divider()
                ForEach(details.rows) { row in
                    VStack(spacing: 0) {
                        if isPlaceholder {
                            item(row: row)
                                .redacted(reason: .placeholder)
                        } else {
                            item(row: row)
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
                        if widgetFamily == .systemSmall {
                            Text(L10n.ChecklistEntries.totalNumberOfEntries.localized(with: details.totalEntries))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } else {
                            Text(L10n.ChecklistEntries.checkedOfTotalEntries.localized(with: details.totalChecked, details.totalEntries))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
        }
        .privacySensitive()
        .widgetURL(details.url)
    }

    private func error() -> some View {
        Text(L10n.ChecklistEntries.pickChecklist.localized)
            .font(.title2)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.bottom)
    }

    var body: some View {
        switch entry.content {
        case .checklist(let details):
            content(for: details, isPlaceholder: false)

        case .placeholder(let details):
            content(for: details, isPlaceholder: true)

        case.error:
            error()
        }
    }
}

