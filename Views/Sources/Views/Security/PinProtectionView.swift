//
//  File.swift
//  
//
//  Created by Данис Тазетдинов on 20.02.2022.
//

import SwiftUI
import LocalAuthentication

public struct PinProtectionView: View {
    
    public var body: some View {
        EmptyView()
    }
}

//if biometryType() != .none {
//    Button {
//        LAContext().evaluatePolicy(
//            .deviceOwnerAuthenticationWithBiometricsOrWatch
//            , localizedReason: "Authenticate the app") { success, error in
//            Logger.default.info("\(success)")
//        }
//        
//    } label: {
//        switch biometryType() {
//        case .faceID:
//            Image(systemName: "faceid")
//            
//        case .touchID:
//            Image(systemName: "touchid")
//            
//        case .none:
//            EmptyView()
//
//        @unknown default:
//            EmptyView()
//        }
//    }
//    .imageScale(.large)
//}
//private func biometryType() -> LABiometryType {
//    let context = LAContext()
//    var error: NSError? = nil
//    if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, error: &error) {
//        Logger.default.error(error)
//    }
//    Logger.default.info("\(String (describing: LAContext().biometryType)) - \(LAContext().biometryType.rawValue)")
//    return LAContext().biometryType
//}

