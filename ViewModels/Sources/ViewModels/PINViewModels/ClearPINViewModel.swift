//
//  ClearPINViewModel.swift
//  
//
//  Created by Danis Tazetdinov on 22.02.2022.
//

import Foundation
import Combine
import DataModel
import LocalAuthentication
import Localization

public class ClearPINViewModel: PINViewModelProtocol {

    @Published public var message: String
    @Published public var lockState = PINViewModelLockState.noLock
    public let biometryType = LABiometryType.none

    public init() {
        message = L10n.PINViewModel.enterExistingPIN.localized
    }

    public func enter(pin: String) -> PINViewModelAction {
        guard AppAccessManager.shared.isPasswordSet else {
            return .incorrect
        }

        guard pin.count == 6 else {
            return .incorrect
        }

        guard AppAccessManager.shared.validate(password: pin) else {
            return .incorrect
        }

        AppAccessManager.shared.clearPassword()
        lockState = .unlocked
        return .success
    }

}
