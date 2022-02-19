//
//  ChecklistListRow.swift
//  
//
//  Created by Данис Тазетдинов on 19.02.2022.
//

import SwiftUI
import DataModel
import Localization

struct ChecklistListRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var checklist: Checklist

    @State private var showDeleteConfirmation = false
    @State private var showItemAssignment = false

    @State private var itemsUnavailable = false

    @State private var detailsOpen = false

    private func element() -> some View {
        NavigationLink(isActive: $detailsOpen) {
            ChecklistEntryListView(checklist: checklist)
        } label: {
            ChecklistListElement(checklist: checklist)
        }
        .contextMenu {
            Button {
                showItemAssignment = true
            } label: {
                Label(L10n.ChecklistsList.addItemsButton.localized, systemImage: "text.badge.plus")
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
                Label(L10n.ChecklistsList.addItemsButton.localized, systemImage: "text.badge.plus")
            }
            .tint(.indigo)
            .disabled(itemsUnavailable)
        }
        .confirmationDialog(L10n.ChecklistsList.shouldDeleteChecklist.localized(with: checklist.title), isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(role: .destructive) {
                viewContext.delete(checklist)
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
            ChecklistItemsAssingmentView(checklist: checklist)
        }
        .onAppear {
            itemsUnavailable = Item.isEmpty(in: viewContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: nil).receive(on: DispatchQueue.main)) { _ in
            itemsUnavailable = Item.isEmpty(in: viewContext)
        }
        .onChange(of: checklist) { newValue in
            if checklist.isFault || checklist.isDeleted {
                detailsOpen = false
            }
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
