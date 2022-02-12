//
//  ItemCondition.swift
//  
//
//  Created by Danis Tazetdinov on 18.01.2022.
//

import Foundation
import Localization

public enum ItemCondition: String, CaseIterable {
    case unknown
    case brandNew
    case excellent
    case good
    case moderate
    case poor
    case damaged

    public var localizedTitle: String { // TODO: use proper localization
        switch self {

        case .unknown:
            return L10n.ItemCondition.unknown.localized

        case .brandNew:
            return L10n.ItemCondition.brandNew.localized

        case .excellent:
            return L10n.ItemCondition.excellent.localized

        case .good:
            return L10n.ItemCondition.good.localized

        case .moderate:
            return L10n.ItemCondition.moderate.localized

        case .poor:
            return L10n.ItemCondition.poor.localized

        case .damaged:
            return L10n.ItemCondition.damaged.localized
        }
    }
}
