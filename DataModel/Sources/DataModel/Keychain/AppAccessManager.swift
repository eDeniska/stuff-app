//
//  File.swift
//  
//
//  Created by Данис Тазетдинов on 20.02.2022.
//

import Foundation
import Logger

public class AppAccessManager {
    public static let shared = AppAccessManager()
    
    private enum Constants {
        static let lockPasswordService = "lockPasswordService"
        static let lockPasswordAccount = "lockPasswordAccount"
    }
    
    private init() {
    }
    
    public var isPasswordSet: Bool {
        do {
            return try KeychainPasswordItem(service: Constants.lockPasswordService,
                                            account: Constants.lockPasswordAccount)
                .containsPassword()
        } catch {
            Logger.default.error("could not access password: \(error)")
            return false
        }
    }

    public func clearPassword() {
        do {
            try KeychainPasswordItem(service: Constants.lockPasswordService,
                                     account: Constants.lockPasswordAccount)
                .deleteItem()
        } catch {
            Logger.default.error("could not clear password: \(error)")
        }
    }
    
    public func validate(password: String) -> Bool {
        do {
            return try KeychainPasswordItem(service: Constants.lockPasswordService,
                                            account: Constants.lockPasswordAccount)
                .readPassword() == password
        } catch {
            Logger.default.error("could not access password: \(error)")
            return false
        }
    }
    
    public func set(password: String) {
        do {
            try KeychainPasswordItem(service: Constants.lockPasswordService,
                                     account: Constants.lockPasswordAccount)
                .savePassword(password)
        } catch {
            Logger.default.error("could not access password: \(error)")
        }
    }
}
