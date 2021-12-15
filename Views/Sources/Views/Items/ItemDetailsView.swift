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
            Text(item.title ?? "Unnamed item")
            ScrollView(.vertical, showsIndicators: true) {
                Text(detectedInformation)
            }
            Spacer()
            if !selectedImages.isEmpty {
                GroupBox {
                    VStack{
                        Text("Images")
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
        .fullScreenCover(isPresented: $showTakePhoto) {
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
            Task {
                var filteredPredictions: [ItemPrediction] = []
                var predictedText = ""
                for image in images {
                    let predictions = try? await imagePredictor.makePredictions(for: image)
                    filteredPredictions.append(contentsOf: predictions ?? [])

                }

                predictedText.append(contentsOf: "raw results:\n")
                for prediction in filteredPredictions {
                    predictedText.append("\(prediction.detectedItem.description) [[ \(prediction.classification) ]] (\(prediction.confidence))\n")
                }

                predictedText.append(contentsOf: "filtered results:\n")
                for prediction in filteredPredictions.aggregate() where prediction.confidence > 0.15 {
                    predictedText.append("\(prediction.detectedItem.description) [[ \(prediction.classification) ]] (\(prediction.confidence))\n")
                }
                self.detectedInformation = predictedText
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
