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

struct RecentChechlistsWidget: Widget {
    let kind: String = "RecentChechlistsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RecentChecklistsProvider()) { entry in
            StuffWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName(L10n.RecentChecklists.widgetTitle.localized)
        .description(L10n.RecentChecklists.widgetDescription.localized)
    }
}

struct StuffWidget_Previews: PreviewProvider {
    static var previews: some View {
        StuffWidgetEntryView(entry: RecentChecklistsEntry(date: .now, totalChecklists: 5))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}