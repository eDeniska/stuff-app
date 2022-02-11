//
//  QuickAction.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 10.02.2022.
//

import UIKit
import Logger
import Views

enum QuickAction: String {
    case itemCapture = "action.capture.item"
    case checklistSelected = "action.select.checklist"

    @MainActor
    func handle(with item: UIApplicationShortcutItem) {
        switch self {
        case .itemCapture:
            NotificationCenter.default.post(name: .itemCaptureRequest, object: nil)

        case .checklistSelected:
            guard let identifier = item.userInfo?[ChecklistEntryListView.identifierKey] as? String,
                  let uuid = UUID(uuidString: identifier) else {
                      return
                  }
            let notification = Notification(name: .checklistSelected, object: nil, userInfo: [
                ChecklistEntryListView.identifierKey: uuid
            ])
            NotificationCenter.default.post(notification)
        }
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {

        Logger.default.info("got action \(shortcutItem)")
        guard let action = QuickAction(rawValue: shortcutItem.type) else {
            completionHandler(false)
            return
        }
        action.handle(with: shortcutItem)
        completionHandler(true)
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        if let shortcutItem = options.shortcutItem, let action = QuickAction(rawValue: shortcutItem.type) {
            Logger.default.info("got on connect action \(shortcutItem)")
            DispatchQueue.main.async {
                action.handle(with: shortcutItem)
            }
        }

        let sceneConfiguration = UISceneConfiguration(name: "Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self

        return sceneConfiguration
    }
}
