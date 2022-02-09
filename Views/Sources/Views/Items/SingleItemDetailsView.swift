//
//  SingleItemDetailsView.swift
//  
//
//  Created by Danis Tazetdinov on 08.02.2022.
//

import SwiftUI
import DataModel
import CoreData
import Logger

public struct SingleItemDetailsView: View {

    private static let itemIDKey = "itemID"
    public static let activityIdentifier = "com.tazetdinov.stuff.item.scene"

    static func activateSession(item: Item) {
        let activity = NSUserActivity(activityType: activityIdentifier)
        activity.targetContentIdentifier = activityIdentifier
        activity.userInfo = [itemIDKey: item.objectID.uriRepresentation()]
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { error in
            Logger.default.error("[SCENE] could not spawn scene \(error)")
        }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @SceneStorage(SingleItemDetailsView.itemIDKey) private var itemID = ""
    @State private var scene: UIWindowScene?

    public init() {
    }

    public var body: some View {
        NavigationView {
            if let checklistURL = URL(string: itemID), let item = Item.item(with: checklistURL, in: viewContext) {
                ItemDetailsView(item: item, allowOpenInSeparateWindow: false)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(role: .cancel) {
                                if let scene = scene {
                                    Logger.default.info("[SCENE] processing captured scene: \(scene)")
                                    UIApplication.shared.requestSceneSessionDestruction(scene.session, options: nil) { error in
                                        Logger.default.error("[SCENE] failed to dismiss scene \(error)")
                                    }
                                } else {
                                    Logger.default.error("[SCENE] no scene, could not dismiss window")
                                }
                            } label: {
                                Text("Dismiss")
                            }
                        }
                    }
            } else {
                VStack {
                    Text("Item is no longer available")
                    Button(role: .cancel) {
                        if let scene = scene {
                            Logger.default.info("[SCENE] processing captured scene: \(scene)")
                            UIApplication.shared.requestSceneSessionDestruction(scene.session, options: nil) { error in
                                Logger.default.error("[SCENE] failed to dismiss scene \(error)")
                            }
                        } else {
                            Logger.default.error("[SCENE] no scene, could not dismiss window")
                        }
                    } label: {
                        Text("Dismiss")
                    }
                }
            }
        }
        .onAppear {
            Logger.default.info("[SCENE] scene context (third) = \(itemID)")
        }
        .withWindow { window in
            Logger.default.info("[SCENE] received window: \(String(describing: window))")
            scene = window?.windowScene
        }
        .navigationViewStyle(.stack)
        .onContinueUserActivity(SingleItemDetailsView.activityIdentifier) { activity in
            itemID = (activity.userInfo?[SingleItemDetailsView.itemIDKey] as? URL)?.absoluteString ?? ""
            Logger.default.info("[SCENE] got activity \(activity)")
            Logger.default.info("[SCENE] got userInfo \(activity.userInfo ?? [:])")
        }
        .userActivity(SingleItemDetailsView.activityIdentifier) { activity in
            activity.targetContentIdentifier = SingleItemDetailsView.activityIdentifier
            if let url = URL(string: itemID) {
                activity.userInfo = [SingleItemDetailsView.itemIDKey: url]
            } else {
                Logger.default.info("[SCENE] no URL")
            }
            Logger.default.info("[SCENE] advertising activity \(activity)")
        }
    }
}
