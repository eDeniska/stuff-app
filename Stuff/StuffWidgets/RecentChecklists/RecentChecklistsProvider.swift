//
//  RecentChecklistsProvider.swift
//  StuffWidgetsExtension
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import Foundation
import DataModel
import WidgetKit

struct RecentChecklistsProvider: TimelineProvider {

    private let context = PersistenceController.shared.container.viewContext

    private enum Constants {
        static let timelineRefreshInterval: TimeInterval = 60.0 * 60.0
    }

    func placeholder(in context: Context) -> RecentChecklistsEntry {
        RecentChecklistsEntry(date: .now, totalChecklists: 0, isPlaceholder: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (RecentChecklistsEntry) -> ()) {
        completion(entry(widgetFamily: context.family))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RecentChecklistsEntry>) -> ()) {
        let timeline = Timeline(entries: [entry(widgetFamily: context.family)],
                                policy: .after(.now.addingTimeInterval(Constants.timelineRefreshInterval)))
        completion(timeline)
    }
}

// MARK: - Data fetching routines
extension RecentChecklistsProvider {
    func entry(widgetFamily: WidgetFamily) -> RecentChecklistsEntry {
        let recent = Checklist.recentChecklists(limit: 3, in: context)
            .prefix(widgetFamily  == .systemLarge ? 9 : 3)
            .map { checklist in
                ChecklistRow(identifier: checklist.identifier,
                             title: checklist.title,
                             icon: checklist.icon ?? "list.bullet.rectangle",
                             entries: checklist.entries.count,
                             url: WidgetURLHandler.url(for: checklist)
                )
            }

        return RecentChecklistsEntry(date: .now,
                                     rows: recent,
                                     totalChecklists: Checklist.count(in: context))
    }
}

