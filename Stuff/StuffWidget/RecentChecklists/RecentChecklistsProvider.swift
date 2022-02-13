//
//  RecentChecklistsProvider.swift
//  Stuff
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import Foundation
import DataModel
import WidgetKit
import CoreData

struct RecentChecklistsProvider: TimelineProvider {
    private enum Constants {
        static let timelineRefreshInterval: TimeInterval = 15.0 * 60.0
    }
    let container = PersistenceController.shared.container
    
    func placeholder(in context: Context) -> RecentChecklistsEntry {
        RecentChecklistsEntry(date: Date())
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
        let recentRows = Checklist.recentChecklists(in: container.viewContext).map { checklist in
            ChecklistRow(identfier: checklist.identifier,
                         title: checklist.title,
                         icon: checklist.icon ?? "list.bullet.rectangle",
                         entries: checklist.entries.count,
                         url: WidgetURLHandler.url(for: checklist)
            )
        }
        return RecentChecklistsEntry(date: .now, rows: recentRows)
    }
}

