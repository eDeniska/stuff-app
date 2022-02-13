//
//  RecentChecklistsEntry.swift
//  StuffWidgetExtension
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import Foundation
import WidgetKit
import DataModel

struct ChecklistRow: Hashable {
    let identfier: UUID
    let title: String
    let icon: String
    let entries: Int
    let url: URL
}

extension ChecklistRow: Identifiable {
    var id: UUID {
        identfier
    }
}

struct RecentChecklistsEntry: TimelineEntry {
    let date: Date
    let rows: [ChecklistRow]
    let isPlaceholder: Bool
    
    init(date: Date = .now, rows: [ChecklistRow] = [], isPlaceholder: Bool = false) {
        if isPlaceholder {
            self.rows = [
                ChecklistRow(identfier: UUID(),
                             title: "Sample checklist entry",
                             icon: "list.bullet.rectangle",
                             entries: 5,
                             url: WidgetURLHandler.createChecklistURL()),
                ChecklistRow(identfier: UUID(),
                             title: "Sample checklist",
                             icon: "list.bullet.rectangle",
                             entries: 5,
                             url: WidgetURLHandler.createChecklistURL()),
                ChecklistRow(identfier: UUID(),
                             title: "Sample checklist row",
                             icon: "list.bullet.rectangle",
                             entries: 5,
                             url: WidgetURLHandler.createChecklistURL())
            ]
        } else {
            self.rows = rows
        }
        self.date = date
        self.isPlaceholder = isPlaceholder
    }
}

