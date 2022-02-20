//
//  ItemListRow.swift
//  
//
//  Created by Данис Тазетдинов on 19.02.2022.
//

import SwiftUI
import DataModel
import Localization

struct ItemListRow: View {

    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: Item

    @State private var showChecklistAssignment = false
    @State private var showDeleteConfirmation = false

    @State private var checklistsUnavailable = false

    @State private var detailsOpen = false

    var displayPlace: Bool = true
    var displayCategory: Bool = false
    var displayCondition: Bool = false

    private func element() -> some View {
        NavigationLink(isActive: $detailsOpen) {
            ItemDetailsView(item: item)
        } label: {
            ItemListElement(item: item,
                            displayPlace: displayPlace,
                            displayCategory: displayCategory,
                            displayCondition: displayCondition)
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
                item.removeImages()
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
