//
//  ManagePasswordViewModel.swift
//  
//
//  Created by Danis Tazetdinov on 21.02.2022.
//

import Foundation
import Combine
import Logger
import DataModel

public class ManagePasswordViewModel: ObservableObject {

    public enum ChangeResult {
        case success
        case incorrectExisting
        case passwordsNotMatch
        case emptyPassword
    }

    public enum ClearResult {
        case success
        case incorrectExisting
    }

    public enum SetResult {
        case success
        case passwordIsSet
        case passwordsNotMatch
        case emptyPassword
    }

    public init() {
    }

    public func passwordIsSet() -> Bool {
        AppAccessManager.shared.isPasswordSet
    }

    private func isValid(password: String) -> Bool {
        !password.isEmpty
    }

    public func clearPassword(existing: String) -> ClearResult {
        guard AppAccessManager.shared.validate(password: existing) else {
            return .incorrectExisting
        }

        AppAccessManager.shared.clearPassword()
        return .success
    }

    public func setPassword(password: String, repeated: String) -> SetResult {
        guard !AppAccessManager.shared.isPasswordSet else {
            return .passwordIsSet
        }
        guard password == repeated else {
            return .passwordsNotMatch
        }
        guard isValid(password: password) else {
            return .emptyPassword
        }

        AppAccessManager.shared.set(password: password)
        return .success
    }


    public func changePassword(existing: String, password: String, repeated: String) -> ChangeResult {
        guard AppAccessManager.shared.validate(password: existing) else {
            return .incorrectExisting
        }
        guard password == repeated else {
            return .passwordsNotMatch
        }
        guard isValid(password: password) else {
            return .emptyPassword
        }

        AppAccessManager.shared.set(password: password)
        return .success
    }
}
