//
//  ItemDetailsWelcomeView.swift
//  
//
//  Created by Danis Tazetdinov on 19.01.2022.
//

import SwiftUI
import Localization

extension Notification.Name {
    static let newItemRequest = Notification.Name("NewItemRequestNotification")
}

struct ItemDetailsWelcomeView: View {

    var addNewItemAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Text(L10n.ItemWelcome.chooseExisting.localized)
                .font(.title3)
            Text(L10n.ItemWelcome.orLabel.localized)
                .font(.body)
            Button {
                NotificationCenter.default.post(name: .newItemRequest, object: nil)
            } label: {
                Label(L10n.ItemWelcome.createNewButton.localized, systemImage: "plus.square.dashed")
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)
        }
    }
}
