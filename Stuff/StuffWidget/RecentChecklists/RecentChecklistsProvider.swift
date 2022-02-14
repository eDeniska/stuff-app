//
//  RecentChecklistsProvider.swift
//  Stuff
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import Foundation
import DataModel
import WidgetKit

struct RecentChecklistsProvider: TimelineProvider {
    private enum Constants {
        static let timelineRefreshInterval: TimeInterval = 15.0 * 60.0
    }

    func placeholder(in context: Context) -> RecentChecklistsEntry {
        RecentChecklistsEntry(date: .now, totalChecklists: 0, isPlaceholder: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (RecentChecklistsEntry) -> ()) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RecentChecklistsEntry>) -> ()) {
        let timeline = Timeline(entries: [entry()],
                                policy: .after(.now.addingTimeInterval(Constants.timelineRefreshInterval)))
        completion(timeline)
    }
}

// MARK: - Data fetching routines
extension RecentChecklistsProvider {
    func entry() -> RecentChecklistsEntry {

        guard let info = WidgetDataManager.recentChecklistsWidgetInfo() else {
            return RecentChecklistsEntry(totalChecklists: 0, needsSync: true)
        }
        return RecentChecklistsEntry(date: info.lastModified,
                                     rows: Array(info.recentChecklists.prefix(3)),
                                     totalChecklists: info.totalChecklists
        )
    }
}

