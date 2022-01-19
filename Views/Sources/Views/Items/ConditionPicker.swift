//
//  ConditionPicker.swift
//  
//
//  Created by Danis Tazetdinov on 18.01.2022.
//

import SwiftUI
import DataModel

struct ConditionPicker: View {
    @Binding var itemCondition: ItemCondition
    @Environment(\.presentationMode) private var presentationMode

    var body: some View  {
//        NavigationView {
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
            .navigationBarTitleDisplayMode(.automatic)
            .navigationBarTitle("Item Condition")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
//        }
    }
}
