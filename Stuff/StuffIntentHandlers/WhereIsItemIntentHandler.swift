//
//  File.swift
//  StuffIntentHandlers
//
//  Created by Danis Tazetdinov on 16.02.2022.
//

import Foundation
import Intents
import DataModel

class WhereIsItemIntentHandler: NSObject, WhereIsItemIntentHandling {

    private let context = PersistenceController.shared.container.viewContext

    func handle(intent: WhereIsItemIntent) async -> WhereIsItemIntentResponse {
        guard let identifierString = intent.item?.identifier,
              let identifier = UUID(uuidString: identifierString),
              let item = Item.item(with: identifier, in: context) else {
                  return WhereIsItemIntentResponse(code: .failure, userActivity: nil)
        }
        guard let place = item.place else {
            return .placeIsUnknown(itemTitle: item.title)
        }

        return .success(itemTitle: item.title, placeTitle: place.title)
    }

    func resolveItem(for intent: WhereIsItemIntent) async -> PickedItemResolutionResult {
        if let item = intent.item {
            return .success(with: item)
        } else {
            return .needsValue()
        }
    }

    func provideItemOptionsCollection(for intent: WhereIsItemIntent) async throws -> INObjectCollection<PickedItem> {
        INObjectCollection(items: Item.all(in: context).map { PickedItem(identifier: $0.identifier.uuidString, display: $0.title) })
    }
}
