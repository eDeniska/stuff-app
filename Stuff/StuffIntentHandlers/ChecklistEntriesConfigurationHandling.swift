//
//  ChecklistEntriesConfigurationHandling.swift
//  StuffIntentHandlers
//
//  Created by Danis Tazetdinov on 15.02.2022.
//

import Foundation
import Intents
import DataModel

class ChecklistEntriesConfigurationHandler: NSObject, ChecklistEntriesConfigurationIntentHandling {

    func resolveHideChecked(for intent: ChecklistEntriesConfigurationIntent) async -> INBooleanResolutionResult {
        .success(with: intent.hideChecked?.boolValue ?? false)
    }

    private let context = PersistenceController.shared.container.viewContext

    func resolveChecklist(for intent: ChecklistEntriesConfigurationIntent) async -> PickedChecklistResolutionResult {
        if let checklist = intent.checklist {
            return .success(with: checklist)
        } else {
            return .confirmationRequired(with: intent.checklist)
        }
    }

    func provideChecklistOptionsCollection(for intent: ChecklistEntriesConfigurationIntent) async throws -> INObjectCollection<PickedChecklist> {
        INObjectCollection(items: Checklist.all(in: context).map { PickedChecklist(identifier: $0.identifier.uuidString, display: $0.title) })
    }

}
