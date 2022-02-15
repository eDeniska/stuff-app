//
//  StuffWidget.swift
//  StuffWidget
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import WidgetKit
import SwiftUI
import DataModel
import Localization

struct RecentChecklistsWidget: Widget {
    let kind: String = "RecentChecklistsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RecentChecklistsProvider()) { entry in
            RecentChecklistsView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName(L10n.RecentChecklists.widgetTitle.localized)
        .description(L10n.RecentChecklists.widgetDescription.localized)
    }
}
