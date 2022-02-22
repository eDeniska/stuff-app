//
//  PINProtectionView.swift
//  
//
//  Created by Данис Тазетдинов on 20.02.2022.
//

import SwiftUI
import LocalAuthentication
import ViewModels
import Logger
import Localization

public extension Notification.Name {
    static let requestBiometricAuthentiction = Notification.Name("RequestBiometricAuthentictionNotification")
}

public struct PINProtectionView: View {

    private let onUnlock: () -> Void

    @State private var pin = ""
    @State private var state: PINViewModelLockState = .locked

    @StateObject private var viewModel = PINProtectionViewModel()
    @State private var processingBiometrics = false
    @State private var cancelledBiometrics = false

    @FocusState private var passwordFocused: Bool

    public init(onUnlock: @escaping () -> Void) {
        self.onUnlock = onUnlock
    }

    private func height(for size: CGSize) -> CGFloat {
        if UIDevice.current.isPhone {
            return size.height
        } else {
            return max(size.width, size.height) / 2
        }
    }

    @ViewBuilder
    private func passwordView() -> some View {
        if UIDevice.current.isMac {
            GeometryReader { proxy in
                HStack {
                    Spacer()
                    VStack(spacing: 40) {
                        Spacer()
                        Image(systemName: "lock")
                            .font(.title)
                            .imageScale(.large)
                            .foregroundColor(.secondary)
                        Text(viewModel.message)
                            .font(.title)
                            .foregroundColor(.secondary)
                        SecureField(L10n.PINProtection.passwordPlaceholder.localized, text: $pin)
                            .textContentType(.password)
                            .focused($passwordFocused)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                            .frame(width: proxy.size.width / 3, alignment: .center)
                            .onSubmit {
                                if viewModel.authenticateWithPassword(pin) {
                                    pin = ""
                                    onUnlock()
                                } else {
                                    pin = ""
                                }
                            }
                        Spacer()
                    }
                    Spacer()
                }
            }
        } else {
            ManagePINView(viewModel: UnlockPINViewModel(completionHandler: onUnlock), showsCancel: false) {
                Task {
                    if try await viewModel.authenticateWithBiometrics() {
                        pin = ""
                        cancelledBiometrics = false
                        onUnlock()
                    }
                }
            }
        }
    }

    public var body: some View {
        passwordView()
            .onReceive(NotificationCenter.default.publisher(for: .requestBiometricAuthentiction, object: nil).receive(on: DispatchQueue.main)) { _ in
                Logger.default.debug("[BIOMETRIC] attempting")
                guard !processingBiometrics && !cancelledBiometrics else {
                    Logger.default.debug("[BIOMETRIC] skip - already processing")
                    return
                }
                Logger.default.debug("[BIOMETRIC] trying - not processing previously")
                processingBiometrics = true
                Task {
                    do {
                        if try await viewModel.authenticateWithBiometrics() {
                            pin = ""
                            cancelledBiometrics = false
                            onUnlock()
                        } else {
                            cancelledBiometrics = true
                            passwordFocused = true
                        }
                    } catch {
                        Logger.default.error("[BIOMETRIC] could not perform biometric: \(error)")
                        cancelledBiometrics = true
                        passwordFocused = true
                    }
                    processingBiometrics = false
                }
            }
    }
}
