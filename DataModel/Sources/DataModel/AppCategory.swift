//
//  AppCategory.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import Foundation

public enum AppCategory: String, CaseIterable {
    case pets
    case clothers
    case shoes
    case gadgets
    case tableware
    case jewelry
    case accessories
    case books
    case appliances
    case furniture
    case sports
    case tools
    case music
    case other

    public var iconName: String {
        "tshirt"
    }
}
