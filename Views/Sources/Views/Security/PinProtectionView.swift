//
//  File.swift
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

public struct PinProtectionView: View {

    private let onUnlock: () -> Void

    @State private var pin = ""
    @State private var state: PinKeypadView.LockState = .locked

    @StateObject private var viewModel = PinProtectionViewModel()
    @State private var processingBiometrics = false
    @State private var cancelledBiometrics = false

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
        GeometryReader { proxy in
            if UIDevice.current.isMac {
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
                        SecureField(L10n.PinProtection.passwordPlaceholder.localized, text: $pin)
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
            } else {
                VStack {
                    Spacer()
                    PinKeypadView(pin: $pin, message: $viewModel.message, state: $state, biometryType: viewModel.biometryType) { entered in
                        if viewModel.authenticateWithPassword(entered) {
                            pin = ""
                            onUnlock()
                            return true
                        } else {
                            return false
                        }
                    } biometryAction: {
                        Task {
                            if try await viewModel.authenticateWithBiometrics() {
                                pin = ""
                                cancelledBiometrics = false
                                onUnlock()
                            }
                        }
                    }
                    .frame(height: height(for: proxy.size), alignment: .center)
                    Spacer()
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
                        }
                    } catch {
                        Logger.default.error("[BIOMETRIC] could not perform biometric: \(error)")
                        cancelledBiometrics = true
                    }
                    processingBiometrics = false
                }
            }
    }
}
