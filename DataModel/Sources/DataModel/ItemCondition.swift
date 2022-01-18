//
//  ItemCondition.swift
//  
//
//  Created by Danis Tazetdinov on 18.01.2022.
//

import Foundation

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
            return "unknown"

        case .brandNew:
            return "brand new"

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
}
