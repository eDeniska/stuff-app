//
//  ChecklistsListView.swift
//  WatchStuff WatchKit Extension
//
//  Created by Danis Tazetdinov on 16.02.2022.
//

import SwiftUI
import DataModel
import CoreData
import Localization
import Logger

struct ChecklistsListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\Checklist.lastModified, order: .reverse),
            SortDescriptor(\Checklist.title)
                         ],
        animation: .default)
    private var lists: FetchedResults<Checklist>

    var body: some View {
        NavigationView {
            if !lists.isEmpty {
                List {
                    ForEach(lists) { list in
                        NavigationLink {
                            ChecklistEntriesListView(checklist: list)
                        } label: {
                            ChecklistListRow(checklist: list)
                        }
                    }
                }
                .navigationTitle(L10n.WatchStuff.checklistsTitle.localized)
            } else {
                Text(L10n.WatchStuff.noLists.localized)
                    .padding()
                    .font(.title3)
                    .navigationTitle(L10n.WatchStuff.checklistsTitle.localized)
            }
        }
    }
}
