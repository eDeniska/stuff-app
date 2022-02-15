//
//  ChecklistEntriesWidget.swift
//  StuffWidgetExtension
//
//  Created by Danis Tazetdinov on 15.02.2022.
//

import WidgetKit
import SwiftUI
import DataModel
import Localization
import Intents

struct ChecklistEntriesWidget: Widget {
    let kind: String = "ChecklistEntriesWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: ChecklistEntriesConfigurationIntent.self,
                            provider: ChecklistEntriesProvider()) { entry in
            ChecklistEntriesView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName(L10n.RecentChecklists.widgetTitle.localized)
        .description(L10n.RecentChecklists.widgetDescription.localized)
    }
}
