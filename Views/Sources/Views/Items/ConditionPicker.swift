//
//  ConditionPicker.swift
//  
//
//  Created by Danis Tazetdinov on 18.01.2022.
//

import SwiftUI
import DataModel
import Localization

struct ConditionPicker: View {
    @Binding var itemCondition: ItemCondition
    @Environment(\.presentationMode) private var presentationMode

    var body: some View  {
        PhoneNavigationView {
            List {
                Section {
                    ForEach(ItemCondition.allCases, id: \.self) { condition in
                        Button {
                            itemCondition = condition
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Text(condition.localizedTitle)
                                Spacer()
                                if itemCondition == condition {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationBarTitle(L10n.ConditionView.title.localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text(L10n.Common.buttonCancel.localized)
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
    }
}
