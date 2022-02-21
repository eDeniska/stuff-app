//
//  PinButton.swift
//  
//
//  Created by Danis Tazetdinov on 21.02.2022.
//

import SwiftUI

struct FlashingButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if configuration.isPressed {
                color
                    .clipShape(Circle().inset(by: 0.5))
            } else {
                Circle().stroke(color)
            }
            configuration.label
                .foregroundColor(configuration.isPressed ? .secondary : color)
        }
        .contentShape(Circle())
    }
}

extension ButtonStyle where Self == FlashingButtonStyle {
    static func flashingButton(color: Color) -> FlashingButtonStyle {
        FlashingButtonStyle(color: color)
    }
}

struct PinButton: View {
    let title: String
    let action: ((String) -> Void)?

    @State private var height: CGFloat = .zero

    var body: some View {
        Button {
            action?(title)
        } label: {
            Text(title)
        }
        .buttonStyle(.flashingButton(color: .accentColor))
        .keyboardShortcut(KeyEquivalent(title[title.startIndex]), modifiers: [])
    }
}
