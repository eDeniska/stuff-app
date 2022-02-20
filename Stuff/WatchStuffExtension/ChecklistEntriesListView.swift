//
//  ChecklistEntriesListView.swift
//  WatchStuffExtension
//
//  Created by Danis Tazetdinov on 16.02.2022.
//

import Foundation
import SwiftUI
import Localization
import DataModel
import Logger

public struct ChecklistEntriesListView: View {

    @ObservedObject private var checklist: Checklist
    @Environment(\.managedObjectContext) private var viewContext

    private var entriesRequest: SectionedFetchRequest<Bool, ChecklistEntry>
    private var entries: SectionedFetchResults<Bool, ChecklistEntry> { entriesRequest.wrappedValue }

    private let validObject: Bool

    init(checklist: Checklist) {
        validObject = checklist.managedObjectContext != nil
        self.checklist = checklist
        self.entriesRequest = SectionedFetchRequest(entity: ChecklistEntry.entity(),
                                                    sectionIdentifier: \ChecklistEntry.isChecked,
                                                    sortDescriptors: [
                                                        NSSortDescriptor(key: #keyPath(ChecklistEntry.isChecked), ascending: true),
                                                        NSSortDescriptor(key: #keyPath(ChecklistEntry.order), ascending: true)],
                                                    predicate:
                                                            .equalsTo(keyPath: #keyPath(ChecklistEntry.checklist), object: checklist),
                                                    animation: .default)
    }

    func title(for sectionIdentifier: SectionedFetchResults<Bool, ChecklistEntry>.Section.ID) -> String {
        if sectionIdentifier {
            return L10n.WatchStuff.sectionChecked.localized
        } else {
            return L10n.WatchStuff.sectionPending.localized
        }
    }

    public var body: some View {
        if validObject {
            if entries.isEmpty {
                Text(L10n.WatchStuff.noEntries.localized)
                    .padding()
                    .font(.title3)
                    .navigationTitle(checklist.title)
            } else {
                List {
                    ForEach(entries) { section in
                        Section(header: Text(title(for: section.id))) {
                            ForEach(section) { entry in
                                ChecklistEntriesListRow(entry: entry)
                            }
                        }
                    }
                }
                .navigationTitle(checklist.title)
                .userActivity(UserActivityRegistry.ChecklistView.activityType, isActive: !checklist.isFault) { activity in
                    activity.title = checklist.title
                    Logger.default.info("checklist -> '\(checklist)")
                    activity.userInfo = [UserActivityRegistry.ChecklistView.identifierKey: checklist.identifier]
                    activity.isEligibleForHandoff = true
                    activity.isEligibleForPrediction = true
                }
            }
        } else {
            EmptyView()
        }
    }
}
