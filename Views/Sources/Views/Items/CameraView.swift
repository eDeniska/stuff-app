//
//  CameraView.swift
//  
//
//  Created by Danis Tazetdinov on 10.12.2021.
//

import SwiftUI
import PhotosUI

// TODO: check, if this might solve issues with iPhone
extension UIImagePickerController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

struct CameraView: UIViewControllerRepresentable {

    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = context.coordinator
        imagePickerVC.mediaTypes = [UTType.image.identifier]
        imagePickerVC.sourceType = .camera
        imagePickerVC.cameraCaptureMode = .photo
        imagePickerVC.showsCameraControls = true
        imagePickerVC.allowsEditing = true
        return imagePickerVC
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
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
