//
//  AppCategory.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import Foundation
import Localization

public enum AppCategory: String, CaseIterable, Identifiable {
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
            return "figure.walk" // TODO: reconsider other options

        case .gadgets:
            return "laptopcomputer.and.iphone"

        case .tableware:
            return "fork.knife"

        case .jewelry:
            return "aqi.medium"

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
            return "tag"
        }
    }

    public var localizedTitle: String {
        switch self {
        case .pets:
            return L10n.AppCategory.pets.localized
        case .clothers:
            return L10n.AppCategory.clothers.localized
        case .shoes:
            return L10n.AppCategory.shoes.localized
        case .gadgets:
            return L10n.AppCategory.gadgets.localized
        case .tableware:
            return L10n.AppCategory.tableware.localized
        case .jewelry:
            return L10n.AppCategory.jewelry.localized
        case .accessories:
            return L10n.AppCategory.accessories.localized
        case .books:
            return L10n.AppCategory.books.localized
        case .appliances:
            return L10n.AppCategory.appliances.localized
        case .furniture:
            return L10n.AppCategory.furniture.localized
        case .sports:
            return L10n.AppCategory.sports.localized
        case .tools:
            return L10n.AppCategory.tools.localized
        case .music:
            return L10n.AppCategory.music.localized
        case .other:
            return L10n.AppCategory.other.localized
        }
    }

    public var id: String {
        rawValue
    }

    public var sortOrder: Int {
        switch self {

        case .pets, .clothers, .shoes, .gadgets, .tableware, .jewelry, .accessories, .books, .appliances, .furniture, .sports, .tools, .music:
            return 0
        case .other:
            return -999
        }
    }
}
