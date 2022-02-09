//
//  WindowReader.swift
//  
//
//  Created by Danis Tazetdinov on 08.02.2022.
//

import SwiftUI

public extension View {
    func withWindow(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        background(WindowReader(reader: callback))
    }
}

struct WindowReader: UIViewRepresentable {
    var reader: (UIWindow?) -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            reader(view.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            reader(uiView.window)
        }
    }
}

