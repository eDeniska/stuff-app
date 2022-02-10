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

// TODO: onboarding

// TODO: add search support

// TODO: check, if handoff works with modal windows opened (consider "didSet" with cancellation)

// TODO: add icon quick actions - "add item", "take photo of item", and latest checklists

// TODO: separate windows have the same title

// TODO: add option to share lists, items, etc.

@main
struct StuffApp: App {
    let persistenceController = PersistenceController.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var selectedItem: Item?
    @State private var selectedPlace: ItemPlace?
    @State private var selectedChecklist: Checklist?

    @State private var sceneDelegate = SceneDelegate()

    var body: some Scene {
        WindowGroup {
            ContentView(selectedItem: $selectedItem, selectedPlace: $selectedPlace, selectedChecklist: $selectedChecklist)
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
