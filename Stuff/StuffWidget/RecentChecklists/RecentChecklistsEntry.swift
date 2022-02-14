//
//  RecentChecklistsEntry.swift
//  StuffWidgetExtension
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import Foundation
import WidgetKit
import DataModel

struct RecentChecklistsEntry: TimelineEntry {
    let date: Date
    let rows: [ChecklistRow]
    let totalChecklists: Int
    let isPlaceholder: Bool
    let needsSync: Bool
    
    init(date: Date = .now, rows: [ChecklistRow] = [], totalChecklists: Int, isPlaceholder: Bool = false, needsSync: Bool = false) {
        if isPlaceholder {
            self.rows = [
                ChecklistRow(identifier: UUID(),
                             title: "Sample checklist entry",
                             icon: "list.bullet.rectangle",
                             entries: 5,
                             url: WidgetURLHandler.createChecklistURL()),
                ChecklistRow(identifier: UUID(),
                             title: "Sample checklist",
                             icon: "list.bullet.rectangle",
                             entries: 5,
                             url: WidgetURLHandler.createChecklistURL()),
                ChecklistRow(identifier: UUID(),
                             title: "Sample checklist row",
                             icon: "list.bullet.rectangle",
                             entries: 5,
                             url: WidgetURLHandler.createChecklistURL())
            ]
        } else {
            self.rows = rows
        }
        self.date = date
        self.totalChecklists = totalChecklists
        self.isPlaceholder = isPlaceholder
        self.needsSync = needsSync
    }
}

