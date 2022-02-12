//
//  NewPlaceView.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import DataModel
import Localization

struct NewPlaceView: View {

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var newPlaceTitle = ""
    @State private var selectedIcon = PlaceIcon.allCases.first?.rawValue ?? ""

    @Binding var createdPlace: ItemPlace?

    private let gridItemLayout = [GridItem(.adaptive(minimum: 80))]

    private var trimmedTitle: String {
        newPlaceTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submit() {
        guard !trimmedTitle.isEmpty else {
            return
        }
        createdPlace = ItemPlace.place(title: trimmedTitle, icon: selectedIcon, in: viewContext)
        viewContext.saveOrRollback()
        presentationMode.wrappedValue.dismiss()
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(L10n.NewPlace.titlePlaceholder.localized, text: $newPlaceTitle)
                        .onSubmit(submit)
                } header: {
                    Text(L10n.NewPlace.titleSectionTitle.localized)
                }
                Section {
                    LazyVGrid(columns: gridItemLayout) {
                        ForEach(PlaceIcon.allCases) { icon in
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
                    Text(L10n.NewPlace.customIcon.localized)
                }
            }
            .navigationTitle(L10n.NewPlace.title.localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
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
