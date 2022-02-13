//
//  RecentChecklistsEntry.swift
//  StuffWidgetExtension
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import Foundation
import WidgetKit

struct ChecklistRow {
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
    
    init(date: Date = .now, rows: [ChecklistRow] = []) {
        self.date = date
        self.rows = rows
    }
}

