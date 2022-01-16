//
//  ItemDetailsView.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import Combine
import DataModel
import CoreData
import ImageRecognizer

extension AppCategory: Identifiable {
    public var id: AppCategory {
        self
    }
}

public struct ItemDetailsView: View {
    @StateObject private var itemDetails: ItemViewModel

    @State private var showPhotoPicker = false
    @State private var showTakePhoto = false
    @State private var takenImage: UIImage?
    @State private var pickedImages: [UIImage] = []

    @State private var detectedInformation = ""
    @State private var isCategoryListExpanded = false

    @Environment(\.editMode) private var editMode
    @Environment(\.presentationMode) private var presentationMode

    private let imagePredictor = ImagePredictor()

    public init(item: Item?) {
        _itemDetails = StateObject(wrappedValue: ItemViewModel(item: item))
    }

    public var body: some View {
        Form {
            Section {
                if editMode?.wrappedValue.isEditing ?? false {
                    TextField("Item title", text: $itemDetails.title)
                } else {
                    Text(itemDetails.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } header: {
                Text("Item")
            }
            if editMode?.wrappedValue.isEditing ?? false {
                CategoryPickerView(category: $itemDetails.category)
            } else {
                Section {
                    Text(itemDetails.category.title)
                } header: {
                    Text("Category")
                }
            }

            Section {
                if editMode?.wrappedValue.isEditing ?? false {
                    TextEditor(text: $itemDetails.details)
                } else {
                    Text(itemDetails.details)
                }
            } header: {
                Text("Details")
            }
            Section {
                Text(detectedInformation)
            }

            Section {
                if !itemDetails.images.isEmpty {
                    GroupBox {
                        VStack{
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack(alignment: .center) {
                                    ForEach(itemDetails.images) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 200, height: 200)
                                            .clipped()
                                    }
                                }
                            }
                        }
                    } label: {
                        Text("Images")
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("Save", systemImage: "checkmark")
                }
            }
        }
        .fullScreenCover(isPresented: $showTakePhoto) {
            CameraView(image: $takenImage)
        }
        .popover(isPresented: $showPhotoPicker) {
            PhotoPicker(images: $pickedImages)
        }
        .onAppear {
            print(FileStorageManager.shared.urls(withPrefix: "S"))
        }
        .onChange(of: takenImage) { image in
            guard let image = image else {
                return
            }
            itemDetails.addImage(image)
        }
        .onChange(of: pickedImages) { images in
            itemDetails.addImages(images)
        }
        .onChange(of: itemDetails.images) { _ in
            Task {
                await itemDetails.predict()
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
