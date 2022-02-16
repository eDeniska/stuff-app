//
//  ChecklistListRow.swift
//  WatchStuffExtension
//
//  Created by Danis Tazetdinov on 16.02.2022.
//

import SwiftUI
import DataModel
import CoreData
import Combine
import Localization

struct ChecklistListRow: View {

    @ObservedObject var checklist: Checklist

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: checklist.icon ?? "list.bullet")
                .frame(width: 32, height: 32, alignment: .center)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading) {
                Text(checklist.title)
                    .truncationMode(.tail)
                    .lineLimit(1)
                    .font(.body)
                if let count = checklist.entries.count, count > 0 {
                    Text(L10n.Common.numberOfEntries.localized(with: count))
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }    }
}
