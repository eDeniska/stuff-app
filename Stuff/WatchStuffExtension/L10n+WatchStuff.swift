//
//  L10n+WatchStuff.swift
//  WatchStuffExtension
//
//  Created by Danis Tazetdinov on 16.02.2022.
//

import Foundation
import Localization

extension L10n {
    enum WatchStuff: String, Localizable {
        case checklistsTitle = "watch.checklists.title"
        case noLists = "watch.checklists.noLists"
        case noEntries = "watch.checklists.noEntries"
        case sectionChecked = "watch.checklist.section.checked"
        case sectionPending = "watch.checklist.section.pending"
    }
}
