//
//  PINKeypadView.swift
//  
//
//  Created by Данис Тазетдинов on 20.02.2022.
//

import SwiftUI
import LocalAuthentication
import Logger
import ViewModels

struct PINKeypadView: View {
    
    @Binding var pin: String
    @Binding var lockState: PINViewModelLockState
    @Binding var message: String

    var biometryType: LABiometryType

    var validationAction: ((String) -> Bool)
    var biometryAction: (() -> Void)?
    
    @State private var disabled = false

    private let buttonSpacing: CGFloat = 24
    
    func append(_ number: String) {
        withAnimation {
            if pin.count < 6 {
                pin.append(number)
                if pin.count == 6 {
                    if !validationAction(pin) {
                        disabled = true
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

    private func buttonSize(for size: CGSize) -> CGSize {
        let horizontal = (size.width - 6 * buttonSpacing) / 3
        let vertical = (size.height - 7 * buttonSpacing) / 4
        let dimension = min(horizontal, vertical)
        if dimension > 0  {
            return CGSize(width: dimension, height: dimension)
        } else {
            return CGSize(width: 10, height: 10)
        }

    }

    private let pinPad = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]

    @ViewBuilder
    private func classicPinPad(buttonSize: CGSize) -> some View {
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: buttonSpacing) {
                Spacer()
                ForEach(pinPad, id: \.self) { padLine in
                    HStack(alignment: .center, spacing: buttonSpacing) {
                        ForEach(padLine, id: \.self) { key in
                            PINButton(title: key, action: append(_:))
                                .frame(width: buttonSize.width, height: buttonSize.height)
                        }
                    }
                }

                HStack(alignment: .center, spacing: buttonSpacing) {
                    if biometryType != .none {
                        Button {
                            biometryAction?()
                        } label: {
                            Group {
                                switch biometryType {
                                case .faceID:
                                    Image(systemName: "faceid")

                                case .touchID:
                                    Image(systemName: "touchid")

                                case .none:
                                    EmptyView()

                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .contentShape(Circle())
                        }
                        .buttonStyle(.flashingButton(color: .accentColor))
                        .frame(width: buttonSize.width, height: buttonSize.height)
                    } else {
                        Color.clear
                            .frame(width: buttonSize.width, height: buttonSize.height)
                    }
                    PINButton(title: "0", action: append(_:))
                        .frame(width: buttonSize.width, height: buttonSize.height)
                    Button(action: delete) {
                        Image(systemName: "delete.left")
                            .contentShape(Circle())
                    }
                    .buttonStyle(.flashingButton(color: .accentColor))
                    .frame(width: buttonSize.width, height: buttonSize.height)
                    .disabled(pin.isEmpty)
                    .keyboardShortcut(.delete, modifiers: [])
                }
            }
            .font(.title.monospaced())
            .disabled(disabled)
            Spacer()
        }
    }

    private func alternateButtonSize(for size: CGSize) -> CGSize {
        let buttonWidth = (size.width - buttonSpacing * 11) / 10
        return CGSize(width: buttonWidth, height: buttonWidth)
    }

    @ViewBuilder
    private func alternatePinPad(buttonSize: CGSize) -> some View {
        VStack(spacing: buttonSpacing) {
            HStack(alignment: .center, spacing: buttonSpacing) {
                Spacer()
                ForEach(pinPad.reduce([], +), id: \.self) { key in
                    PINButton(title: key, action: append(_:))
                        .frame(width: buttonSize.width, height: buttonSize.height)
                }
                PINButton(title: "0", action: append(_:))
                    .frame(width: buttonSize.width, height: buttonSize.height)
                Spacer()
            }

            HStack(alignment: .center, spacing: buttonSpacing) {
                Spacer()
                if biometryType != .none {
                    Button {
                        biometryAction?()
                    } label: {
                        Group {
                            switch biometryType {
                            case .faceID:
                                Image(systemName: "faceid")

                            case .touchID:
                                Image(systemName: "touchid")

                            case .none:
                                EmptyView()

                            @unknown default:
                                EmptyView()
                            }
                        }
                        .contentShape(Circle())
                    }
                    .buttonStyle(.flashingButton(color: .accentColor))
                    .frame(width: buttonSize.width, height: buttonSize.height)
                }
                Button(action: delete) {
                    Image(systemName: "delete.left")
                        .contentShape(Circle())
                }
                .buttonStyle(.flashingButton(color: .accentColor))
                .frame(width: buttonSize.width, height: buttonSize.height)
                .disabled(pin.isEmpty)
                .keyboardShortcut(.delete, modifiers: [])
                Spacer()
            }
        }
        .font(.title.monospaced())
        .disabled(disabled)
    }


    @ViewBuilder
    private func pinPad(for size: CGSize) -> some View {
        if UIDevice.current.isPhone && size.height < size.width {
            alternatePinPad(buttonSize: alternateButtonSize(for: size))
        } else {
            classicPinPad(buttonSize: buttonSize(for: size))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if lockState != .noLock {
                    switch lockState {
                    case .locked:
                        Image(systemName: "lock")
                    case .unlocked:
                        Image(systemName: "lock.open")
                    case .noLock:
                        EmptyView()
                    }
                }
                Text(message)
                    .fixedSize(horizontal: true, vertical: false)
                    .animation(nil, value: message)
            }
            .font(.headline)
            .multilineTextAlignment(.center)
            .foregroundColor(.primary)
            HStack(spacing: buttonSpacing) {
                Image(systemName: pinImage(index: 0))
                Image(systemName: pinImage(index: 1))
                Image(systemName: pinImage(index: 2))
                Image(systemName: pinImage(index: 3))
                Image(systemName: pinImage(index: 4))
                Image(systemName: pinImage(index: 5))
            }
            .padding()
            .modifier(ShakeModifier(percentage: disabled ? 1.0 : 0.0) {
                DispatchQueue.main.async {
                    disabled = false
                    pin = ""
                }
            })

            GeometryReader { proxy in
                pinPad(for: proxy.size)
            }
        }
    }
}
