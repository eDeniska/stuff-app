//
//  PinProtectionViewModel.swift
//  
//
//  Created by Данис Тазетдинов on 20.02.2022.
//

import DataModel
import Combine
import LocalAuthentication
import Logger
import Localization

public class PinProtectionViewModel: ObservableObject {
    
    public static func protectionIsSet() -> Bool {
        AppAccessManager.shared.isPasswordSet
    }
    
    private let context: LAContext
    
    public var biometryType: LABiometryType {
        context.biometryType
    }
    
    public init() {
        context = LAContext()
        var error: NSError? = nil
        if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, error: &error) {
            Logger.default.error("could not authenticate with biometrics or watch")
            if let error = error {
                Logger.default.error("error: \(error)")
            }
        }
    }
    
    public func authenticateWithBiometrics() async throws -> Bool {
        guard context.biometryType != .none else {
            return false
        }
        // TODO: localize biometry reason
        return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, localizedReason: L10n.Protection.biometryReason.localized)
    }
    
    public func authenticateWithPassword(_ password: String) -> Bool {
        AppAccessManager.shared.validate(password: password)
    }

}
