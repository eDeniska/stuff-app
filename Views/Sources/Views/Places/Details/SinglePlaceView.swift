//
//  SinglePlaceView.swift
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

public struct SinglePlaceView: View {

    static func activateSession(place: ItemPlace) {
        let activity = NSUserActivity(activityType: UserActivityRegistry.PlaceScene.activityType)
        activity.targetContentIdentifier = UserActivityRegistry.PlaceScene.activityType
        activity.userInfo = [UserActivityRegistry.PlaceScene.identifierKey: place.objectID.uriRepresentation()]
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { error in
            Logger.default.error("[SCENE] could not spawn scene \(error)")
        }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase

    @SceneStorage(UserActivityRegistry.PlaceScene.identifierKey) private var placeID = ""
    @State private var scene: UIWindowScene?

    public init() {
    }

    public var body: some View {
        NavigationView {
            if let placeURL = URL(string: placeID), let place = ItemPlace.place(with: placeURL, in: viewContext) {
                PlaceDetailsView(place: place, allowOpenInSeparateWindow: false)
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
                        window?.windowScene?.title = place.title
                    }
            } else {
                VStack {
                    Text(L10n.PlaceDetails.placeNoLongerAvailable.localized)
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
            Logger.default.info("[SCENE] scene context (second) = \(placeID)")
        }
        .withWindow { window in
            Logger.default.info("[SCENE] received window: \(String(describing: window))")
            scene = window?.windowScene
        }
        .navigationViewStyle(.stack)
        .onContinueUserActivity(UserActivityRegistry.PlaceScene.activityType) { activity in
            placeID = (activity.userInfo?[UserActivityRegistry.PlaceScene.identifierKey] as? URL)?.absoluteString ?? ""
            Logger.default.info("[SCENE] got activity \(activity)")
            Logger.default.info("[SCENE] got userInfo \(activity.userInfo ?? [:])")
        }
        .userActivity(UserActivityRegistry.PlaceScene.activityType) { activity in
            activity.targetContentIdentifier = UserActivityRegistry.PlaceScene.activityType
            if let url = URL(string: placeID) {
                activity.userInfo = [UserActivityRegistry.PlaceScene.identifierKey: url]
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
