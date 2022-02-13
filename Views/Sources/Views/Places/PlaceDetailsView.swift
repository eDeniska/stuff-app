//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 24.01.2022.
//

import SwiftUI
import DataModel
import CoreData
import Logger
import Localization

public struct PlaceDetailsView: View {

    public static let activityIdentifier = "com.tazetdinov.stuff.place.view"
    public static let identifierKey = "placeID"

    @ObservedObject private var place: ItemPlace
    @Environment(\.managedObjectContext) private var viewContext

    private var items: SectionedFetchResults<String, Item> { itemsRequest.wrappedValue }
    private var itemsRequest: SectionedFetchRequest<String, Item>

    @State private var presentedItem: Item?

    @State private var showItemAssignment = false
    @State private var itemsUnavailable = true

    private let allowOpenInSeparateWindow: Bool
    private let validObject: Bool

    public init(place: ItemPlace, allowOpenInSeparateWindow: Bool = true) {
        validObject = place.managedObjectContext != nil
        self.place = place
        itemsRequest = SectionedFetchRequest(entity: Item.entity(),
                                             sectionIdentifier: \Item.categoryTitle,
                                             sortDescriptors: [
                                                NSSortDescriptor(key: #keyPath(Item.category.order), ascending: false),
                                                NSSortDescriptor(key: #keyPath(Item.category.title), ascending: true),
                                                NSSortDescriptor(key: #keyPath(Item.lastModified), ascending: true)
                                             ],
                                             predicate: NSPredicate(format: "\(#keyPath(Item.place)) == %@", place),
                                             animation: .default)
        self.allowOpenInSeparateWindow = UIApplication.shared.supportsMultipleScenes && allowOpenInSeparateWindow
    }


    private func title(for sectionIdentifier: SectionedFetchResults<String, Item>.Section.ID) -> String {
        if sectionIdentifier.isEmpty {
            return L10n.Category.unnamedCategory.localized
        } else {
            return sectionIdentifier
        }
    }

    public var body: some View {
        if validObject {
        List {
            ForEach(items) { section in
                Section(header: Text(title(for: section.id))) {
                    ForEach(section) { item in
                        Button {
                            presentedItem = item

                        } label: {
                            HStack {
                                ItemListElement(item: item)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSets in
                        withAnimation {
                            indexSets.map { section[$0] }.forEach { item in
                                item.place = nil
                            }
                            viewContext.saveOrRollback()
                        }
                    }
                    .sheet(item: $presentedItem) { item in
                        NavigationView {
                            ItemDetailsView(item: item, hasDismissButton: true)
                        }
                    }
                }
            }
        }
        .overlay {
            if items.isEmpty {
                Text(L10n.PlaceDetails.placeIsEmpty.localized)
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showItemAssignment) {
            PlaceItemsAssingmentView(place: place)
        }
        .navigationTitle(place.title)
        .userActivity(Self.activityIdentifier, isActive: !place.isFault) { activity in
            activity.title = place.title
            activity.userInfo = [Self.identifierKey: place.identifier]
            activity.isEligibleForHandoff = true
            activity.isEligibleForPrediction = true
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showItemAssignment = true
                } label: {
                    Label(L10n.PlacesList.placeItemsButton.localized, systemImage: "text.badge.plus") // TODO: consider other icon
                }
                .disabled(itemsUnavailable)
                if allowOpenInSeparateWindow {
                    Button {
                        SinglePlaceView.activateSession(place: place)
                    } label: {
                        Label(L10n.Common.buttonSeparateWindow.localized, systemImage: "square.on.square")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .onAppear {
            itemsUnavailable = Item.isEmpty(in: viewContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: nil).receive(on: DispatchQueue.main)) { _ in
            itemsUnavailable = Item.isEmpty(in: viewContext)
        }
        } else {
            PlaceDetailsWelcomeView()
        }
    }
}
