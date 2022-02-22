//
//  SetPINViewModel.swift
//  
//
//  Created by Danis Tazetdinov on 22.02.2022.
//

import Foundation
import Combine
import DataModel
import LocalAuthentication
import Localization

public class SetPINViewModel: PINViewModelProtocol {

    @Published public var message: String
    @Published public var lockState = PINViewModelLockState.noLock
    public let biometryType = LABiometryType.none

    private var firstPIN = ""

    public init() {
        message = L10n.PINViewModel.enterPIN.localized
    }

    public func enter(pin: String) -> PINViewModelAction {
        guard !AppAccessManager.shared.isPasswordSet else {
            return .incorrect
        }
        guard pin.count == 6 else {
            return .incorrect
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
