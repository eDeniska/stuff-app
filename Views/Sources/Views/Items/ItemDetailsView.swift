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
import AVFoundation

// TODO: add onSubmit action to save on enter press?

public struct ItemDetailsView: View {

    public static let activityIdentifier = "com.tazetdinov.stuff.item.view"
    public static let identifierKey = "itemID"

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
    @State private var showCameraPermissionWarning = false

    @State private var takenImage: UIImage?
    @State private var pickedImages: [UIImage] = []

    @State private var isPredicting = false
    @State private var isFetchingImages = false
    @State private var removingImageId: String? = nil

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
    @State private var checklistsUnavailable = false

    private let isNew: Bool
    private let allowOpenInSeparateWindow: Bool

    private var title: String {
        itemDetails.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "New item" : itemDetails.title
    }

    private func cameraAccessAllowed() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized || AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
    }

    private func cameraAccessRestricted() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .restricted
    }

    public init(item: Item?, allowOpenInSeparateWindow: Bool = true) {
        self.item = item
        _itemDetails = StateObject(wrappedValue: ItemViewModel(item: item))
        _isEditing = State(wrappedValue: item == nil)
        isNew = item == nil

        self.allowOpenInSeparateWindow = UIApplication.shared.supportsMultipleScenes && allowOpenInSeparateWindow
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox {
                    if isEditing {
                        TextField("Item title", text: $itemDetails.title)
                            .focused($focusedField, equals: .title)
                            .font(.title2)
                            .id("title")
                            .padding(UIDevice.current.isMac ? 8 : 0)
                    } else {
                        Text(itemDetails.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .id("title")
                            .padding(UIDevice.current.isMac ? 8 : 0)
                    }
                } label: {
                    Text("Item")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                GroupBox {
                    if isEditing {
                        if UIDevice.current.isMac {
                            HStack {
                                Text(itemDetails.category.title)
                                    .font(.title2)
                                Spacer()
                                Button {
                                    showCategoryPicker = true
                                } label: {
                                    HStack {
                                        Text("Choose...")
                                            .font(.title2)
                                    }
                                    .contentShape(Rectangle())
                                }
                            }
                            .padding(8)
                            .id("categoryTitle")
                        } else {
                            Button {
                                showCategoryPicker = true
                            } label: {
                                HStack {
                                    Text(itemDetails.category.title)
                                        .font(.title2)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .id("categoryTitle")
                        }
                    } else {
                        Text(itemDetails.category.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .id("categoryTitle")
                            .padding(UIDevice.current.isMac ? 8 : 0)
                    }
                } label: {
                    Text("Category")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .popover(isPresented: $showCategoryPicker) {
                    CategoryPickerView(category: $itemDetails.category)
                        .frame(minWidth: 300, idealWidth: 400, minHeight: 400, idealHeight: 600)
                }

                if !itemDetails.details.isEmpty || isEditing {
                    GroupBox {
                        if isEditing {
                            TextField("Item details", text: $itemDetails.details)
                                .font(.title2)
                                .focused($focusedField, equals: .details)
                                .id("details")
                                .padding(UIDevice.current.isMac ? 8 : 0)
                        } else {
                            Text(itemDetails.details)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title2)
                                .id("details")
                                .padding(UIDevice.current.isMac ? 8 : 0)
                        }
                    } label: {
                        Text("Details")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                GroupBox {
                    if isEditing {
                        if UIDevice.current.isMac {
                            HStack {
                                Text(itemDetails.condition.localizedTitle)
                                    .font(.title2)
                                Spacer()
                                Button {
                                    showConditionPicker = true
                                } label: {
                                    HStack {
                                        Text("Choose...")
                                            .font(.title2)
                                    }
                                    .contentShape(Rectangle())
                                }
                            }
                            .padding(8)
                            .id("conditionTitle")
                        } else {
                            Button {
                                showConditionPicker = true
                            } label: {
                                HStack {
                                    Text(itemDetails.condition.localizedTitle)
                                        .font(.title2)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .id("conditionTitle")
                        }
                    } else {
                        Text(itemDetails.condition.localizedTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .id("conditionTitle")
                            .padding(UIDevice.current.isMac ? 8 : 0)
                    }
                } label: {
                    Text("Condition")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .popover(isPresented: $showConditionPicker) {
                    ConditionPicker(itemCondition: $itemDetails.condition)
                        .frame(minWidth: 300, idealWidth: 400, minHeight: 300, idealHeight: 400)
                }

                GroupBox {
                    if isEditing {
                        if UIDevice.current.isMac {
                            HStack {
                                Text(itemDetails.place?.title ?? "No place is set")
                                    .font(.title2)
                                Spacer()
                                Button {
                                    showPlacePicker = true
                                } label: {
                                    HStack {
                                        Text("Choose...")
                                            .font(.title2)
                                    }
                                    .contentShape(Rectangle())
                                }
                            }
                            .padding(8)
                            .id("conditionTitle")
                        } else {
                            Button {
                                showPlacePicker = true
                            } label: {
                                HStack {
                                    Text(itemDetails.place?.title ?? "No place is set")
                                        .font(.title2)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .id("placeTitle")
                        }
                    } else {
                        Text(itemDetails.place?.title ?? "No place is set")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .id("placeTitle")
                            .padding(UIDevice.current.isMac ? 8 : 0)
                    }
                } label: {
                    Text("Place")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .popover(isPresented: $showPlacePicker) {
                    PlacePickerView(place: $itemDetails.place)
                        .frame(minWidth: 300, idealWidth: 400, minHeight: 400, idealHeight: 600)
                }

                if !itemDetails.images.isEmpty || isEditing {
                    GroupBox {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(itemDetails.images) { image in
                                    Image(uiImage: image.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 200, height: 200)
                                        .clipped()
                                        .cornerRadius(8)
                                        .contentShape(Rectangle())
                                        .onDrag {
                                            let itemProvider = NSItemProvider(object: image.image)
                                            itemProvider.suggestedName = image.suggestedName
                                            return itemProvider
                                        }
                                        .overlay(alignment: .topTrailing) {
                                            if isEditing {
                                                Button(role: .destructive) {
                                                    removingImageId = image.id
                                                } label: {
                                                    Image(systemName: "xmark.circle")
                                                        .foregroundColor(.red)
                                                        .font(.largeTitle)
                                                        .shadow(color: .black, radius: 2, x: 0, y: 0)
                                                        .padding(4)
                                                        .contentShape(Rectangle())
                                                }

                                                .buttonStyle(.plain)
                                                .accessibilityLabel(Text("Remove image?"))

                                            } else {
                                                EmptyView()
                                            }
                                        }
                                        .confirmationDialog("Remove the image?", isPresented: Binding {
                                            removingImageId == image.id
                                        } set: { newValue in
                                            if !newValue {
                                                removingImageId = nil
                                            }
                                        }, titleVisibility: .visible) {
                                            Button(role: .destructive) {
                                                itemDetails.removeImage(with: image.id)
                                            } label: {
                                                Text("Remove")
                                            }
                                        }
                                }
                                if isEditing {
                                    Button {
                                        showPhotoSourcePikcer = true
                                    } label: {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.secondary)
                                            .frame(width: 200, height: 200)
                                            .overlay {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.largeTitle)
                                                    .padding(4)
                                                    .foregroundColor(.primary)
                                            }
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .frame(width: 200, height: 200)
                                    .accessibilityLabel(Text("Add image"))
                                    .confirmationDialog("Add photos of the item", isPresented: $showPhotoSourcePikcer, titleVisibility: .visible) {
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
                                    .alert("Camera access is not allowed", isPresented: $showCameraPermissionWarning) {
                                        if UIDevice.current.isMac {
                                            Button(role: .cancel) {
                                                showCameraPermissionWarning = false
                                            } label: {
                                                Text("Dismiss")
                                            }
                                        } else {
                                            Button {
                                                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                                                    return
                                                }
                                                UIApplication.shared.open(url, options: [:]) { success in
                                                    if !success {
                                                        Logger.default.error("could not open settings")
                                                    }
                                                }
                                            } label: {
                                                Text("Open settings")
                                            }
                                            Button(role: .cancel) {
                                                showCameraPermissionWarning = false
                                            } label: {
                                                Text("Cancel")
                                            }
                                        }
                                    } message: {
                                        Text("You can open Settings and check your permissions.")
                                    }

                                }
                            }
                            .padding(UIDevice.current.isMac ? 8 : 0)
                        }
                        .onDrop(of: [.image], isTargeted: nil) { itemProviders in
                            guard isEditing else {
                                return false
                            }
                            let knownNames = itemDetails.images.map(\.suggestedName)
                            Logger.default.info("drop of \(itemProviders)")
                            for provider in itemProviders {
                                if provider.canLoadObject(ofClass: UIImage.self) {
                                    if let name = provider.suggestedName, knownNames.contains(name) {
                                        Logger.default.info("name = \(name) is known, skipping")
                                        continue
                                    }
                                    provider.loadObject(ofClass: UIImage.self) { image, error in
                                        if let error = error {
                                            Logger.default.error("could not load content: \(error)")
                                        } else if let image = image as? UIImage {
                                            DispatchQueue.main.async {
                                                itemDetails.addImage(image)
                                            }
                                        } else {
                                            Logger.default.error("wrong content: \(String(describing: image))")
                                        }
                                    }

                                }
                            }
                            return true
                        }
                    } label: {
                        Text("Images")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
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
                    .disabled(itemDetails.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
                if !checklistsUnavailable && !isEditing {
                    Menu {
                        ForEach(checklists) { checklist in
                            Button {
                                itemDetails.add(to: checklist)
                            } label: {
                                Label(checklist.title, systemImage: checklist.icon ?? "list.bullet.rectangle")
                            }
                            .disabled(isItem(in: checklist))
                        }
                    } label: {
                        Label("Add to checklist", systemImage: "text.badge.plus")
                    }
                    .menuStyle(.borderlessButton)
                    .disabled(Checklist.isEmpty(in: viewContext))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if allowOpenInSeparateWindow && !isEditing, let item = item {
                    Button {
                        SingleItemDetailsView.activateSession(item: item)
                    } label: {
                        Label("Open in separate window", systemImage: "square.on.square")
                    }
                }
            }
        }
        .navigationTitle(title)
        .fullScreenCover(isPresented: $showTakePhoto) {
            CameraView(image: $takenImage)
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(images: $pickedImages, isFetchingImages: $isFetchingImages)
        }
        .disabled(isPredicting || isFetchingImages)
        .onAppear {
            checklistsUnavailable = Checklist.isEmpty(in: viewContext)
        }
        .userActivity(Self.activityIdentifier, isActive: item != nil) { activity in
            guard let item = item else {
                return
            }

            activity.title = itemDetails.title
            // TODO: add more details?
            activity.userInfo = [Self.identifierKey: item.identifier]
            activity.isEligibleForHandoff = true
            activity.isEligibleForPrediction = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: nil)) { _ in
            checklistsUnavailable = Checklist.isEmpty(in: viewContext)
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

    private func isItem(in checklist: Checklist) -> Bool {
        guard let item = item else {
            return false
        }
        return checklist.entries.compactMap(\.item).contains(item)
    }

    private func takePhoto() {
        if cameraAccessAllowed() {
            showTakePhoto = true
        } else {
            showCameraPermissionWarning = true
        }
    }
    
    private func addPhoto() {
        showPhotoPicker = true
    }
}

