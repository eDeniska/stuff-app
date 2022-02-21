//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 21.02.2022.
//

import SwiftUI
import Logger

public struct SizePreferenceKey: PreferenceKey {
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }

    public static var defaultValue = CGSize.zero
}

public extension View {
    func withSize(_ sizeHandler: @escaping (CGSize) -> ()) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
                    .onAppear {
                        Logger.default.debug("measuring \(self) -> \(proxy.size)")
                    }
            }
        }
        .onPreferenceChange(SizePreferenceKey.self, perform: sizeHandler)
    }
}


