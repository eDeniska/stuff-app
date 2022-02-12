//
//  PlaceDetailsWelcomeView.swift
//  
//
//  Created by Danis Tazetdinov on 19.01.2022.
//

import SwiftUI
import Localization

extension Notification.Name {
    static let newPlaceRequest = Notification.Name("NewPlaceRequestNotification")
}

struct PlaceDetailsWelcomeView: View {

    var addNewPlaceAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Text(L10n.PlaceWelcome.chooseExisting.localized)
                .font(.title3)
            Text(L10n.PlaceWelcome.orLabel.localized)
                .font(.body)
            Button {
                NotificationCenter.default.post(name: .newPlaceRequest, object: nil)
            } label: {
                Label(L10n.PlaceWelcome.createNewButton.localized, systemImage: "plus.square.dashed")
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)
        }
    }
}
