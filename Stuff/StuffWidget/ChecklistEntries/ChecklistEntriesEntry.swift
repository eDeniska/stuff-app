//
//  ChecklistEntriesEntry.swift
//  StuffWidgetExtension
//
//  Created by Danis Tazetdinov on 15.02.2022.
//

import Foundation
import WidgetKit
import UIKit

struct ChecklistEntriesRow: Identifiable, Hashable {
    let title: String
    let icon: String
    let image: UIImage?
    let checked: Bool
    let id: UUID

    init(title: String, icon: String, image: UIImage?, checked: Bool) {
        self.title = title
        self.icon = icon
        self.image = image
        self.checked = checked
        id = UUID()
    }
}

enum ChecklistEntriesEntryContent {
    case checklist(ChecklistEntriesDetails)
    case error
    case placeholder(ChecklistEntriesDetails)
}

struct ChecklistEntriesDetails {
    let title: String
    let icon: String
    let rows: [ChecklistEntriesRow]
    let totalChecked: Int
    let totalEntries: Int
    let url: URL?

    init(title: String, icon: String, rows: [ChecklistEntriesRow] = [], totalChecked: Int = 0, totalEntries: Int = 0, url: URL? = nil) {
        self.title = title
        self.icon = icon
        self.rows = rows
        self.totalChecked = totalChecked
        self.totalEntries = totalEntries
        self.url = url
    }

    init() {
        title = "Sample checklist"
        icon = "list.bullet.rectangle"
        rows = [
            ChecklistEntriesRow(title: "Sample checklist entry",
                                icon: "list.bullet.rectangle",
                                image: nil,
                                checked: true),
            ChecklistEntriesRow(title: "Sample other checklist entry",
                                icon: "list.bullet.rectangle",
                                image: nil,
                                checked: false),
            ChecklistEntriesRow(title: "A checklist entry",
                                icon: "list.bullet.rectangle",
                                image: nil,
                                checked: true)
            ]
        totalChecked = 1
        totalEntries = 3
        url = nil
    }
}



struct ChecklistEntriesEntry: TimelineEntry {
    let date: Date
    let content: ChecklistEntriesEntryContent

    init(date: Date = .now, content: ChecklistEntriesEntryContent) {
        self.date = date
        self.content = content
    }
}

