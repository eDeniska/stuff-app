//
//  ChecklistListWelcomeView.swift
//  
//
//  Created by Danis Tazetdinov on 11.02.2022.
//

import SwiftUI
import Localization

extension Notification.Name {
    static let newChecklistRequest = Notification.Name("NewChecklistRequestNotification")
}

struct ChecklistListWelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text(L10n.ChecklistWelcome.chooseExisting.localized)
                .font(.title3)
            Text(L10n.ChecklistWelcome.orLabel.localized)
                .font(.body)
            Button {
                NotificationCenter.default.post(name: .newChecklistRequest, object: nil)
            } label: {
                Label(L10n.ChecklistWelcome.createNewButton.localized, systemImage: "plus.square.dashed")
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)
        }
    }
}

