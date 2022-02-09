//
//  PhoneNavigationView.swift
//  
//
//  Created by Danis Tazetdinov on 19.01.2022.
//

import SwiftUI

struct PhoneNavigationView<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        if UIDevice.current.isPhone {
            NavigationView {
                content
            }
        } else {
            content
        }
    }
}
