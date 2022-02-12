//
//  ChecklistListElement.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import DataModel
import CoreData
import Localization

struct ChecklistListElement: View {
    @ObservedObject private var checklist: Checklist

    public init(checklist: Checklist) {
        self.checklist = checklist
    }

    public var body: some View {
        HStack(alignment: .center) {
            Image(systemName: checklist.icon ?? "list.bullet")
                .frame(width: 40, height: 40, alignment: .center)
            VStack(alignment: .leading) {
                Text(checklist.title)
                    .truncationMode(.tail)
                    .lineLimit(1)
                    .font(.body)
                if let count = checklist.entries.count, count > 0 {
                    Text(L10n.ChecklistsList.elementNumberOfEntries.localized(with: count))
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

}
