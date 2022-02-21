//
//  File.swift
//  
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import Foundation
import Localization

extension L10n {
    enum Item: String, Localizable {
        case unnamed = "item.unnamed"
    }
    
    enum Protection: String, Localizable {
        case biometryReason = "protection.biometry.reason"
        case messageAuthenticate = "protection.message.authenticate"
        case messageUnlocked = "protection.message.unlocked"
        case messageIncorrectPIN = "protection.message.incorrectPIN"
        case messageIncorrectPassword = "protection.message.incorrectPassword"
    }
}
