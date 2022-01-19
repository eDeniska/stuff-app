//
//  PlaceDetailsWelcomeView.swift
//  
//
//  Created by Danis Tazetdinov on 19.01.2022.
//

import SwiftUI

struct PlaceDetailsWelcomeView: View {

    var addNewPlaceAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose existing place")
                .font(.title3)
            Text("or")
                .font(.body)
            Button {
                addNewPlaceAction?()
            } label: {
                Label("Add new", systemImage: "plus.square.dashed")
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)
        }
    }
}
