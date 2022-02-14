//
//  WidgetDataManager.swift
//  
//
//  Created by Danis Tazetdinov on 14.02.2022.
//

import Foundation
import Logger
import CoreData
#if canImport(WidgetKit)
import WidgetKit
#endif


public struct ChecklistRow: Identifiable, Hashable, Codable {
    public let identifier: UUID
    public let title: String
    public let icon: String
    public let entries: Int
    public let url: URL

    public var id: UUID {
        identifier
    }

    public init(identifier: UUID, title: String, icon: String, entries: Int, url: URL) {
        self.identifier = identifier
        self.title = title
        self.icon = icon
        self.entries = entries
        self.url = url
    }
}

public struct RecentChecklistsInfo: Codable {
    public let lastModified: Date
    public let totalChecklists: Int
    public let recentChecklists: [ChecklistRow]
}

public struct WidgetDataManager {
    private enum Constants {
        static let appGroup = "group.com.tazetdinov.stuff.widget"
        static let recentChecklistsFile = "recentChecklists.json"
    }


    private static func fileURL(name: String) -> URL {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroup) else {
            Logger.default.error("failed to get widget container")
            fatalError("failed to get widget container")
        }
        return container.appendingPathComponent(name)
    }

    private static func buildRecentChecklistsInfo(in context: NSManagedObjectContext) -> RecentChecklistsInfo {
        let total = Checklist.count(in: context)
        let recent = Checklist.recentChecklists(in: context).map { checklist in
            ChecklistRow(identifier: checklist.identifier,
                         title: checklist.title,
                         icon: checklist.icon ?? "list.bullet.rectangle",
                         entries: checklist.entries.count,
                         url: WidgetURLHandler.url(for: checklist)
                         )
        }

        return RecentChecklistsInfo(lastModified: .now, totalChecklists: total, recentChecklists: recent)
    }

    public static func storeWidgetInfo(from context: NSManagedObjectContext) {
        do {
            let recentChecklistsData = try JSONEncoder().encode(buildRecentChecklistsInfo(in: context))
            try recentChecklistsData.write(to: fileURL(name: Constants.recentChecklistsFile), options: [.atomic])
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        } catch {
            Logger.default.error("failed to save RecentChecklits widget info: \(error)")
        }
    }

    public static func recentChecklistsWidgetInfo() -> RecentChecklistsInfo? {
        do {
            let recentChecklistsData = try Data(contentsOf: fileURL(name: Constants.recentChecklistsFile))
            return try JSONDecoder().decode(RecentChecklistsInfo.self, from: recentChecklistsData)
        } catch {
            Logger.default.error("failed to load RecentChecklits widget info: \(error)")
            return nil
        }
    }
}
