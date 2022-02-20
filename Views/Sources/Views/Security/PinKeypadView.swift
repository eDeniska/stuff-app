//
//  PinKeypadView.swift
//  
//
//  Created by Данис Тазетдинов on 20.02.2022.
//

import SwiftUI

struct FlashingNumberButtonStyle: ButtonStyle {

    let foregroundColor: Color
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? backgroundColor : foregroundColor)
            .background(configuration.isPressed ? foregroundColor : backgroundColor)
            .clipShape(Circle().inset(by: 0.5))
            .background(Circle().stroke(configuration.isPressed ? backgroundColor : foregroundColor))
    }
}

struct SizePreferenceKey: PreferenceKey {
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
    
    static var defaultValue = CGSize.zero
}

extension View {
    func withSize(_ sizeHandler: @escaping (CGSize) -> ()) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        }
        .onPreferenceChange(SizePreferenceKey.self, perform: sizeHandler)
    }
}

struct PinButton: View {
    let title: String
    let action: ((String) -> Void)?
    
    @State private var height: CGFloat = .zero
    
    var body: some View {
        Button {
            self.action?(self.title)
        } label: {
            Text(title)
                .font(.system(size: 32, weight: .light, design: .monospaced))
                .padding(32)
        }
        .frame(height: height)
        .buttonStyle(FlashingNumberButtonStyle(foregroundColor: .accentColor,
                                               backgroundColor: .secondary))
        .withSize { (size) in
            if size.width > 0 {
                self.height = size.width
            }
        }
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 4
    var percentage: CGFloat
    var completion: (() -> Void)? = nil
    var animatableData: CGFloat {
        get {
            percentage
        }
        set {
            percentage = newValue
            checkIfCompleted()
        }
    }
    
    func checkIfCompleted() {
        if percentage == 1 {
            completion?()
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}


struct PinKeypadView: View {
    
    var biometryAllowed: Bool
    @Binding var pin: String
    
    var validationAction: ((String) -> Bool)
    var biometryAction: (() -> Void)?
    
    @State private var disabled = false

    private let buttonSpacing: CGFloat = 16
    
    func append(_ number: String) {
        withAnimation {
            if pin.count < 6 {
                pin.append(number)
                if pin.count == 6 {
                    if validationAction(pin) {
                        pin = ""
                    } else {
                        disabled = true
                        pin = ""
                    }
                }
            }
        }
    }
    
    func delete() {
        withAnimation {
            if !pin.isEmpty {
                pin.removeLast()
            }
        }
    }
    
    func pinImage(index: Int) -> String {
        index < pin.count ? "circle.fill" : "circle"
    }


    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
