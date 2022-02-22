//
//  ChangePINViewModel.swift
//  
//
//  Created by Danis Tazetdinov on 22.02.2022.
//

import Foundation
import Combine
import DataModel
import LocalAuthentication
import Localization

public class ChangePINViewModel: PINViewModelProtocol {

    @Published public var message: String
    @Published public var lockState = PINViewModelLockState.locked
    public let biometryType = LABiometryType.none

    private var existingPINValidated = false
    private var firstPIN = ""

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

        guard existingPINValidated else {
            guard AppAccessManager.shared.validate(password: pin) else {
                return .incorrect
            }
            existingPINValidated = true
            lockState = .unlocked
            message = L10n.PINViewModel.enterNewPIN.localized
            return .next
        }

        guard !firstPIN.isEmpty else {
            firstPIN = pin
            message = L10n.PINViewModel.repeatPIN.localized
            return .next
        }

        guard firstPIN == pin else {
            return .incorrect
        }

        AppAccessManager.shared.set(password: pin)
        return .success
    }

}
