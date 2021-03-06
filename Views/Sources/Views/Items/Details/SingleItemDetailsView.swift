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
import Localization
import WidgetKit

public struct SingleItemDetailsView: View {

    static func activateSession(item: Item) {
        let activity = NSUserActivity(activityType: UserActivityRegistry.ItemScene.activityType)
        activity.targetContentIdentifier = UserActivityRegistry.ItemScene.activityType
        activity.userInfo = [UserActivityRegistry.ItemScene.identifierKey: item.objectID.uriRepresentation()]
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { error in
            Logger.default.error("[SCENE] could not spawn scene \(error)")
        }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase

    @SceneStorage(UserActivityRegistry.ItemScene.identifierKey) private var itemID = ""
    @State private var scene: UIWindowScene?

    public init() {
    }

    public var body: some View {
        NavigationView {
            if let itemURL = URL(string: itemID), let item = Item.item(with: itemURL, in: viewContext) {
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
                                Text(L10n.Common.buttonDismiss.localized)
                            }
                        }
                    }
                    .withWindow { window in
                        window?.windowScene?.title = item.title
                    }
            } else {
                VStack {
                    Text(L10n.ItemDetails.itemNoLongerAvailable.localized)
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
                        Text(L10n.Common.buttonDismiss.localized)
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
        .onContinueUserActivity(UserActivityRegistry.ItemScene.activityType) { activity in
            itemID = (activity.userInfo?[UserActivityRegistry.ItemScene.identifierKey] as? URL)?.absoluteString ?? ""
            Logger.default.info("[SCENE] got activity \(activity)")
            Logger.default.info("[SCENE] got userInfo \(activity.userInfo ?? [:])")
        }
        .userActivity(UserActivityRegistry.ItemScene.activityType) { activity in
            activity.targetContentIdentifier = UserActivityRegistry.ItemScene.activityType
            if let url = URL(string: itemID) {
                activity.userInfo = [UserActivityRegistry.ItemScene.identifierKey: url]
            } else {
                Logger.default.info("[SCENE] no URL")
            }
            Logger.default.info("[SCENE] advertising activity \(activity)")
        }
        .onChange(of: scenePhase) { newValue in
            if newValue != .active {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
