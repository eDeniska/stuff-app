//
//  NewChecklistView.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import DataModel
import Localization

struct NewChecklistView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @State private var newListTitle = ""
    @State private var selectedIcon = ChecklistIcon.allCases.first?.rawValue ?? ""

    @Binding var createdChecklist: Checklist?

    private let gridItemLayout = [GridItem(.adaptive(minimum: 80))]

    private var trimmedTitle: String {
        newListTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submit() {
        guard !trimmedTitle.isEmpty else {
            return
        }
        createdChecklist = Checklist.checklist(title: trimmedTitle, icon: selectedIcon, in: viewContext)
        viewContext.saveOrRollback()
        dismiss()
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(L10n.EditChecklist.titlePlaceholder.localized, text: $newListTitle)
                        .onSubmit(submit)
                } header: {
                    Text(L10n.EditChecklist.titleSectionTitle.localized)
                }
                Section {
                    LazyVGrid(columns: gridItemLayout) {
                        ForEach(ChecklistIcon.allCases) { icon in
                            Button {
                                selectedIcon = icon.rawValue
                            } label: {
                                Image(systemName: icon.rawValue)
                                    .font(.title3)
                                    .padding()
                                    .frame(width: 60, height: 60, alignment: .center)
                                    .overlay(icon.rawValue == selectedIcon ? RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor) : nil)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .id(icon)
                        }
                    }
                } header: {
                    Text(L10n.EditChecklist.customIcon.localized)
                }
            }
            .navigationTitle(L10n.EditChecklist.title.localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text(L10n.Common.buttonCancel.localized)
                    }
                    .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: submit) {
                        Text(L10n.Common.buttonSave.localized)
                            .bold()
                    }
                    .keyboardShortcut("S", modifiers: [.command])
                    .disabled(trimmedTitle.isEmpty)
                }
            }
        }
    }
}
