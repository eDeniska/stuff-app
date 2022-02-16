//
//  ChecklistToggleStyle.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI

extension ToggleStyle where Self == ChecklistToggleStyle {

    static var checklist: ChecklistToggleStyle { ChecklistToggleStyle() }
}

struct ChecklistToggleStyle: ToggleStyle {

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Button {
                configuration.isOn.toggle()
            } label: {
                Image(systemName: configuration.isOn ? "checkmark.circle" : "circle")
                    .resizable()
                    .frame(width: 22, height: 22)
            }
        }
    }

}
