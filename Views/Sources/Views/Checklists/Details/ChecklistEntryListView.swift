//
//  ChecklistEntryListView.swift
//  
//
//  Created by Danis Tazetdinov on 02.02.2022.
//

import SwiftUI
import CoreData
import DataModel
import ViewModels
import Logger
import Localization

// TODO: add simple way of adding items to the list without separate form (but - suggestions?)

public extension Notification.Name {
    static let checklistSelected = Notification.Name("ChecklistSelectedNotification")
}

public struct ChecklistEntryListView: View {

    @ObservedObject private var checklist: Checklist
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) private var editMode

    private var entriesRequest: SectionedFetchRequest<Bool, ChecklistEntry>
    private var entries: SectionedFetchResults<Bool, ChecklistEntry> { entriesRequest.wrappedValue }

    @State private var addEntry = false
    @StateObject private var checklistTitle = ObservableText()

    private let allowOpenInSeparateWindow: Bool
    private let validObject: Bool
    private let gridItemLayout = [GridItem(.adaptive(minimum: 80))]

    init(checklist: Checklist, allowOpenInSeparateWindow: Bool = true) {
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
        self.allowOpenInSeparateWindow = UIApplication.shared.supportsMultipleScenes && allowOpenInSeparateWindow
    }

    func title(for sectionIdentifier: SectionedFetchResults<Bool, ChecklistEntry>.Section.ID) -> String {
        sectionIdentifier ? L10n.ChecklistDetails.sectionChecked.localized : L10n.ChecklistDetails.sectionPending.localized
    }

    public var body: some View {
        if validObject {
            List {
                if editMode?.wrappedValue == .active {
                    Section {
                        TextField(L10n.EditChecklist.titlePlaceholder.localized, text: $checklistTitle.text)
                            .onSubmit {
                                editMode?.wrappedValue = .inactive
                            }
                    } header: {
                        Text(L10n.EditChecklist.titleSectionTitle.localized)
                    }
                    Section {
                        LazyVGrid(columns: gridItemLayout) {
                            ForEach(ChecklistIcon.allCases) { icon in
                                Button {
                                    checklist.icon = icon.rawValue
                                    checklist.lastModified = .now
                                    viewContext.saveOrRollback()
                                } label: {
                                    Image(systemName: icon.rawValue)
                                        .font(.title3)
                                        .padding()
                                        .frame(width: 60, height: 60, alignment: .center)
                                        .overlay(icon.rawValue == checklist.icon ? RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor) : nil)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .id(icon)
                            }
                        }
                    } header: {
                        Text(L10n.EditChecklist.customIcon.localized)
                    }
                }
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
                if entries.isEmpty && editMode?.wrappedValue != .active {
                    Text(L10n.ChecklistDetails.checklistIsEmpty.localized)
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                checklistTitle.text = checklist.title
            }
            .onDisappear {
                editMode?.wrappedValue = .inactive
            }
            .onReceive(checklistTitle
                        .$text
                        .debounce(for: 0.2, scheduler: DispatchQueue.main)) { newValue in
                var title = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if title.isEmpty {
                    title = L10n.EditChecklist.unnamedChecklist.localized
                }
                if checklist.title != title {
                    checklist.title = title
                    checklist.lastModified = .now
                    viewContext.saveOrRollback()
                }
            }
            .navigationTitle(checklist.title)
            // for some reason, after deleting the item app crashes on identifier access...
            .userActivity(UserActivityRegistry.ChecklistView.activityType, isActive: !checklist.isFault) { activity in
                activity.title = checklist.title
                Logger.default.info("checklist -> '\(checklist)")
                activity.userInfo = [UserActivityRegistry.ChecklistView.identifierKey: checklist.identifier]
                activity.isEligibleForHandoff = true
                activity.isEligibleForPrediction = true
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if allowOpenInSeparateWindow {
                        Button {
                            SingleChecklistView.activateSession(checklist: checklist)
                        } label: {
                            Label(L10n.Common.buttonSeparateWindow.localized, systemImage: "square.on.square")
                                .contentShape(Rectangle())
                        }
                    }
                    Button {
                        addEntry = true
                    } label: {
                        Label(L10n.ChecklistDetails.addEntryButton.localized, systemImage: "plus")
                            .contentShape(Rectangle())
                            .frame(height: 96, alignment: .trailing)
                        // this solves issue with button becoming unclickable after several clicks
                    }
                    EditButton()
                }
            }
            .sheet(isPresented: $addEntry) {
                NewChecklistEntryView(checklist: checklist)
            }
        } else {
            ChecklistListWelcomeView()
        }
    }
}
