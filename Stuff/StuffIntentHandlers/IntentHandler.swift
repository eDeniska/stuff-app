//
//  IntentHandler.swift
//  StuffIntentHandlers
//
//  Created by Danis Tazetdinov on 15.02.2022.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        if intent is WhereIsItemIntent {
            return WhereIsItemIntentHandler()
        } else if intent is PlaceItemIntent {
            return PlaceItemIntentHandler()
        } else if intent is AddItemToChecklistIntent {
            return AddItemToChecklistIntentHandler()
        } else if intent is ChecklistEntriesConfigurationIntent {
            return ChecklistEntriesConfigurationHandler()
        }
        
        return self
    }
    
}

