//
//  ItemCaptureView.swift
//  
//
//  Created by Danis Tazetdinov on 14.02.2022.
//

import Foundation
import SwiftUI
import DataModel
import Localization
import Logger
import AVFoundation

public struct ItemCaptureView: View {
    @Binding var createdItem: Item?
    @Binding var startItemCapture: Bool

    @State private var showCameraPermissionWarning = false
    @State private var showCameraView = false
    @State private var image: UIImage? = nil
    // image is being set by camera capture before camera view is dismissed
    @State private var startingImage: UIImage? = nil

    @Environment(\.presentationMode) private var presentationMode

    private func cameraAccessAllowed() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized || AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
    }

    public init(createdItem: Binding<Item?>, startItemCapture: Binding<Bool>) {
        _createdItem = createdItem
        _startItemCapture = startItemCapture
    }

    public var body: some View {
        Color.clear
            .fullScreenCover(isPresented: $showCameraView) {
                if let image = image {
                    startingImage = image
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            } content: {
                CameraView(image: $image)
            }
            .sheet(isPresented: Binding { startingImage != nil } set: { if !$0 { startingImage = nil } }) {
                if let startingImage = startingImage {
                    NavigationView {
                        ItemDetailsView(item: $createdItem, startingImage: startingImage)
                    }
                } else {
                    EmptyView()
                }
            }
            .onChange(of: startItemCapture) { newValue in
                if newValue {
                    if cameraAccessAllowed() {
                        showCameraView = true
                    } else {
                        showCameraPermissionWarning = true
                    }
                    startItemCapture = false
                }
            }
            .alert(L10n.ItemDetails.noCameraAccessTitle.localized, isPresented: $showCameraPermissionWarning) {
                if UIDevice.current.isMac {
                    Button(role: .cancel) {
                        showCameraPermissionWarning = false
                    } label: {
                        Text(L10n.Common.buttonDismiss.localized)
                    }
                    .keyboardShortcut(.cancelAction)
                } else {
                    Button {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        showCameraPermissionWarning = false
                        UIApplication.shared.open(url, options: [:]) { success in
                            if !success {
                                Logger.default.error("could not open settings")
                            }
                        }
                    } label: {
                        Text(L10n.ItemDetails.buttonOpenSettings.localized)
                    }
                    .keyboardShortcut(.defaultAction)
                    Button(role: .cancel) {
                        showCameraPermissionWarning = false
                    } label: {
                        Text(L10n.Common.buttonCancel.localized)
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
    }
}
