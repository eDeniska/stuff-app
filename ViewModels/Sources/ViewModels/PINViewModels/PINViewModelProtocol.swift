//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 22.02.2022.
//

import Foundation
import Combine
import LocalAuthentication

public enum PINViewModelAction {
    case next
    case incorrect
    case success
}

public enum PINViewModelLockState {
    case locked
    case unlocked
    case noLock
}


public protocol PINViewModelProtocol: ObservableObject {
    var message: String { get set }
    var lockState: PINViewModelLockState { get set }
    var biometryType: LABiometryType { get }
    func enter(pin: String) -> PINViewModelAction
}
