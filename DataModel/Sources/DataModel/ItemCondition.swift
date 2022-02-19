//
//  ItemCondition.swift
//  
//
//  Created by Danis Tazetdinov on 18.01.2022.
//

import Foundation
import Localization

public enum ItemCondition: String, CaseIterable {
    case brandNew = "010-brandNew"
    case excellent = "020-excellent"
    case good = "030-good"
    case moderate = "040-moderate"
    case poor = "050-poor"
    case damaged = "060-damaged"
    case unknown = "999-unknown"

    public init(storedValue: String?) {
        guard let storedValue = storedValue else {
            self = .unknown
            return
        }

        if let condition = ItemCondition(rawValue: storedValue) {
            self = condition
        } else {
            for condition in ItemCondition.allCases {
                if storedValue == condition.alternateName {
                    self = condition
                    return
                }
            }
            self = .unknown
        }
    }
    
    private var alternateName: String {
        switch self {
        case .unknown:
            return "unknown"
        case .brandNew:
            return "brandNew"
        case .excellent:
            return "excellent"
        case .good:
            return "good"
        case .moderate:
            return "moderate"
        case .poor:
            return "poor"
        case .damaged:
            return "damaged"
        }
    }

    public var localizedTitle: String {
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
    
    public var fullLocalizedTitle: String {
        switch self {

        case .unknown:
            return L10n.ItemCondition.Full.unknown.localized

        case .brandNew:
            return L10n.ItemCondition.Full.brandNew.localized

        case .excellent:
            return L10n.ItemCondition.Full.excellent.localized

        case .good:
            return L10n.ItemCondition.Full.good.localized

        case .moderate:
            return L10n.ItemCondition.Full.moderate.localized

        case .poor:
            return L10n.ItemCondition.Full.poor.localized

        case .damaged:
            return L10n.ItemCondition.Full.damaged.localized
        }
    }
}
