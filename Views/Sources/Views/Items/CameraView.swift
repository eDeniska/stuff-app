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

public class CameraMarkerViewController: UIViewController {
}

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
        let vc = CameraMarkerViewController()
        vc.addChild(imagePickerVC)
        vc.view.addSubview(imagePickerVC.view)
        imagePickerVC.didMove(toParent: vc)
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
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
