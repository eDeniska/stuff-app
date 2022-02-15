//
//  ChecklistEntriesProvider.swift
//  StuffWidgetExtension
//
//  Created by Danis Tazetdinov on 15.02.2022.
//

import Foundation
import WidgetKit
import DataModel
import Intents
import Logger

struct ChecklistEntriesProvider: IntentTimelineProvider {

    private let context = PersistenceController.shared.container.viewContext

    private enum Constants {
        static let timelineRefreshInterval: TimeInterval = 15.0 * 60.0
    }

    func placeholder(in context: Context) -> ChecklistEntriesEntry {
        ChecklistEntriesEntry(date: .now, content: .placeholder(ChecklistEntriesDetails()))
    }

    func getSnapshot(for configuration: ChecklistEntriesConfigurationIntent, in context: Context, completion: @escaping (ChecklistEntriesEntry) -> Void) {
        Logger.default.info("[WIDGET] snapshot for \(String(describing: configuration.checklist?.identifier))")
        guard let identifierString = configuration.checklist?.identifier,
              let identifier = UUID(uuidString: identifierString) else {
                  Logger.default.info("[WIDGET] could not build identifier")
                  completion(ChecklistEntriesEntry(date: .now, content: .error))
                  return
              }
        completion(entry(for: identifier, widgetFamily: context.family, skipChecked: configuration.hideChecked?.boolValue ?? false))
    }

    func getTimeline(for configuration: ChecklistEntriesConfigurationIntent, in context: Context, completion: @escaping (Timeline<ChecklistEntriesEntry>) -> Void) {
        Logger.default.info("[WIDGET] timeline for \(String(describing: configuration.checklist?.identifier))")
        guard let identifierString = configuration.checklist?.identifier,
              let identifier = UUID(uuidString: identifierString) else {
                  Logger.default.info("[WIDGET] could not build identifier")
                  let timeline = Timeline(entries: [ChecklistEntriesEntry(date: .now, content: .error)],
                                          policy: .after(.now.addingTimeInterval(Constants.timelineRefreshInterval)))
                  completion(timeline)
                  return
              }
        let timeline = Timeline(entries: [entry(for: identifier, widgetFamily: context.family, skipChecked: configuration.hideChecked?.boolValue ?? false)],
                                policy: .after(.now.addingTimeInterval(Constants.timelineRefreshInterval)))
        completion(timeline)
    }
}

// MARK: - Data fetching routines
extension ChecklistEntriesProvider {
    func entry(for identifier: UUID, widgetFamily: WidgetFamily, skipChecked: Bool) -> ChecklistEntriesEntry {
        guard let checklist = Checklist.checklist(with: identifier, in: context) else {
            Logger.default.info("[WIDGET] could not find checklist")
            return ChecklistEntriesEntry(date: .now, content: .error)
        }

        let entries = checklist.entries
            .sorted {
                if $0.isChecked && $1.isChecked {
                    return false
                } else {
                    return $0.order < $1.order
                }
            }
            .filter { skipChecked ? !$0.isChecked : true }
            .prefix(widgetFamily  == .systemLarge ? 9 : 3)
            .map { checklistEntry in
                ChecklistEntriesRow(title: checklistEntry.item?.title ?? checklistEntry.title,
                                    icon: checklistEntry.icon ?? "list.bullet.rectangle",
                                    image: checklistEntry.item?.thumbnail,
                                    checked: checklistEntry.isChecked)
            }


        let details = ChecklistEntriesDetails(title: checklist.title,
                                              icon: checklist.icon ?? "list.bullet.rectangle",
                                              rows: entries,
                                              totalChecked: checklist.entries.filter(\.isChecked).count,
                                              totalEntries: checklist.entries.count,
                                              url: WidgetURLHandler.url(for: checklist)
                                              )

        return ChecklistEntriesEntry(date: .now, content: .checklist(details))
    }
}

