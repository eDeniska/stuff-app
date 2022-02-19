//
//  SingleChecklistView.swift
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

public struct SingleChecklistView: View {

    static func activateSession(checklist: Checklist) {
        let activity = NSUserActivity(activityType: UserActivityRegistry.ChecklistScene.activityType)
        activity.targetContentIdentifier = UserActivityRegistry.ChecklistScene.activityType
        activity.userInfo = [UserActivityRegistry.ChecklistScene.identifierKey: checklist.objectID.uriRepresentation()]
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { error in
            Logger.default.error("[SCENE] could not spawn scene \(error)")
        }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase

    @SceneStorage(UserActivityRegistry.ChecklistScene.identifierKey) private var checklistID = ""
    @State private var scene: UIWindowScene?

    public init() {
    }

    public var body: some View {
        NavigationView {
            if let checklistURL = URL(string: checklistID), let checklist = Checklist.checklist(with: checklistURL, in: viewContext) {
                ChecklistEntryListView(checklist: checklist, allowOpenInSeparateWindow: false)
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
                        window?.windowScene?.title = checklist.title
                    }
            } else {
                VStack {
                    Text(L10n.ChecklistDetails.checklistNoLongerAvailable.localized)
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
            Logger.default.info("[SCENE] scene context (second) = \(checklistID)")
        }
        .withWindow { window in
            Logger.default.info("[SCENE] received window: \(String(describing: window))")
            scene = window?.windowScene
        }
        .navigationViewStyle(.stack)
        .onContinueUserActivity(UserActivityRegistry.ChecklistScene.activityType) { activity in
            checklistID = (activity.userInfo?[UserActivityRegistry.ChecklistScene.identifierKey] as? URL)?.absoluteString ?? ""
            Logger.default.info("[SCENE] got activity \(activity)")
            Logger.default.info("[SCENE] got userInfo \(activity.userInfo ?? [:])")
        }
        .userActivity(UserActivityRegistry.ChecklistScene.activityType) { activity in
            activity.targetContentIdentifier = UserActivityRegistry.PlaceScene.activityType
            if let url = URL(string: checklistID) {
                activity.userInfo = [UserActivityRegistry.ChecklistScene.identifierKey: url]
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
