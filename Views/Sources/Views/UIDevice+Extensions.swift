//
//  UIDevice+Extensions.swift
//  
//
//  Created by Danis Tazetdinov on 19.01.2022.
//

import UIKit

public extension UIDevice {
    var isPhone: Bool {
        userInterfaceIdiom == .phone
    }

    var isMac: Bool {
        userInterfaceIdiom == .mac
    }
}
