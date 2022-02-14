//
//  AssetPagedView.swift
//  LifeViews
//
//  Created by Danis Tazetdinov on 07.10.2020.
//  Copyright © 2020 EPAM Systems. All rights reserved.
//

import SwiftUI
import Combine
import Localization

struct ImagesPagedView: View {

    @Environment(\.presentationMode) private var presentationMode

    private let images: [UIImage]
    @State private var currentIndex: Int
    
    init(images: [UIImage], index: Int) {
        self.images = images
        _currentIndex = State(initialValue: index)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $currentIndex) {
                    ForEach(0..<images.count) { index in
                        AssetView(asset: .image(images[index]))
                            .background(Color.clear)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea([.bottom, .horizontal])
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .navigationBarTitle(Text("\(currentIndex + 1) / \(images.count)")
                                    , displayMode: .inline
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .cancel) {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text(L10n.Common.buttonDismiss.localized)
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        // this needs attention, if app needs support for RTL
                        Button {
                            withAnimation {
                                if currentIndex > 0 {
                                    currentIndex -= 1
                                }
                            }
                        } label: {
                            Text(L10n.PhotoViewer.previous.localized)
                        }
                        .disabled(currentIndex == 0)
                        .keyboardShortcut(.leftArrow, modifiers: [])
                        
                        Button {
                            withAnimation {
                                if currentIndex < images.count - 1 {
                                    currentIndex += 1
                                }
                            }
                        } label: {
                            Text(L10n.PhotoViewer.next.localized)
                        }
                        .disabled(currentIndex == images.count - 1)
                        .keyboardShortcut(.rightArrow, modifiers: [])
                    }
                }
            }
        }
    }
}

