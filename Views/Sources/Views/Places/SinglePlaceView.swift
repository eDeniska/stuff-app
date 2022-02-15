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

    private static let placeIDKey = "placeID"
    public static let activityIdentifier = "com.tazetdinov.stuff.place.scene"

    static func activateSession(place: ItemPlace) {
        let activity = NSUserActivity(activityType: activityIdentifier)
        activity.targetContentIdentifier = activityIdentifier
        activity.userInfo = [placeIDKey: place.objectID.uriRepresentation()]
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { error in
            Logger.default.error("[SCENE] could not spawn scene \(error)")
        }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase

    @SceneStorage(SinglePlaceView.placeIDKey) private var placeID = ""
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
        .onContinueUserActivity(SinglePlaceView.activityIdentifier) { activity in
            placeID = (activity.userInfo?[SinglePlaceView.placeIDKey] as? URL)?.absoluteString ?? ""
            Logger.default.info("[SCENE] got activity \(activity)")
            Logger.default.info("[SCENE] got userInfo \(activity.userInfo ?? [:])")
        }
        .userActivity(SinglePlaceView.activityIdentifier) { activity in
            activity.targetContentIdentifier = SinglePlaceView.activityIdentifier
            if let url = URL(string: placeID) {
                activity.userInfo = [SinglePlaceView.placeIDKey: url]
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
