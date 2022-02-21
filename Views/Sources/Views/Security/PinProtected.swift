//
//  PinProtected.swift
//  
//
//  Created by Danis Tazetdinov on 21.02.2022.
//

import SwiftUI
import Logger
import ViewModels

public struct PinProtected<Content: View>: View {

    private enum Constants {
        static var backgroundDuration: Int { 60 }
    }

    @Binding private var needsEnterPin: Bool
    @Binding private var backgroundedDate: Date
    private let content: () -> Content

    @State private var requestBiometric = false

    public init(needsEnterPin: Binding<Bool>, backgroundedDate: Binding<Date>, content: @escaping () -> Content) {
        _needsEnterPin = needsEnterPin
        _backgroundedDate = backgroundedDate
        self.content = content
    }

    @ViewBuilder
    private func mainView() -> some View {
        // TODO: add PinProtectionViewModel.protectionIsSet()
        if needsEnterPin {
            PinProtectionView {
                needsEnterPin = false
            }
            .onAppear {
                NotificationCenter.default.post(name: .requestBiometricAuthentiction, object: nil)
            }
        } else {
            content()
        }
    }

    public var body: some View {
        mainView()
            .onReceive(NotificationCenter.default.publisher(for: UIScene.didEnterBackgroundNotification, object: nil)) { notification in
                if backgroundedDate > .now {
                    backgroundedDate = .now
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Constants.backgroundDuration + 1)) {
                    if Date.now.timeIntervalSince(backgroundedDate) > TimeInterval(Constants.backgroundDuration) {
                        needsEnterPin = true
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIScene.willEnterForegroundNotification, object: nil)) { notification in
                if Date.now.timeIntervalSince(backgroundedDate) > TimeInterval(Constants.backgroundDuration) {
                    needsEnterPin = true
                }
                backgroundedDate = .distantFuture
                if needsEnterPin {
                    Logger.default.debug("[BIOMETRIC] requesting biometric auth")
                    NotificationCenter.default.post(name: .requestBiometricAuthentiction, object: nil)
                }
            }
    }
}
