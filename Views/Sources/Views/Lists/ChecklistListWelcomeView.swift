//
//  ChecklistListWelcomeView.swift
//  
//
//  Created by Danis Tazetdinov on 11.02.2022.
//

import SwiftUI

struct ChecklistListWelcomeView: View {

    var addNewChecklistAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose existing checklist")
                .font(.title3)
            Text("or")
                .font(.body)
            Button {
                addNewChecklistAction?()
            } label: {
                Label("Add new", systemImage: "plus.square.dashed")
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)
        }
    }
}

