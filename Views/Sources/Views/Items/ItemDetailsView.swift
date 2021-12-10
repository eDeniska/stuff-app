//
//  ItemDetailsView.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import DataModel
import CoreData
import ImageRecognizer

public struct ItemDetailsView: View {
    private let item: Item

    @State private var showPhotoPicker = false
    @State private var showTakePhoto = false
    @State private var selectedImages: [UIImage] = []
    @State private var takenImage: UIImage?

    @State private var detectedInformation = ""

    private let imagePredictor = ImagePredictor()

    public init(item: Item) {
        self.item = item
    }

    public var body: some View {
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Text(detectedInformation)
            Spacer()
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .center) {
                    ForEach(selectedImages) { image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 200)
                            .clipped()
                    }

                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: takePhoto) {
                    Label("Take Photo", systemImage: "camera")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addPhoto) {
                    Label("Add Photo", systemImage: "plus")
                }
            }
        }
        .popover(isPresented: $showTakePhoto) {
            CameraView(image: $takenImage)
        }
        .popover(isPresented: $showPhotoPicker) {
            PhotoPicker(images: $selectedImages)
        }
        .onChange(of: takenImage) { image in
            guard let image = image else {
                return
            }
            selectedImages.insert(image, at: 0)
        }
        .onChange(of: selectedImages) { images in
            guard let image = images.first else {
                return
            }
            try? imagePredictor.makePredictions(for: image) { predictions in
                var predictedText = ""
                for prediction in predictions ?? [] where prediction.confidencePercentage > 0.1 {
                    predictedText.append("\(prediction.classification) (\(prediction.confidencePercentage))\n")

                }
                DispatchQueue.main.async {
                    self.detectedInformation = predictedText
                }
            }
        }
    }
    private func takePhoto() {
        showTakePhoto = true
    }
    private func addPhoto() {
        showPhotoPicker = true
    }
}

extension UIImage: Identifiable {
    public var id: UIImage {
        self
    }
}

//struct ItemDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemDetailsView()
//    }
//}
