//
//  StuffApp.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 07.12.2021.
//

import SwiftUI
import DataModel
import Logger
import Views

// TODO: Apple Watch app – go through checklist, use only thumbnails, if needed
// TODO: add Spotlight search support
// TODO: add option to share checklists (and items)
// TODO: add option to make reminders out of checklists

// TODO: onboarding
// TODO: add option to export and import data
// TODO: add onSubmit actions for text fields where appropriate
// TODO: Keyboard shortcuts for New Item, New Place, New Checklist and shortcuts for buttons in details view
// TODO: remap new window command to other key?..
// TODO: support undo in editing lists

// TODO: fix keyboard shortcuts not working on places and checklists tabs on Mac Catalyst

//extension Notification.Name {
//    static let itemsTabSelected = Notification.Name("com.tazetdinov.stuff.toolbar.tab-items")
//    static let placesTabSelected = Notification.Name("com.tazetdinov.stuff.toolbar.tab-places")
//    static let checklistsTabSelected = Notification.Name("com.tazetdinov.stuff.toolbar.tab-checklists")
//}

enum Tab: Int, Codable, Equatable, Hashable {
    case items = 0
    case places = 1
    case checklists = 2
}

@main
struct StuffApp: App {
    let persistenceController = PersistenceController.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var selectedItem: Item?
    @State private var selectedPlace: ItemPlace?
    @State private var selectedChecklist: Checklist?

    @State private var requestedTab: Tab?

    @State private var sceneDelegate = SceneDelegate()

    var body: some Scene {
        WindowGroup {
            ContentView(selectedItem: $selectedItem, selectedPlace: $selectedPlace, selectedChecklist: $selectedChecklist, requestedTab: $requestedTab)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onContinueUserActivity(ItemDetailsView.activityIdentifier) { activity in
                    Logger.default.info("[HANDOFF] [\(activity.title ?? "<>")]")
                    Logger.default.info("[HANDOFF] UserInfo = \(String(describing: activity.userInfo))")
                    guard let identifier = activity.userInfo?[ItemDetailsView.identifierKey] as? UUID else {
                        Logger.default.error("[HANDOFF] could not build the identifier")
                        return
                    }
                    selectedItem = Item.item(with: identifier, in: persistenceController.container.viewContext)
                    Logger.default.info("[HANDOFF] got item = [\(selectedItem?.title ?? "<>")]")
                }
                .onContinueUserActivity(PlaceDetailsView.activityIdentifier) { activity in
                    Logger.default.info("[HANDOFF] [\(activity.title ?? "<>")]")
                    Logger.default.info("[HANDOFF] UserInfo = \(String(describing: activity.userInfo))")
                    guard let identifier = activity.userInfo?[PlaceDetailsView.identifierKey] as? UUID else {
                        Logger.default.error("[HANDOFF] could not build the identifier")
                        return
                    }
                    selectedPlace = ItemPlace.place(with: identifier, in: persistenceController.container.viewContext)
                    Logger.default.info("[HANDOFF] got checklist = [\(selectedChecklist?.title ?? "<>")]")
                }
                .onContinueUserActivity(ChecklistEntryListView.activityIdentifier) { activity in
                    Logger.default.info("[HANDOFF] [\(activity.title ?? "<>")]")
                    Logger.default.info("[HANDOFF] UserInfo = \(String(describing: activity.userInfo))")
                    guard let identifier = activity.userInfo?[ChecklistEntryListView.identifierKey] as? UUID else {
                        Logger.default.error("[HANDOFF] could not build the identifier")
                        return
                    }
                    selectedChecklist = Checklist.checklist(with: identifier, in: persistenceController.container.viewContext)
                    Logger.default.info("[HANDOFF] got checklist = [\(selectedChecklist?.title ?? "<>")]")
                }
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.toolbar) {
                Button {
                    requestedTab = .items
                } label: {
                    Label("Show items", systemImage: "tag")
                }
                .keyboardShortcut("1", modifiers: [.command])
                Button {
                    requestedTab = .places
                } label: {
                    Label("Show places", systemImage: "house")
                }
                .keyboardShortcut("2", modifiers: [.command])
                Button {
                    requestedTab = .checklists
                } label: {
                    Label("Show checklists", systemImage: "list.bullet.rectangle")
                }
                .keyboardShortcut("3", modifiers: [.command])
            }
        }

        WindowGroup("Item") {
            SingleItemDetailsView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .handlesExternalEvents(matching: [SingleItemDetailsView.activityIdentifier])

        WindowGroup("Place") {
            SinglePlaceView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .handlesExternalEvents(matching: [SinglePlaceView.activityIdentifier])

        WindowGroup("Checklist") {
            SingleChecklistView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .handlesExternalEvents(matching: [SingleChecklistView.activityIdentifier])
    }
}
