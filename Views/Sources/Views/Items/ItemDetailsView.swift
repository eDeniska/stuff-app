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

// TODO: add appropriate swipe actions to items

public struct ItemDetailsView: View {

    private enum FocusedField {
        case title
        case details
    }

    @StateObject private var itemDetails: ItemViewModel
    private let item: Item?

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
    @State private var removingImageIndex: Int? = nil

    @FocusState private var focusedField: FocusedField?

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\Checklist.title)
                         ],
        animation: .default)
    private var checklists: FetchedResults<Checklist>

    @State private var isEditing: Bool

    private let isNew: Bool

    private var title: String {
        itemDetails.title.isEmpty ? "New item" : itemDetails.title
    }

    public init(item: Item?) {
        self.item = item
        _itemDetails = StateObject(wrappedValue: ItemViewModel(item: item))
        _isEditing = State(wrappedValue: item == nil)
        isNew = item == nil
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

//            Section {
//                Text("Not implemented yet :(")
//            } header: {
//                Text("Color")
//            }

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
                            .frame(minWidth: 300, idealWidth: 400, minHeight: 300, idealHeight: 400)
                    }
                } else {
                    Text(itemDetails.condition.localizedTitle)
                        .id("conditionTitle")
                }
            } header: {
                Text("Condition")
            }

            // TODO: cannot clean place
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
                        PlacePickerView(place: $itemDetails.place)
                            .frame(minWidth: 300, idealWidth: 400, minHeight: 400, idealHeight: 600)
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
                                                removingImageIndex = index
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
                                    .confirmationDialog("Remove the image?", isPresented: Binding {
                                        removingImageIndex == index
                                    } set: { newValue in
                                        if !newValue {
                                            removingImageIndex = nil
                                        }
                                    }, titleVisibility: .visible) {
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
                        viewContext.saveOrRollback()
                        if isNew {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            isEditing.toggle()
                        }
                    } label: {
                        Text("Save")
                            .bold()
                    }
                } else {
                    Button {
                        isEditing.toggle()
                    } label: {
                        Text("Edit")
                    }
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                if isEditing && (horizontalSizeClass != .compact || isNew) {
                    Button(role: .cancel) {
                        if isNew {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            itemDetails.reset()
                            isEditing.toggle()
                        }
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            ToolbarItem {
                if !itemDetails.checklists.isEmpty && !isEditing {
                    Menu {
                        ForEach(checklists) { checklist in
                            Button {
                                itemDetails.add(to: checklist)
                            } label: {
                                Label(checklist.title ?? "", systemImage: checklist.icon ?? "list.bullet.rectangle")
                            }
                            .disabled(checklist.entries?.compactMap { ($0 as? ChecklistEntry)?.item }.contains(item) ?? false)
                        }
                    } label: {
                        Label("Add to checklist", systemImage: "text.badge.plus")
                    }
                    .menuStyle(.borderlessButton)
                }
            }

        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showTakePhoto) {
            CameraView(image: $takenImage)
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(images: $pickedImages, isFetchingImages: $isFetchingImages)
        }
        .disabled(isPredicting || isFetchingImages)
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

    private func takePhoto() {
        showTakePhoto = true
    }
    
    private func addPhoto() {
        showPhotoPicker = true
    }
}
