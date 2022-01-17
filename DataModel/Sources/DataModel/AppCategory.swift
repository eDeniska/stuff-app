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
        switch self {

        case .pets:
            return "tortoise"

        case .clothers:
            return "tshirt"

        case .shoes:
            return "pawprint" // TODO: reconsider other options

        case .gadgets:
            return "laptopcomputer.and.iphone"

        case .tableware:
            return "fork.knife"

        case .jewelry:
            return "aqi.medium" // TODO: maybe - sun.min 

        case .accessories:
            return "bag"

        case .books:
            return "books.vertical"

        case .appliances:
            return "house"

        case .furniture:
            return "bed.double"

        case .sports:
            return "sportscourt"

        case .tools:
            return "hammer"

        case .music:
            return "guitars"

        case .other:
            return "tray.full"
        }
    }

    public var localizedTitle: String {
        rawValue // TODO: replace with localization
    }
}
