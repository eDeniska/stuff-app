//
//  StuffWidget.swift
//  StuffWidget
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import WidgetKit
import SwiftUI
import DataModel

// TODO: add widget localization

struct RecentChechlistsWidget: Widget {
    let kind: String = "RecentChechlistsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RecentChecklistsProvider()) { entry in
            StuffWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Stuff")
        .description("List of recent checklists.")
    }
}

struct StuffWidget_Previews: PreviewProvider {
    static var previews: some View {
        StuffWidgetEntryView(entry: RecentChecklistsEntry(date: .now))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
