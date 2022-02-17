//
//  L10n+StuffIntentHandlers.swift
//  StuffIntentHandlers
//
//  Created by Danis Tazetdinov on 17.02.2022.
//

import Foundation
import Localization

extension L10n {
    enum StuffIntentHandlers: String, Localizable {
        case itemIsLocatedAt = "intents.place.itemIsLocatedAt" // "Item %@ is located at %@"
        case itemIsPlacedTo = "intents.place.itemIsPlacedTo" // "Item %@ is placed to %@"
        case itemIsAlreadyInChecklist = "intents.checklist.itemIsAlreadyIn"
        case itemIsAddedToChecklist = "intents.checklist.itemIsAddedTo"
    }
}
