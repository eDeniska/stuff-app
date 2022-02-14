//
//  AssetView.swift
//  LifeViews
//
//  Created by Eugene Grebnev on 6/10/20.
//  Copyright © 2020 EPAM Systems. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import UIKit

struct AssetView: View {
    
    private let asset: PresentableAsset
    
    init(asset: PresentableAsset) {
        self.asset = asset
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                mediaElementContainer(size: proxy.size)
                    .transition(.opacity)
            }
        }
    }

    @ViewBuilder private func mediaElementContainer(size: CGSize) -> some View {
        switch asset {
        case .image(let image):
            ImageView(image: image)
                .frame(width: size.width)
        }
    }
}

private class ZoomingCoordinator {
    private var zoom: CGFloat = 1.0
    private var origin: CGPoint = .zero
    private var translation: CGPoint = .zero
    private var oldPosition: CGPoint? = nil

    init() {
    }
    
    @objc
    func handlePinch(_ gr: UIPinchGestureRecognizer) {
        guard let view = gr.view, let subview = view.subviews.first else {
            return
        }
        
        guard gr.numberOfTouches >= 2 else {
            zoom = 1.0
            translation = .zero
            UIView.animate(withDuration: 0.3) {
                subview.transform = .identity
                subview.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                if let position = self.oldPosition {
                    subview.layer.position = position
                    self.oldPosition = nil
                }
            }
            return
        }

        switch gr.state {
            
        case .possible:
            break

        case .began:
            origin = gr.location(in: view)
            oldPosition = subview.layer.position
            subview.setAnchorPoint(CGPoint(x: origin.x / subview.bounds.width, y: origin.y / subview.bounds.height))
            translation = .zero
            zoom = gr.scale

        case .changed:
            zoom = gr.scale
            translation = CGPoint(x: gr.location(in: view).x - origin.x, y: gr.location(in: view).y - origin.y)
            UIView.animate(withDuration: 0.1) {
                subview.transform = self.transform()
            }

        case .ended, .cancelled, .failed:
            zoom = 1.0
            translation = .zero
            UIView.animate(withDuration: 0.3) {
                subview.transform = .identity
                subview.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                if let position = self.oldPosition {
                    subview.layer.position = position
                    self.oldPosition = nil
                }
            }

        @unknown default:
            zoom = 1.0
            translation = .zero
            UIView.animate(withDuration: 0.3) {
                subview.transform = .identity
                subview.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                if let position = self.oldPosition {
                    subview.layer.position = position
                    self.oldPosition = nil
                }
            }
        }
    }

    private func transform() -> CGAffineTransform {
        CGAffineTransform(scaleX: zoom, y: zoom).translatedBy(x: translation.x / zoom, y: translation.y / zoom)
    }
}

private struct ImageView: UIViewRepresentable {
    let image: UIImage

    func makeUIView(context: Context) -> UIView {
        let boundingView = UIView()
        
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        boundingView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: boundingView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: boundingView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: boundingView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: boundingView.bottomAnchor)
        ])
        
        let pinchGR = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(ZoomingCoordinator.handlePinch(_:)))
        boundingView.addGestureRecognizer(pinchGR)
        return boundingView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let view = uiView.subviews.first as? UIImageView else {
            return
        }
        view.image = image
    }
    
    func makeCoordinator() -> ZoomingCoordinator {
        ZoomingCoordinator()
    }
}

extension UIView {
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
}

