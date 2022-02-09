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

public struct SingleChecklistView: View {

    private static let checklistIDKey = "checklistID"
    public static let activityIdentifier = "com.tazetdinov.stuff.checklist.scene"

    static func activateSession(checklist: Checklist) {
        let activity = NSUserActivity(activityType: activityIdentifier)
        activity.targetContentIdentifier = activityIdentifier
        activity.userInfo = [checklistIDKey: checklist.objectID.uriRepresentation()]
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { error in
            Logger.default.error("[SCENE] could not spawn scene \(error)")
        }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @SceneStorage(SingleChecklistView.checklistIDKey) private var checklistID = ""
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
                                Text("Dismiss")
                            }
                        }
                    }
            } else {
                VStack {
                    Text("Checklist is no longer available")
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
            Logger.default.info("[SCENE] scene context (second) = \(checklistID)")
        }
        .withWindow { window in
            Logger.default.info("[SCENE] received window: \(String(describing: window))")
            scene = window?.windowScene
        }
        .navigationViewStyle(.stack)
        .onContinueUserActivity(SingleChecklistView.activityIdentifier) { activity in
            checklistID = (activity.userInfo?[SingleChecklistView.checklistIDKey] as? URL)?.absoluteString ?? ""
            Logger.default.info("[SCENE] got activity \(activity)")
            Logger.default.info("[SCENE] got userInfo \(activity.userInfo ?? [:])")
        }
        .userActivity(SingleChecklistView.activityIdentifier) { activity in
            activity.targetContentIdentifier = SingleChecklistView.activityIdentifier
            if let url = URL(string: checklistID) {
                activity.userInfo = [SingleChecklistView.checklistIDKey: url]
            } else {
                Logger.default.info("[SCENE] no URL")
            }
            Logger.default.info("[SCENE] advertising activity \(activity)")
        }
    }
}