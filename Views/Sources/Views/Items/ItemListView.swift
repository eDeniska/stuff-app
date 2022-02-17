//
//  ItemListView.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import CoreData
import DataModel
import Localization
import AVFoundation
import Intents
import IntentsUI
struct ItemListRow: View {

    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: Item

    @State private var showChecklistAssignment = false
    @State private var showDeleteConfirmation = false

    @State private var checklistsUnavailable = false

    @State private var detailsOpen = false

    private func element() -> some View {
        NavigationLink(isActive: $detailsOpen) {
            ItemDetailsView(item: item)
        } label: {
            ItemListElement(item: item)
        }
        .contextMenu {
            Button {
                showChecklistAssignment = true
            } label: {
                Label(L10n.ItemsList.addToChecklistsButton.localized, systemImage: "text.badge.plus")
            }
            .disabled(checklistsUnavailable)
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(L10n.Common.buttonDeleteEllipsis.localized, systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(L10n.Common.buttonDeleteEllipsis.localized, systemImage: "trash")
            }
            Button {
                showChecklistAssignment = true
            } label: {
                Label(L10n.ItemsList.addToChecklistsButton.localized, systemImage: "text.badge.plus")
            }
            .tint(.indigo)
            .disabled(checklistsUnavailable)
        }
        .confirmationDialog(L10n.ItemsList.shouldDeleteItem.localized(with: item.title), isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(role: .destructive) {
                viewContext.delete(item)
                viewContext.saveOrRollback()
            } label: {
                Text(L10n.Common.buttonDelete.localized)
            }
            .keyboardShortcut(.defaultAction)
            Button(role: .cancel) {
            } label: {
                Text(L10n.Common.buttonCancel.localized)
            }
            .keyboardShortcut(.cancelAction)
        }
        .sheet(isPresented: $showChecklistAssignment) {
            ItemChecklistsAssignmentView(item: item)
        }
        .onAppear {
            checklistsUnavailable = Checklist.isEmpty(in: viewContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: nil).receive(on: DispatchQueue.main)) { _ in
            checklistsUnavailable = Checklist.isEmpty(in: viewContext)
        }
    }

    var body: some View {
        // due to bug in SwifUI context menu handling, we have to re-create view each time
        if checklistsUnavailable {
            element()
        } else {
            element()
        }
    }
}

public struct ItemListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @SectionedFetchRequest(
        sectionIdentifier: \Item.categoryTitle,
        sortDescriptors: [
            SortDescriptor(\Item.category?.order, order: .reverse),
            SortDescriptor(\Item.category?.title),
            SortDescriptor(\Item.lastModified)
                         ],
        animation: .default)
    private var items: SectionedFetchResults<String, Item>

    @State private var searchText: String = ""
    @State private var showNewItemForm = false
    @State private var showItemCapture = false

    @Binding private var selectedItem: Item?

    public init(selectedItem: Binding<Item?>) {
        _selectedItem = selectedItem
    }

    private func title(for sectionIdentifier: SectionedFetchResults<String, Item>.Section.ID) -> String {
        sectionIdentifier.isEmpty ? L10n.Category.unnamedCategory.localized : sectionIdentifier
    }

    private func cameraAccessDisallowed() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) != .authorized && AVCaptureDevice.authorizationStatus(for: .video) != .notDetermined
    }

    public var body: some View {
        NavigationView {
            List {
                ForEach(items) { section in
                    Section(header: Text(title(for: section.id))) {
                        ForEach(section) { item in
                            ItemListRow(item: item)
                        }
                        .onDelete { indexSets in
                            // this one is used by edit mode seemingly
                            withAnimation {
                                indexSets.map { section[$0] }.forEach(viewContext.delete)
                                viewContext.saveOrRollback()
                            }
                        }
                    }
                }
            }
            .background {
                VStack {
                    NavigationLink(isActive: Binding { selectedItem != nil } set: { if !$0 { selectedItem = nil } }) {
                        ItemDetailsView(item: selectedItem)
                    } label: {
                        EmptyView()
                    }
                    .hidden()
                    ItemCaptureView(createdItem: $selectedItem, startItemCapture: $showItemCapture)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .newItemRequest, object: nil).receive(on: DispatchQueue.main)) { _ in
                selectedItem = nil
                showNewItemForm = true
            }
            .onChange(of: searchText) { newValue in
                let text = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if text.isEmpty {
                    items.nsPredicate = nil
                } else {
                    items.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:
                                                                [#keyPath(Item.title),
                                                                 #keyPath(Item.details),
                                                                 #keyPath(Item.place.title),
                                                                 #keyPath(Item.category.title)].map { keyPath in
                            .contains(keyPath: keyPath, text: text)
                    })
                }
            }
            .userActivity(UserActivityRegistry.ItemsView.activityType) { activity in
                activity.title = L10n.ItemsList.listTitle.localized
                activity.isEligibleForHandoff = true
                activity.isEligibleForPrediction = true
            }
            .searchable(text: $searchText, prompt: Text(L10n.ItemsList.searchPlaceholder.localized))
            .navigationTitle(L10n.ItemsList.listTitle.localized)
            .sheet(isPresented: $showNewItemForm) {
                NavigationView {
                    ItemDetailsView(item: $selectedItem)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        selectedItem = nil
                        showItemCapture = true
                    } label: {
                        Label(L10n.ItemDetails.takePhotoTitle.localized, systemImage: "camera")
                    }
                    .disabled(cameraAccessDisallowed())
                    Button {
                        selectedItem = nil
                        showNewItemForm = true
                    } label: {
                        Label(L10n.ItemsList.addItemButton.localized, systemImage: "plus")
                    }
                    EditButton()
                }
            }
            ItemDetailsWelcomeView()
        }
        .tabItem {
            Label(L10n.ItemsList.listTitle.localized, systemImage: "tag")
        }
        .navigationViewStyle(.columns)
    }
}
