//
//  UserActivityRegistry.swift
//  
//
//  Created by Danis Tazetdinov on 17.02.2022.
//

import Foundation

public protocol UserActivityDefinition {
    static var activityType: String { get }
}

public enum UserActivityRegistry {

    public enum ItemsView: UserActivityDefinition {
        public static let activityType = "com.tazetdinov.stuff.items.view"
    }

    public enum PlacesView: UserActivityDefinition {
        public static let activityType = "com.tazetdinov.stuff.places.view"
    }

    public enum ChecklistsView: UserActivityDefinition {
        public static let activityType = "com.tazetdinov.stuff.checklists.view"
    }

    public enum ItemView: UserActivityDefinition {
        public static let activityType = "com.tazetdinov.stuff.item.view"
        public static let identifierKey = "itemID"
    }

    public enum PlaceView: UserActivityDefinition {
        public static let activityType = "com.tazetdinov.stuff.place.view"
        public static let identifierKey = "placeID"
    }

    public enum ChecklistView: UserActivityDefinition {
        public static let activityType = "com.tazetdinov.stuff.checklist.view"
        public static let identifierKey = "itemID"
    }

    public enum ChecklistScene: UserActivityDefinition {
        public static let identifierKey = "checklistID"
        public static let activityType = "com.tazetdinov.stuff.checklist.scene"
    }

    public enum PlaceScene: UserActivityDefinition {
        public static let identifierKey = "placeID"
        public static let activityType = "com.tazetdinov.stuff.place.scene"
    }

    public enum ItemScene: UserActivityDefinition {
        public static let identifierKey = "itemID"
        public static let activityType = "com.tazetdinov.stuff.item.scene"
    }

    public enum SettingsView: UserActivityDefinition {
        public static let activityType = "com.tazetdinov.stuff.settings.view"
    }

    public enum SettingsScene: UserActivityDefinition {
        public static let activityType = "com.tazetdinov.stuff.settings.scene"
    }

}
