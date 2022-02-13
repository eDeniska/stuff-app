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
import Localization
import ViewModels

// TODO: add onSubmit action to save on enter press?

public extension Notification.Name {
    static let itemCaptureRequest = Notification.Name("ItemCaptureRequestNotification")
}

public struct ItemDetailsView: View {

    public static let activityIdentifier = "com.tazetdinov.stuff.item.view"
    public static let identifierKey = "itemID"

    @Binding private var item: Item?
    private let hasDismissButton: Bool
    private let allowOpenInSeparateWindow: Bool
    private let startWithPhoto: Bool
    private let validObject: Bool

    public init(item: Item?, hasDismissButton: Bool = false, allowOpenInSeparateWindow: Bool = true, startWithPhoto: Bool = false) {
        if let item = item {
            validObject = item.managedObjectContext != nil
        } else {
            validObject = true
        }
        _item = Binding(projectedValue: .constant(item))
        self.hasDismissButton = hasDismissButton
        self.allowOpenInSeparateWindow = allowOpenInSeparateWindow
        self.startWithPhoto = startWithPhoto
    }

    public init(item: Binding<Item?>, hasDismissButton: Bool = false, allowOpenInSeparateWindow: Bool = true, startWithPhoto: Bool = false) {
        _item = item
        self.hasDismissButton = hasDismissButton
        self.allowOpenInSeparateWindow = allowOpenInSeparateWindow
        self.startWithPhoto = startWithPhoto
        if let item = item.wrappedValue {
            validObject = item.managedObjectContext != nil
        } else {
            validObject = true
        }
    }

    public var body: some View {
        if validObject {
            ItemDetailsViewInternal(item: $item,
                                    hasDismissButton: hasDismissButton,
                                    allowOpenInSeparateWindow: allowOpenInSeparateWindow,
                                    startWithPhoto: startWithPhoto)
        } else {
            ItemDetailsWelcomeView()
        }
    }
}
struct ItemDetailsViewInternal: View {

    private enum FocusedField {
        case title
        case details
    }

    @StateObject private var itemDetails: ItemViewModel
    @Binding private var item: Item?

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
    private let hasDismissButton: Bool

    private var title: String {
        itemDetails.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? L10n.ItemDetails.newItemTitle.localized : itemDetails.title
    }

    private func cameraAccessAllowed() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized || AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
    }

    private func cameraAccessRestricted() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .restricted
    }

    init(item: Binding<Item?>, hasDismissButton: Bool = false, allowOpenInSeparateWindow: Bool = true, startWithPhoto: Bool = false) {
        _item = item
        _itemDetails = StateObject(wrappedValue: ItemViewModel(item: item.wrappedValue))
        _isEditing = State(wrappedValue: item.wrappedValue == nil)
        isNew = item.wrappedValue == nil
        self.hasDismissButton = hasDismissButton

        self.allowOpenInSeparateWindow = UIApplication.shared.supportsMultipleScenes && allowOpenInSeparateWindow
        if startWithPhoto {
            _showTakePhoto = State(wrappedValue: true)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox {
                    if isEditing {
                        TextField(L10n.ItemDetails.itemTitlePlaceholder.localized, text: $itemDetails.title)
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
                    Text(L10n.ItemDetails.itemSectionTitle.localized)
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
                                        Text(L10n.Common.buttonChoose.localized)
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
                    Text(L10n.Category.title.localized)
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
                            TextField(L10n.ItemDetails.detailsPlaceholder.localized, text: $itemDetails.details)
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
                        Text(L10n.ItemDetails.detailsSectionTitle.localized)
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
                                        Text(L10n.Common.buttonChoose.localized)
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
                    Text(L10n.ConditionView.title.localized)
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
                                Text(itemDetails.place?.title ?? L10n.ItemDetails.noPlaceIsSet.localized)
                                    .font(.title2)
                                Spacer()
                                Button {
                                    showPlacePicker = true
                                } label: {
                                    HStack {
                                        Text(L10n.Common.buttonChoose.localized)
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
                                    Text(itemDetails.place?.title ?? L10n.ItemDetails.noPlaceIsSet.localized)
                                        .font(.title2)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .id("placeTitle")
                        }
                    } else {
                        Text(itemDetails.place?.title ?? L10n.ItemDetails.noPlaceIsSet.localized)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .id("placeTitle")
                            .padding(UIDevice.current.isMac ? 8 : 0)
                    }
                } label: {
                    Text(L10n.PlaceDetails.title.localized)
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
                                                .accessibilityLabel(Text(L10n.ItemDetails.shouldRemoveImage.localized))

                                            } else {
                                                EmptyView()
                                            }
                                        }
                                        .confirmationDialog(L10n.ItemDetails.shouldRemoveImage.localized, isPresented: Binding {
                                            removingImageId == image.id
                                        } set: { newValue in
                                            if !newValue {
                                                removingImageId = nil
                                            }
                                        }, titleVisibility: .visible) {
                                            Button(role: .destructive) {
                                                itemDetails.removeImage(with: image.id)
                                            } label: {
                                                Text(L10n.ItemDetails.removeImageConfirmation.localized)
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
                                    .accessibilityLabel(Text(L10n.ItemDetails.addPhotosTitle.localized))
                                    .confirmationDialog(L10n.ItemDetails.addPhotosTitle.localized, isPresented: $showPhotoSourcePikcer, titleVisibility: .visible) {
                                        Button {
                                            takePhoto()
                                        } label: {
                                            Label(L10n.ItemDetails.takePhotoTitle.localized, systemImage: "camera")
                                        }

                                        Button {
                                            addPhoto()
                                        } label: {
                                            Label(L10n.ItemDetails.choosePhotosTitle.localized, systemImage: "photo.on.rectangle.angled")
                                        }
                                    }
                                    .alert(L10n.ItemDetails.noCameraAccessTitle.localized, isPresented: $showCameraPermissionWarning) {
                                        if UIDevice.current.isMac {
                                            Button(role: .cancel) {
                                                showCameraPermissionWarning = false
                                            } label: {
                                                Text(L10n.Common.buttonDismiss.localized)
                                            }
                                            .keyboardShortcut(.cancelAction)
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
                                                Text(L10n.ItemDetails.buttonOpenSettings.localized)
                                            }
                                            .keyboardShortcut(.defaultAction)
                                            Button(role: .cancel) {
                                                showCameraPermissionWarning = false
                                            } label: {
                                                Text(L10n.Common.buttonCancel.localized)
                                            }
                                            .keyboardShortcut(.cancelAction)
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
                        Text(L10n.ItemDetails.imagesSectionTitle.localized)
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
                    ProgressView(isPredicting ? L10n.ItemDetails.predictingTitle.localized : L10n.ItemDetails.fetchingImagesTitle.localized)
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
                        item = itemDetails.save(in: viewContext)
                        viewContext.saveOrRollback()
                        if isNew {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            isEditing.toggle()
                        }
                    } label: {
                        Text(L10n.Common.buttonSave.localized)
                            .bold()
                    }
                    .keyboardShortcut("S", modifiers: [.command])
                    .disabled(itemDetails.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } else {
                    Button {
                        isEditing.toggle()
                    } label: {
                        Text(L10n.Common.buttonEdit.localized)
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
                        Text(L10n.Common.buttonCancel.localized)
                    }
                    .keyboardShortcut(.cancelAction)
                } else if hasDismissButton {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text(L10n.Common.buttonDismiss.localized)
                    }
                    .keyboardShortcut(.cancelAction)
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
                        Label(L10n.ItemDetails.buttonAddToChecklist.localized, systemImage: "text.badge.plus")
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
                        Label(L10n.Common.buttonSeparateWindow.localized, systemImage: "square.on.square")
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
        .userActivity(ItemDetailsView.activityIdentifier, isActive: !(item?.isFault ?? true)) { activity in
            guard let item = item, !item.isFault && !item.isDeleted else {
                return
            }

            activity.title = itemDetails.title
            activity.userInfo = [ItemDetailsView.identifierKey: item.identifier]
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

