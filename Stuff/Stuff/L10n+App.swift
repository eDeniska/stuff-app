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
        enum Menu: String, Localizable {
            case newMenu = "app.menu.newMenu"
            case newWindow = "app.menu.newWindow"
            case newItem = "app.menu.newItem"
            case newPlace = "app.menu.newPlace"
            case newChecklist = "app.menu.newChecklist"
            case showItems = "app.menu.showItems"
            case showPlaces = "app.menu.showPlaces"
            case showChecklists = "app.menu.showChecklists"
            case preferences = "app.menu.preferences"
        }
        case quickActionChecklist = "app.quickAction.openChecklist"
        case toolbarItems = "app.toolbar.items"
        case toolbarPlaces = "app.toolbar.places"
        case toolbarChecklists = "app.toolbar.checklists"
        case windowItems = "app.window.items"
        case windowPlaces = "app.window.places"
        case windowChecklists = "app.window.checklists"
        case windowPreferences = "app.window.preferences"
        case titleItems = "app.title.items"
        case titlePlaces = "app.title.places"
        case titleChecklists = "app.title.checklists"
        case titlePreferences = "app.title.preferences"
    }
}
