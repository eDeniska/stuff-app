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
    let itemTitle: String

    @Environment(\.dismiss) private var dismiss

    var body: some View  {
        PhoneNavigationView {
            List {
                Section {
                    ForEach(ItemCondition.allCases, id: \.self) { condition in
                        Button {
                            itemCondition = condition
                            dismiss()
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
            .navigationTitle(itemTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                             L10n.ConditionView.title.localized :
                             L10n.ConditionView.conditionForItem.localized(with: itemTitle)
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text(L10n.Common.buttonCancel.localized)
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
    }
}
