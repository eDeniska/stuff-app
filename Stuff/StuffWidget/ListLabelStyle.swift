//
//  ListLabelStyle.swift
//  StuffWidgetExtension
//
//  Created by Danis Tazetdinov on 15.02.2022.
//

import SwiftUI

struct ListLabelStyle: LabelStyle {
    @ScaledMetric var padding: CGFloat = 6

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: "rectangle")
                .hidden()
                .padding(padding)
                .overlay(
                    configuration.icon
//                        .foregroundColor(.accentColor)
                        .foregroundColor(Color("AccentColor"))
                )
            configuration.title
        }
    }
}

extension LabelStyle where Self == DefaultLabelStyle {
    static var listLabelStyle: ListLabelStyle {
        ListLabelStyle()
    }
}

