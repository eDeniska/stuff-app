//
//  NewChecklistView.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import DataModel

struct NewChecklistView: View {

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var newListTitle = ""
    @State private var selectedIcon = ChecklistIcon.allCases.first?.rawValue ?? ""

    private let gridItemLayout = [GridItem(.adaptive(minimum: 80))]

    private var trimmedTitle: String {
        newListTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submit() {
        guard !trimmedTitle.isEmpty else {
            return
        }
        Checklist.checklist(title: trimmedTitle, icon: selectedIcon, in: viewContext)
        viewContext.saveOrRollback()
        presentationMode.wrappedValue.dismiss()
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("New checklist title", text: $newListTitle)
                        .onSubmit(submit)
                } header: {
                    Text("Title")
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
                    Text("Icon")
                }
            }
            .navigationTitle("New checklist")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: submit) {
                        Text("Save")
                            .bold()
                    }
                    .disabled(trimmedTitle.isEmpty)
                }
            }
        }
    }
}
