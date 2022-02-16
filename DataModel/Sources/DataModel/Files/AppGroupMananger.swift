//
//  AppGroupManager.swift
//  
//
//  Created by Danis Tazetdinov on 16.02.2022.
//

import Foundation
import Logger

public class AppGroupManager {

    public static let shared = AppGroupManager()

    private enum Constants {
        static let appGroup = "group.com.tazetdinov.stuff.widget"
    }

    public let appGroupContainer: URL

    private init() {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroup) else {
            Logger.default.error("failed to get widget container")
            fatalError("failed to get widget container")
        }
        appGroupContainer = container
    }

}
