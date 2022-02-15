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
import Localization


// TODO: Apple Watch app – go through checklist, use only thumbnails, if needed
// TODO: add Spotlight search support
// TODO: add option to share checklists (and items)
// TODO: add option to make reminders out of checklists
// TODO: Siri/Shortcuts intents to manage lists

// TODO: smart checklists for lost items, items without a place, damaged items - you can't "complete" them

// TODO: onboarding
// TODO: pin/biometric lock of the app access
// TODO: add option to export and import data
// TODO: add onSubmit actions for text fields where appropriate
// TODO: Keyboard shortcuts for New Item, New Place, New Checklist and shortcuts for buttons in details view
// TODO: support undo in editing lists

// TODO: add app help
// TODO: fill credits

// TODO: seems that sort order for checklist entries might not be maintained
// TODO: fix keyboard shortcuts not working on places and checklists tabs on Mac Catalyst

enum Tab: Int, Codable, Equatable, Hashable {
    case items = 0
    case places = 1
    case checklists = 2
}

@main
struct StuffApp: App {
    private let persistenceController = PersistenceController.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @State private var selectedItem: Item?
    @State private var selectedPlace: ItemPlace?
    @State private var selectedChecklist: Checklist?

    @State private var requestedTab: Tab?

    @State private var sceneDelegate = SceneDelegate()

    var body: some Scene {
        WindowGroup {
            ContentView(selectedItem: $selectedItem, selectedPlace: $selectedPlace, selectedChecklist: $selectedChecklist, requestedTab: $requestedTab)
                .onAppear {
                    ItemCategory.performHousekeeping(in: persistenceController.container.viewContext)
                    persistenceController.container.viewContext.saveOrRollback()
                }
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
                .onOpenURL { url in
                    Logger.default.info("[WIDGET] url from widget = \(url)")
                    if let action = WidgetURLHandler.action(from: url, in: persistenceController.container.viewContext) {
                        switch action {
                        case .showChecklist(let checklist):
                            Logger.default.info("[WIDGET] got checklist = \(checklist.identifier)")
                            selectedChecklist = checklist
                        case .createChecklist:
                            requestedTab = .checklists
                            NotificationCenter.default.post(name: .newChecklistRequest, object: nil)
                        }
                    } else {
                        Logger.default.error("[WIDGET] could not get action from url = \(url)")
                    }
                }
        }
        .commands {
            // TODO: consider opening "new..." forms from current tab
            CommandGroup(replacing: .newItem) {
                Menu {
                    Button {
                        requestedTab = .items
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .newItemRequest, object: nil)
                        }
                    } label: {
                        Label(L10n.App.Menu.newItem.localized, systemImage: "tag")
                    }
                    .keyboardShortcut("i", modifiers: [.command, .shift])
                    Divider()
                    Button {
                        requestedTab = .places
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .newPlaceRequest, object: nil)
                        }
                    } label: {
                        Label(L10n.App.Menu.newPlace.localized, systemImage: "house")
                    }
                    .keyboardShortcut("p", modifiers: [.command, .shift])
                    Divider()
                    Button {
                        requestedTab = .checklists
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .newChecklistRequest, object: nil)
                        }
                    } label: {
                        Label(L10n.App.Menu.newChecklist.localized, systemImage: "list.bullet.rectangle")
                    }
                    .keyboardShortcut("l", modifiers: [.command, .shift])
                } label: {
                    Label(L10n.App.Menu.newMenu.localized, systemImage: "plus")
                }
                Button {
                    let activity = NSUserActivity(activityType: "com.tazetdinov.stuff.newWindow")
                    activity.targetContentIdentifier = "com.tazetdinov.stuff.newWindow"
                    UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { error in
                        Logger.default.error("[SCENE] could not spawn scene \(error)")
                    }
                } label: {
                    Label(L10n.App.Menu.newWindow.localized, systemImage: "square.on.square")
                }
                .keyboardShortcut("n", modifiers: [.command])

            }

            CommandGroup(replacing: .toolbar) {
                Button {
                    requestedTab = .items
                } label: {
                    Label(L10n.App.Menu.showItems.localized, systemImage: "tag")
                }
                .keyboardShortcut("1", modifiers: [.command])
                Button {
                    requestedTab = .places
                } label: {
                    Label(L10n.App.Menu.showPlaces.localized, systemImage: "house")
                }
                .keyboardShortcut("2", modifiers: [.command])
                Button {
                    requestedTab = .checklists
                } label: {
                    Label(L10n.App.Menu.showChecklists.localized, systemImage: "list.bullet.rectangle")
                }
                .keyboardShortcut("3", modifiers: [.command])
            }
        }

        WindowGroup(L10n.App.windowItems.localized) {
            SingleItemDetailsView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .handlesExternalEvents(matching: [SingleItemDetailsView.activityIdentifier])

        WindowGroup(L10n.App.windowPlaces.localized) {
            SinglePlaceView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .handlesExternalEvents(matching: [SinglePlaceView.activityIdentifier])

        WindowGroup(L10n.App.windowChecklists.localized) {
            SingleChecklistView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .handlesExternalEvents(matching: [SingleChecklistView.activityIdentifier])
    }
}
