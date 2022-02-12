//
//  ChecklistListWelcomeView.swift
//  
//
//  Created by Danis Tazetdinov on 11.02.2022.
//

import SwiftUI

extension Notification.Name {
    static let newChecklistRequest = Notification.Name("NewChecklistRequestNotification")
}

struct ChecklistListWelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose existing checklist")
                .font(.title3)
            Text("or")
                .font(.body)
            Button {
                NotificationCenter.default.post(name: .newChecklistRequest, object: nil)
            } label: {
                Label("Add new", systemImage: "plus.square.dashed")
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)
        }
    }
}

