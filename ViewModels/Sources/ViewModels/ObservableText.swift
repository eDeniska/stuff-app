//
//  ObservableText.swift
//  
//
//  Created by Danis Tazetdinov on 20.02.2022.
//

import Foundation
import Combine

public class ObservableText: ObservableObject {
    @Published public var text = ""
    public init() { }
}

