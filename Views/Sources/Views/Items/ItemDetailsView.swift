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
import Logger

extension Int: Identifiable {
    public var id: Int { self }
}

public struct ItemDetailsView: View {

    private enum FocusedField {
        case title
        case details
    }

    @StateObject private var itemDetails: ItemViewModel

    @State private var showPhotoPicker = false
    @State private var showTakePhoto = false
    @State private var showPhotoSourcePikcer = false
    @State private var showCategoryPicker = false
    @State private var showPlacePicker = false
    @State private var showConditionPicker = false

    @State private var takenImage: UIImage?
    @State private var pickedImages: [UIImage] = []

    @State private var isPredicting = false
    @State private var isFetchingImages = false

    @FocusState private var focusedField: FocusedField?

    @Environment(\.editMode) private var editMode
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    public init(item: Item?) {
        _itemDetails = StateObject(wrappedValue: ItemViewModel(item: item))
    }

    public var body: some View {
        Form {
            Section {
                if isEditing {
                    TextField("Item title", text: $itemDetails.title)
                        .focused($focusedField, equals: .title)
                        .id("title")
                } else {
                    Text(itemDetails.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id("title")
                }
            } header: {
                Text("Item")
            }

            Section {
                if isEditing {
                    Button {
                        showCategoryPicker = true
                    } label: {
                        HStack {
                            Text(itemDetails.category.title)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .id("categoryTitle")
                    .popover(isPresented: $showCategoryPicker) {
                        CategoryPickerView(category: $itemDetails.category)
                            .frame(minWidth: 300, idealWidth: 400, minHeight: 400, idealHeight: 600)
                    }
                } else {
                    Text(itemDetails.category.title)
                        .id("categoryTitle")
                }
            } header: {
                Text("Category")
            }

            Section {
                if isEditing {
                    TextField("Item details", text: $itemDetails.details)
                        .focused($focusedField, equals: .details)
                        .id("details")

                } else {
                    Text(itemDetails.details)
                        .id("details")
                }
            } header: {
                Text("Details")
            }

            Section {
                Text("Not implemented yet :(")
            } header: {
                Text("Color")
            }

            Section {
                if isEditing {
                    Button {
                        showConditionPicker = true
                    } label: {
                        HStack {
                            Text(itemDetails.condition.localizedTitle)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .id("conditionTitle")
                    .popover(isPresented: $showConditionPicker) {
                        ConditionPicker(itemCondition: $itemDetails.condition)
                            .frame(minWidth: 300, minHeight: 400)
                    }
                } else {
                    Text(itemDetails.condition.localizedTitle)
                        .id("conditionTitle")
                }
            } header: {
                Text("Condition")
            }

            Section {
                if isEditing {
                    Button {
                        showPlacePicker = true
                    } label: {
                        HStack {
                            Text(itemDetails.place?.title ?? "<Place not set>")
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .id("placeTitle")
                    .popover(isPresented: $showPlacePicker) {
                        PlacePicker(place: $itemDetails.place)
                        .frame(minWidth: 300, minHeight: 400)
                    }
                } else {
                    Text(itemDetails.place?.title ?? "<Place not set>")
                        .id("placeTitle")
                }
            } header: {
                Text("Place")
            }

            if !itemDetails.images.isEmpty || isEditing {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(itemDetails.images.enumerated()), id: \.0) { index, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay(alignment: .topTrailing) {
                                        if isEditing {
                                            Button(role: .destructive) {
                                                itemDetails.showDeletePicker[index] = true
                                            } label: {
                                                Image(systemName: "xmark.circle")
                                                    .font(.largeTitle)
                                                    .shadow(color: .black, radius: 2, x: 0, y: 0)
                                                    .padding(4)
                                                    .contentShape(Rectangle())
                                            }
                                            .accessibilityLabel(Text("Remove image at index \(index)"))

                                        } else {
                                            EmptyView()
                                        }
                                    }
                                    .confirmationDialog("Remove the image?", isPresented: $itemDetails.showDeletePicker[index], titleVisibility: .visible) {
                                        Button(role: .destructive) {
                                            itemDetails.removeImage(at: index)
                                        } label: {
                                            Text("Remove")
                                        }
                                    }
                            }
                            if isEditing {
                                Button {
                                    showPhotoSourcePikcer = true
                                } label: {
                                    Rectangle()
                                        .fill(Color.secondary)
                                        .frame(width: 200, height: 200)
                                        .cornerRadius(8)
                                        .overlay {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.largeTitle)
                                                .padding(4)
                                                .foregroundColor(.primary)
                                        }
                                        .contentShape(Rectangle())
                                }
                                .accessibilityLabel(Text("Add image"))
                                .confirmationDialog("Add photos of the item.", isPresented: $showPhotoSourcePikcer, titleVisibility: .visible) {
                                    Button {
                                        takePhoto()
                                    } label: {
                                        Label("Take photo...", systemImage: "camera")
                                    }

                                    Button {
                                        addPhoto()
                                    } label: {
                                        Label("Choose from library...", systemImage: "photo.on.rectangle.angled")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                } header: {
                    Text("Images")
                }
            }
        }
        .simultaneousGesture(DragGesture().onChanged { _ in
            focusedField = nil
        })
//        .simultaneousGesture(TapGesture().onEnded { _ in
//            focusedField = nil
//        })
        .disabled(isPredicting || isFetchingImages)
        .overlay(ZStack(alignment: .center) {
            if isPredicting || isFetchingImages {
                VStack {
                    ProgressView(isPredicting ? "Predicting..." : "Fetching images...")
                        .progressViewStyle(.circular)
                }
                .padding()
                .background(Material.regular)
                .cornerRadius(8)
            }
        })
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if isEditing {
                    Button {
                        itemDetails.save(in: viewContext)
                        do {
                            try viewContext.save()
                        } catch {
                            Logger.default.log(.error, "Could not save context: \(error)")
                        }
                        editMode?.wrappedValue = .inactive
                    } label: {
                        Text("Save")
                    }
                } else {
                    EditButton()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showTakePhoto) {
            CameraView(image: $takenImage)
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(images: $pickedImages, isFetchingImages: $isFetchingImages)
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
        .onChange(of: itemDetails.images) { images in
            guard itemDetails.title.isEmpty && itemDetails.category == .predefined(.other) else {
                return
            }
            isPredicting = true
            Task {
                await itemDetails.predict()
                isPredicting = false
            }
        }
    }

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    private func takePhoto() {
        showTakePhoto = true
    }
    
    private func addPhoto() {
        showPhotoPicker = true
    }
}

extension Optional {
    func asBoolBinding() -> Binding<Bool> {
        Binding {
            self != nil
        } set: { _ in
        }
    }
}
