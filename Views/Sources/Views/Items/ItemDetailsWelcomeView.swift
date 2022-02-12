//
//  ItemDetailsWelcomeView.swift
//  
//
//  Created by Danis Tazetdinov on 19.01.2022.
//

import SwiftUI

extension Notification.Name {
    static let newItemRequest = Notification.Name("NewItemRequestNotification")
}

struct ItemDetailsWelcomeView: View {

    var addNewItemAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose existing item")
                .font(.title3)
            Text("or")
                .font(.body)
            Button {
                NotificationCenter.default.post(name: .newItemRequest, object: nil)
            } label: {
                Label("Add new", systemImage: "plus.square.dashed")
            }
            .buttonStyle(.borderedProminent)
            .font(.title)
        }
    }
}
