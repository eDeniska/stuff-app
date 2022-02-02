//
//  ChecklistIcon.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import Foundation

public enum ChecklistIcon: String, CaseIterable, Identifiable {
    case dash = "list.dash"
    case bullet = "list.bullet"
    case triangle = "list.triangle"
    case checklist = "checklist"
    case square = "square.text.square"
    case menucard = "menucard"
    case note = "note.text"
    case doc = "doc.plaintext"
    case doc2 = "doc.text.below.ecg"
    case book = "text.book.closed"
    case health = "heart.text.square"
    case bag1 = "case"
    case bag2 = "latch.2.case"
    case bag3 = "briefcase"
    case bag4 = "suitcase"
    case bag5 = "suitcase.cart"
    case bag6 = "cross.case"
    case house = "house"
    case building = "building"
    case building2 = "building.2"
    case sun = "sun.max"
    case cloud = "cloud.sun.rain"
    case photo = "photo"

    public var id: String {
        rawValue
    }
}
