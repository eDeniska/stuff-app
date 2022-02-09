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


struct SceneWrapper<Content: View>: View {
    @SceneStorage("context") private var context = ""

    var content: () -> Content

    var body: some View {
        content()
            .onAppear {
                Logger.default.info("[SCENE] scene context (main) = \(context)")
            }
    }
}

struct ThirdScene: View {
    @SceneStorage("context") private var context = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Scene 3")
                Text(context)
            }
        }
        .onAppear {
            Logger.default.info("[SCENE] scene context (second) = \(context)")
        }
        .navigationViewStyle(.stack)
        .onContinueUserActivity("com.tazetdinov.stuff.item.scene") { activity in
            context = (activity.userInfo?["itemID"] as? URL)?.absoluteString ?? "<not passed>"
            Logger.default.info("[SCENE] got activity \(activity)")
            Logger.default.info("[SCENE] got userInfo \(activity.userInfo ?? [:])")
        }
        .userActivity("com.tazetdinov.stuff.item.scene") { activity in
            activity.targetContentIdentifier = "com.tazetdinov.stuff.item.scene"
            Logger.default.info("[SCENE] advertising activity \(activity)")
        }
    }
}

@main
struct StuffApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SceneWrapper {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .onContinueUserActivity("com.tazetdinov.stuff.checklist.scene") { activity in
                        Logger.default.info("[SCENE] got activity in the wrong place \(activity)")
                        Logger.default.info("[SCENE] got userInfo \(activity.userInfo ?? [:])")
                    }
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
