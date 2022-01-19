//
//  ItemDetailsWelcomeView.swift
//  
//
//  Created by Danis Tazetdinov on 19.01.2022.
//

import SwiftUI

struct ItemDetailsWelcomeView: View {

    var addNewItemAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose existing item")
                .font(.title3)
            Text("or")
                .font(.body)
            Button {
                addNewItemAction?()
            } label: {
                Label("Add new", systemImage: "plus.square.dashed")
            }
            .font(.title2)
        }
    }
}
