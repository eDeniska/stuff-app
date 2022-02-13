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

struct StuffWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    var entry: RecentChecklistsEntry

    var body: some View {
        VStack(spacing:0) {
            Text("Recent checklists")
                .font(.title2)
                .padding(.vertical, 8)
            ForEach(entry.rows) { row in
                VStack(spacing: 0) {
                    Link(destination: row.url) {
                        HStack {
                            Image(systemName: row.icon)
                                .imageScale(.large)
                                .frame(width: 16, height: 16, alignment: .center)
                                .foregroundColor(.accentColor)
                            Text(row.title)
                                .truncationMode(.tail)
                                .lineLimit(1)
                                .foregroundColor(.accentColor)
                            Spacer()
                            if widgetFamily != .systemSmall {
                                Text(L10n.Common.numberOfEntries.localized(with: row.entries))
                                    .truncationMode(.tail)
                                    .lineLimit(1)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(8)
                        .font(.headline)
                    }
                    Divider()
                }
            }
            Spacer()
        }
    }
}

