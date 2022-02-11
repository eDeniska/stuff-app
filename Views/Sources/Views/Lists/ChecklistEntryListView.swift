//
//  ChecklistEntryListView.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import CoreData
import DataModel
import Logger

// TODO: add simple way of adding items to the list without separate form (but - suggestions?)
// TODO: need undo support

// TODO: fix: first added item is not added (sometimes)!

public extension Notification.Name {
    static let checklistSelected = Notification.Name("ChecklistSelectedNotification")
}


public struct ChecklistEntryListView: View {

    public static let activityIdentifier = "com.tazetdinov.stuff.checklist.view"
    public static let identifierKey = "checklistID"

    @ObservedObject private var checklist: Checklist
    @Environment(\.managedObjectContext) private var viewContext

    private var entriesRequest : SectionedFetchRequest<Bool, ChecklistEntry>
    private var entries : SectionedFetchResults<Bool, ChecklistEntry> { entriesRequest.wrappedValue }

    @State private var addEntry = false

    private let allowOpenInSeparateWindow: Bool

    init(checklist: Checklist, allowOpenInSeparateWindow: Bool = true) {
        self.checklist = checklist
        self.entriesRequest = SectionedFetchRequest(entity: ChecklistEntry.entity(),
                                                    sectionIdentifier: \ChecklistEntry.isChecked,
                                                    sortDescriptors: [
                                                        NSSortDescriptor(key: #keyPath(ChecklistEntry.isChecked), ascending: true),
                                                        NSSortDescriptor(key: #keyPath(ChecklistEntry.order), ascending: true)],
                                                    predicate:
                                                        NSPredicate(format: "\(#keyPath(ChecklistEntry.checklist)) == %@", checklist),
                                                    animation: .default)
        self.allowOpenInSeparateWindow = UIApplication.shared.supportsMultipleScenes && allowOpenInSeparateWindow
    }

    func title(for sectionIdentifier: SectionedFetchResults<Bool, ChecklistEntry>.Section.ID) -> String {
        if sectionIdentifier {
            return "Checked"
        } else {
            return "Pending"
        }
    }

    public var body: some View {
        List {
            ForEach(entries) { section in
                Section(header: Text(title(for: section.id))) {
                    ForEach(section) { entry in
                        ChecklistEntryView(entry: entry)
                    }
                    .onMove { indexSet, index in
                        var revisedItems = section.map { $0 }
                        revisedItems.move(fromOffsets: indexSet, toOffset: index )

                        for newIndex in 0..<revisedItems.count
                        {
                            revisedItems[newIndex].order = Int64(newIndex)
                        }
                        viewContext.saveOrRollback()
                    }
                    .onDelete { indexSets in
                        withAnimation {
                            indexSets.map { section[$0] }.forEach(viewContext.delete)
                            viewContext.saveOrRollback()
                        }
                    }
                }
            }
        }
        .overlay {
            if entries.isEmpty {
                Text("Checklist is empty")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(checklist.title)
        // for some reason, after deleting the item app crashes on identifier access...
        .userActivity(Self.activityIdentifier, isActive: !checklist.isFault) { activity in
            activity.title = checklist.title
            Logger.default.info("checklist -> '\(checklist)")
            activity.userInfo = [Self.identifierKey: checklist.identifier]
            activity.isEligibleForHandoff = true
            activity.isEligibleForPrediction = true
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if allowOpenInSeparateWindow {
                    Button {
                        SingleChecklistView.activateSession(checklist: checklist)
                    } label: {
                        Label("Open in separate window", systemImage: "square.on.square")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button {
                    addEntry = true
                } label: {
                    Label("Add Checklist", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $addEntry) {
            NewChecklistEntryView(checklist: checklist)
        }
    }
}
