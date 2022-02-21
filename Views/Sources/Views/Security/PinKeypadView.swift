//
//  PinKeypadView.swift
//  
//
//  Created by Данис Тазетдинов on 20.02.2022.
//

import SwiftUI
import LocalAuthentication
import Logger

struct PinKeypadView: View {

    enum LockState {
        case locked
        case unlocked
        case noLock
    }
    
    @Binding var pin: String
    @Binding var message: String
    @Binding var state: LockState

    var biometryType: LABiometryType

    var validationAction: ((String) -> Bool)
    var biometryAction: (() -> Void)?
    
    @State private var disabled = false

    private let buttonSpacing: CGFloat = 16
    
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
        let horizontal = (size.width - 4 * buttonSpacing) / 3
        let vertical = (size.height - 5 * buttonSpacing) / 4
        let dimension = min(horizontal, vertical)
        if dimension > 0  {
            return CGSize(width: dimension, height: dimension)
        } else {
            return CGSize(width: 10, height: 10)
        }

    }

    private let pinPad = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Group {
                    switch state {
                    case .locked:
                        Image(systemName: "lock")
                    case .unlocked:
                        Image(systemName: "lock.open")
                    case .noLock:
                        EmptyView()
                    }
                    Text(message)
                        .fixedSize(horizontal: true, vertical: false)
                        .animation(nil, value: true)
                }
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            }
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
                let buttonSize = buttonSize(for: proxy.size)
                HStack {
                    Spacer()
                VStack(alignment: .center, spacing: buttonSpacing) {
                    ForEach(pinPad, id: \.self) { padLine in
                        HStack(alignment: .center, spacing: buttonSpacing) {
                            ForEach(padLine, id: \.self) { key in
                                PinButton(title: key, action: append(_:))
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
                        PinButton(title: "0", action: append(_:))
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
        }
    }
}
