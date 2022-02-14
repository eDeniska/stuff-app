//
//  QuickAction.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 10.02.2022.
//

import UIKit
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
