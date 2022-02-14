//
//  LifeCycleDelegates.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 14.02.2022.
//

import UIKit
import Logger
import Views

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

    // rotation support management for camera view - it needs to be locked for iPhone in portrait orientation
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        guard UIDevice.current.isPhone else {
            return .all
        }
        guard var viewController = window?.rootViewController else {
            return UIDevice.current.isPhone ? .allButUpsideDown : .all
        }

        repeat {
            if viewController.hasRotationLockMarker() {
                Logger.default.info("[LOGGER] found!")
                return .portrait
            }
            if let presented = viewController.presentedViewController {
                viewController = presented
            } else if let nvc = viewController as? UINavigationController, let top = nvc.topViewController {
                viewController = top
            } else {
                break
            }
        } while true

        return UIDevice.current.isPhone ? .allButUpsideDown : .all
    }

}

fileprivate extension UIViewController {

    func hasRotationLockMarker() -> Bool {
        var viewControllers = [self]

        repeat {
            guard !viewControllers.isEmpty else {
                break
            }
            let vc = viewControllers.removeFirst()
            if vc is UIImagePickerController {
                return true
            }
            viewControllers.append(contentsOf: vc.children)
        } while true
        return false
    }
}

