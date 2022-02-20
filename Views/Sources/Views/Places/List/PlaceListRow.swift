//
//  File.swift
//  
//
//  Created by Данис Тазетдинов on 20.02.2022.
//

import SwiftUI
import DataModel
import Localization

struct PlaceListRow: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var place: ItemPlace
    @State private var showDeleteConfirmation = false
    @State private var showItemAssignment = false

    @State private var itemsUnavailable = true

    @State private var detailsOpen = false

    private func element() -> some View {
        NavigationLink(isActive: $detailsOpen) {
            PlaceDetailsView(place: place)
        } label: {
            PlaceListElement(place: place)
        }
        .contextMenu {
            Button {
                showItemAssignment = true
            } label: {
                Label(L10n.PlacesList.placeItemsButton.localized, systemImage: "text.badge.plus")
            }
            .disabled(itemsUnavailable)
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(L10n.Common.buttonDeleteEllipsis.localized, systemImage: "trash")
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(L10n.Common.buttonDeleteEllipsis.localized, systemImage: "trash")
            }
            Button {
                showItemAssignment = true
            } label: {
                Label(L10n.PlacesList.placeItemsButton.localized, systemImage: "text.badge.plus")
            }
            .tint(.indigo)
            .disabled(itemsUnavailable)
        }
        .confirmationDialog(L10n.PlacesList.shouldDeletePlace.localized(with: place.title), isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(role: .destructive) {
                viewContext.delete(place)
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
        .sheet(isPresented: $showItemAssignment) {
            PlaceItemsAssingmentView(place: place)
        }
        .onAppear {
            itemsUnavailable = Item.isEmpty(in: viewContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: nil).receive(on: DispatchQueue.main)) { _ in
            itemsUnavailable = Item.isEmpty(in: viewContext)
        }
    }

    var body: some View {
        if itemsUnavailable {
            element()
        } else {
            element()
        }
    }
}
