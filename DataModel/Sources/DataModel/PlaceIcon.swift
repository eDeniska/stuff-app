//
//  PlaceIcon.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import Foundation

public enum PlaceIcon: String, CaseIterable, Identifiable {
    case house = "house"
    case building = "building"
    case building2 = "building.2"
    case box = "shippingbox"
    case bag2 = "archivebox"
    case studentdesk = "studentdesk"
    case bed = "bed.double"
    case cross = "cross"
    case briefcase4 = "cross.case"
    case pills = "pills"
    case bag = "bag"
    case globe = "globe"
    case tv = "sparkles.tv"
    case folder = "folder"
    case tray = "tray"
    case tray2 = "tray.2"
    case briefcase = "briefcase"
    case briefcase2 = "latch.2.case"
    case briefcase3 = "suitcase"
    case car = "car"
    case gift = "gift"

    public var id: String {
        rawValue
    }
}
