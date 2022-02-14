//
//  CameraView.swift
//  
//
//  Created by Danis Tazetdinov on 10.12.2021.
//

import SwiftUI
import PhotosUI
import UIKit
import Logger

struct CameraView: UIViewControllerRepresentable {

    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIViewController {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = context.coordinator
        imagePickerVC.mediaTypes = [UTType.image.identifier]
        imagePickerVC.sourceType = .camera
        imagePickerVC.cameraCaptureMode = .photo
        imagePickerVC.showsCameraControls = true
        imagePickerVC.allowsEditing = true
        return imagePickerVC
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // this is hacky, but we need to make sure that UIImagePickerController will revert back to portrait automatically on initial presentation
        if UIDevice.current.isPhone && UIDevice.current.orientation != .portrait {
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: #keyPath(UIDevice.orientation))
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(cameraView: self)
    }

    class Coordinator: NSObject {
        let cameraView: CameraView

        init(cameraView: CameraView) {
            self.cameraView = cameraView
        }
    }
}

extension CameraView.Coordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        cameraView.image = info[.editedImage] as? UIImage
        picker.presentingViewController?.dismiss(animated: true)
    }
}
