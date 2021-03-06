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
import ViewModels
import Localization


// TODO: add Spotlight search support
// TODO: add option to share checklists (and items)
// TODO: add option to make reminders out of checklists
// TODO: Siri/Shortcuts intents to manage lists

// TODO: onboarding
// TODO: add onSubmit actions for text fields where appropriate
// TODO: support undo in editing lists

// TODO: add app help
// TODO: fill credits

// TODO: fix keyboard shortcuts not working on places and checklists tabs on Mac Catalyst

enum Tab: Int, Codable, Equatable, Hashable {
    case items = 0
    case places = 1
    case checklists = 2
    case preferences = 3
}

class WeakBox<T: AnyObject> {
    public weak var value: T?
    init(_ value: T? = nil) {
        self.value = value
    }
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

    @State private var needsEnterPin = true
    @State private var backgroundDate = Date.distantPast

    @State private var settingsScene = WeakBox<UIWindowScene>()

    init() {
        FileStorageManager.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            PINProtected(needsEnterPin: $needsEnterPin, backgroundedDate: $backgroundDate) {
                ContentView(selectedItem: $selectedItem, selectedPlace: $selectedPlace, selectedChecklist: $selectedChecklist, requestedTab: $requestedTab)
            }
            .onAppear {
                Item.performHousekeeping(in: persistenceController.container.viewContext)
                ItemCategory.performHousekeeping(in: persistenceController.container.viewContext)
                ItemPlace.performHousekeeping(in: persistenceController.container.viewContext)
                Checklist.performHousekeeping(in: persistenceController.container.viewContext)
                persistenceController.container.viewContext.saveOrRollback()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environment(\.persistentContainer, persistenceController.container)
            .onContinueUserActivity(UserActivityRegistry.ItemsView.activityType) { _ in
                requestedTab = .items
            }
            .onContinueUserActivity(UserActivityRegistry.PlacesView.activityType) { _ in
                requestedTab = .places
            }
            .onContinueUserActivity(UserActivityRegistry.ChecklistsView.activityType) { _ in
                requestedTab = .checklists
            }
            .onContinueUserActivity(UserActivityRegistry.ItemView.activityType) { activity in
                Logger.default.info("[HANDOFF] [\(activity.title ?? "<>")]")
                Logger.default.info("[HANDOFF] UserInfo = \(String(describing: activity.userInfo))")
                guard let identifier = activity.userInfo?[UserActivityRegistry.ItemView.identifierKey] as? UUID else {
                    Logger.default.error("[HANDOFF] could not build the identifier")
                    return
                }
                selectedItem = Item.item(with: identifier, in: persistenceController.container.viewContext)
                Logger.default.info("[HANDOFF] got item = [\(selectedItem?.title ?? "<>")]")
            }
            .onContinueUserActivity(UserActivityRegistry.PlaceView.activityType) { activity in
                Logger.default.info("[HANDOFF] [\(activity.title ?? "<>")]")
                Logger.default.info("[HANDOFF] UserInfo = \(String(describing: activity.userInfo))")
                guard let identifier = activity.userInfo?[UserActivityRegistry.PlaceView.identifierKey] as? UUID else {
                    Logger.default.error("[HANDOFF] could not build the identifier")
                    return
                }
                selectedPlace = ItemPlace.place(with: identifier, in: persistenceController.container.viewContext)
                Logger.default.info("[HANDOFF] got checklist = [\(selectedChecklist?.title ?? "<>")]")
            }
            .onContinueUserActivity(UserActivityRegistry.ChecklistView.activityType) { activity in
                Logger.default.info("[HANDOFF] [\(activity.title ?? "<>")]")
                Logger.default.info("[HANDOFF] UserInfo = \(String(describing: activity.userInfo))")
                guard let identifier = activity.userInfo?[UserActivityRegistry.ChecklistView.identifierKey] as? UUID else {
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
            CommandGroup(replacing: .appSettings) {
                Button {
                    if UIDevice.current.isMac {
                        let activity = NSUserActivity(activityType: UserActivityRegistry.SettingsScene.activityType)
                        activity.targetContentIdentifier = UserActivityRegistry.SettingsScene.activityType
                        UIApplication.shared.requestSceneSessionActivation(settingsScene.value?.session, userActivity: activity, options: nil) { error in
                            Logger.default.error("[SCENE] could not spawn scene \(error)")
                        }
                    } else {
                        requestedTab = .preferences
                    }

                } label: {
                    Label(L10n.App.Menu.preferences.localized, systemImage: "gear")
                }
                .keyboardShortcut(",", modifiers: [.command])
            }
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
            PINProtected(needsEnterPin: $needsEnterPin, backgroundedDate: $backgroundDate) {
                SingleItemDetailsView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environment(\.persistentContainer, persistenceController.container)
        }
        .handlesExternalEvents(matching: [UserActivityRegistry.ItemScene.activityType])

        WindowGroup(L10n.App.windowPlaces.localized) {
            PINProtected(needsEnterPin: $needsEnterPin, backgroundedDate: $backgroundDate) {
                SinglePlaceView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environment(\.persistentContainer, persistenceController.container)
        }
        .handlesExternalEvents(matching: [UserActivityRegistry.PlaceScene.activityType])

        WindowGroup(L10n.App.windowChecklists.localized) {
            PINProtected(needsEnterPin: $needsEnterPin, backgroundedDate: $backgroundDate) {
                SingleChecklistView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environment(\.persistentContainer, persistenceController.container)
        }
        .handlesExternalEvents(matching: [UserActivityRegistry.ChecklistScene.activityType])

        WindowGroup(L10n.App.windowPreferences.localized) {
            PINProtected(needsEnterPin: $needsEnterPin, backgroundedDate: $backgroundDate) {
                PreferencesView()
                    .withWindow { window in
                        settingsScene.value = window?.windowScene
                    }
            }
            .onContinueUserActivity(UserActivityRegistry.SettingsScene.activityType) { userActivity in
                Logger.default.info("got activity - \(userActivity)")
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environment(\.persistentContainer, persistenceController.container)
            .handlesExternalEvents(preferring: [UserActivityRegistry.SettingsScene.activityType], allowing: ["*"])
        }
        .handlesExternalEvents(matching: [UserActivityRegistry.SettingsScene.activityType])


    }
}
