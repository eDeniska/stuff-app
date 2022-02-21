//
//  ShakeModifier.swift
//  
//
//  Created by Danis Tazetdinov on 21.02.2022.
//

import SwiftUI

struct ShakeModifier: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 4
    var percentage: CGFloat
    var completion: (() -> Void)? = nil
    var animatableData: CGFloat {
        get {
            percentage
        }
        set {
            percentage = newValue
            checkIfCompleted()
        }
    }

    func checkIfCompleted() {
        if percentage == 1 {
            completion?()
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                              y: 0)
        )
    }
}
