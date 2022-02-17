//
//  PlaceItemIntentHandler.swift
//  StuffIntentHandlers
//
//  Created by Danis Tazetdinov on 17.02.2022.
//

import Foundation
import Intents
import DataModel
import Localization
import Logger

// TODO: add user activity to get back to proper place of the app

class PlaceItemIntentHandler: NSObject, PlaceItemIntentHandling {

    private let context = PersistenceController.shared.container.viewContext

    func handle(intent: PlaceItemIntent) async -> PlaceItemIntentResponse {
        guard let itemIdentifierString = intent.item?.identifier,
              let itemIdentifier = UUID(uuidString: itemIdentifierString),
              let item = Item.item(with: itemIdentifier, in: context),
              let placeIdentifierString = intent.place?.identifier,
              let placeIdentifier = UUID(uuidString: placeIdentifierString),
              let place = ItemPlace.place(with: placeIdentifier, in: context)
        else {
            return PlaceItemIntentResponse(code: .failure, userActivity: nil)
        }
        do {
            item.place = place
            try context.save()
            return .success(result: L10n.StuffIntentHandlers.itemIsPlacedTo.localized(with: item.title, place.title))
        } catch {
            Logger.default.error("cannot place item: \(error)")
            return PlaceItemIntentResponse(code: .failure, userActivity: nil)
        }
    }

    func resolveItem(for intent: PlaceItemIntent) async -> PickedItemResolutionResult {
        if let item = intent.item {
            return .success(with: item)
        } else {
            return .needsValue()
        }
    }

    func resolvePlace(for intent: PlaceItemIntent) async -> PickedPlaceResolutionResult {
        if let place = intent.place {
            return .success(with: place)
        } else {
            return .needsValue()
        }
    }

    func provideItemOptionsCollection(for intent: PlaceItemIntent) async throws -> INObjectCollection<PickedItem> {
        INObjectCollection(items: Item.all(in: context).map { PickedItem(identifier: $0.identifier.uuidString, display: $0.title) })
    }

    func providePlaceOptionsCollection(for intent: PlaceItemIntent) async throws -> INObjectCollection<PickedPlace> {
        INObjectCollection(items: ItemPlace.all(in: context).map { PickedPlace(identifier: $0.identifier.uuidString, display: $0.title) })
    }

    
}
