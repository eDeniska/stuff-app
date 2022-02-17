//
//  AddItemToChecklistIntentHandler.swift
//  StuffIntentHandlers
//
//  Created by Danis Tazetdinov on 17.02.2022.
//

import Foundation

import Foundation
import Intents
import DataModel
import Localization
import Logger

// TODO: add user activity to get back to proper place of the app

class AddItemToChecklistIntentHandler: NSObject, AddItemToChecklistIntentHandling {

    private let context = PersistenceController.shared.container.viewContext

    func handle(intent: AddItemToChecklistIntent) async -> AddItemToChecklistIntentResponse {
        guard let itemIdentifierString = intent.item?.identifier,
              let itemIdentifier = UUID(uuidString: itemIdentifierString),
              let item = Item.item(with: itemIdentifier, in: context),
              let checklistIdentifierString = intent.checklist?.identifier,
              let checklistIdentifier = UUID(uuidString: checklistIdentifierString),
              let checklist = Checklist.checklist(with: checklistIdentifier, in: context)
        else {
            return AddItemToChecklistIntentResponse(code: .failure, userActivity: nil)
        }
        do {
            if item.isListed(in: checklist) {
                return .alreadyInList(result: L10n.StuffIntentHandlers.itemIsAlreadyInChecklist.localized(with: item.title, checklist.title))
            } else {
                item.add(to: checklist)
            }
            try context.save()
            return .success(result: L10n.StuffIntentHandlers.itemIsAddedToChecklist.localized(with: item.title, checklist.title))
        } catch {
            Logger.default.error("cannot place item: \(error)")
            return AddItemToChecklistIntentResponse(code: .failure, userActivity: nil)
        }
    }

    func resolveItem(for intent: AddItemToChecklistIntent) async -> PickedItemResolutionResult {
        if let item = intent.item {
            return .success(with: item)
        } else {
            return .needsValue()
        }
    }

    func resolveChecklist(for intent: AddItemToChecklistIntent) async -> PickedChecklistResolutionResult {
        if let checklist = intent.checklist {
            return .success(with: checklist)
        } else {
            return .needsValue()
        }
    }

    func provideItemOptionsCollection(for intent: AddItemToChecklistIntent) async throws -> INObjectCollection<PickedItem> {
        INObjectCollection(items: Item.all(in: context).map { PickedItem(identifier: $0.identifier.uuidString, display: $0.title) })
    }

    func provideChecklistOptionsCollection(for intent: AddItemToChecklistIntent) async throws -> INObjectCollection<PickedChecklist> {
        INObjectCollection(items: Checklist.all(in: context).map { PickedChecklist(identifier: $0.identifier.uuidString, display: $0.title) })
    }

}
