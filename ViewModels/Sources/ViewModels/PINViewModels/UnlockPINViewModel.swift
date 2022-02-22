//
//  EnterPINViewModel.swift
//  
//
//  Created by Danis Tazetdinov on 22.02.2022.
//

import Foundation
import Combine
import DataModel
import LocalAuthentication
import Localization

public class UnlockPINViewModel: PINViewModelProtocol {

    @Published public var message: String
    @Published public var lockState = PINViewModelLockState.locked
    public let biometryType: LABiometryType

    private let protectionViewModel = PINProtectionViewModel()
    private let completionHandler: () -> Void


    public init(completionHandler: @escaping () -> Void) {
        self.completionHandler = completionHandler
        message = L10n.PINViewModel.unlock.localized
        biometryType = protectionViewModel.biometryType
    }

    public func enter(pin: String) -> PINViewModelAction {
        guard AppAccessManager.shared.isPasswordSet else {
            return .incorrect
        }

        guard pin.count == 6 else {
            return .incorrect
        }

        guard AppAccessManager.shared.validate(password: pin) else {
            message = L10n.PINViewModel.incorrectPIN.localized
            return .incorrect
        }

        defer {
            completionHandler()
        }
        return .success
    }

}
