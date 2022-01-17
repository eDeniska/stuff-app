//
//  PhotoPicker.swift
//  
//
//  Created by Danis Tazetdinov on 10.12.2021.
//

import SwiftUI
import PhotosUI
import Logger

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Binding var isFetchingImages: Bool

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selection = .ordered
        configuration.selectionLimit = 0
        configuration.filter = .images
        let pickerVC = PHPickerViewController(configuration: configuration)
        pickerVC.delegate = context.coordinator
        return pickerVC
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(photoPicker: self)
    }

    class Coordinator {
        private let photoPicker: PhotoPicker

        init(photoPicker: PhotoPicker) {
            self.photoPicker = photoPicker
        }

    }
}

extension PhotoPicker.Coordinator: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {
        picker.presentingViewController?.dismiss(animated: true)
        photoPicker.isFetchingImages = !results.isEmpty

        var images: [UIImage] = []
        let group = DispatchGroup()
        for result in results where result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            group.enter()
            Logger.default.log(.info, "PHOTO PICKER: item \(result.itemProvider)")
            result.itemProvider.loadObject(ofClass: UIImage.self) { (imageObject, error) in
                if let error = error {
                    Logger.default.log(.error, "PHOTO PICKER: error \(error)")
                }
                guard let image = imageObject as? UIImage else {
                    group.leave()
                    return
                }
                Logger.default.log(.info, "PHOTO PICKER: image \(image)")
                DispatchQueue.main.async {
                    images.append(image)
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            self.photoPicker.images = images
            self.photoPicker.isFetchingImages = false
        }
    }


}
