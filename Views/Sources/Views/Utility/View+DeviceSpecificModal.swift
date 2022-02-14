//
//  File.swift
//  
//
//  Created by Данис Тазетдинов on 14.02.2022.
//

import SwiftUI

public enum ModalPresentationStyle {
    case sheet
    case fullScreen
}

public extension View {
    @ViewBuilder
    func modal<Content: View>(isPresented presented: Binding<Bool>, style: ModalPresentationStyle, content: @escaping () -> Content) -> some View {
        switch style {
        case .fullScreen:
            fullScreenCover(isPresented: presented, content: content)
            
        case .sheet:
            sheet(isPresented: presented, content: content)
        }
    }

    @ViewBuilder
    func modal<Content: View>(isPresented presented: Binding<Bool>,
                              onPhone phoneStyle: ModalPresentationStyle = .sheet,
                              onPad padStyle: ModalPresentationStyle = .sheet,
                              onMac macStyle: ModalPresentationStyle = .sheet,
                              content: @escaping () -> Content) -> some View {
        if UIDevice.current.isPhone {
            modal(isPresented: presented, style: phoneStyle, content: content)
        } else if UIDevice.current.isMac {
            modal(isPresented: presented, style: macStyle, content: content)
        } else {
            // everything else is considered iPad
            modal(isPresented: presented, style: padStyle, content: content)
        }
    }
}
