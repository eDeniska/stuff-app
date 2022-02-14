//
//  L10n+StuffWidget.swift
//  StuffWidgetExtension
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import Foundation
import Localization

extension L10n {
    
    enum RecentChecklists: String, Localizable {
        case widgetTitle = "recentChecklists.widget.title" // "Checklists"
        case widgetDescription = "recentChecklists.widget.description" // "List of recent checklists."
        case viewTitle = "recentChecklists.view.title" // "Recent checklists"
        case addButton = "recentChecklists.button.add" // "Add..."
        case noChecklists = "recentChecklists.noChecklists" // "No checklists"
        case openAppToSync = "recentChecklists.openAppToSync" // "Open app to sync"
        case totalNumberOfChecklists = "recentChecklists.totalNumberOfChecklist"
    }
}
