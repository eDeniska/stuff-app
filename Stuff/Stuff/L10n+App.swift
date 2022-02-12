//
//  L10n+App.swift
//  Stuff
//
//  Created by Данис Тазетдинов on 12.02.2022.
//

import Foundation
import Localization

extension L10n {
    enum App: String, Localizable {
        case showItems = "app.menu.showItems"
        case showPlaces = "app.menu.showPlaces"
        case showChecklists = "app.menu.showChecklists"
        case quickActionChecklist = "app.quickAction.openChecklist"
        case toolbarItems = "app.toolbar.items"
        case toolbarPlaces = "app.toolbar.places"
        case toolbarChecklists = "app.toolbar.checklists"
        case windowItems = "app.window.items"
        case windowPlaces = "app.window.places"
        case windowChecklists = "app.window.checklists"
        case titleItems = "app.title.items"
        case titlePlaces = "app.title.places"
        case titleChecklists = "app.title.checklists"
    }
}
