//
//  PlaceDetailsWelcomeView.swift
//  
//
//  Created by Danis Tazetdinov on 19.01.2022.
//

import SwiftUI

extension Notification.Name {
    static let newPlaceRequest = Notification.Name("NewPlaceRequestNotification")
}

struct PlaceDetailsWelcomeView: View {

    var addNewPlaceAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose existing place")
                .font(.title3)
            Text("or")
                .font(.body)
            Button {
                NotificationCenter.default.post(name: .newPlaceRequest, object: nil)
            } label: {
                Label("Add new", systemImage: "plus.square.dashed")
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)
        }
    }
}
