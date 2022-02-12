//
//  ContentView.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 07.12.2021.
//

import SwiftUI
import CoreData
import Views
import DataModel
import Localization

@MainActor
struct ContentView: View {

    @Binding var selectedItem: Item?
    @Binding var selectedPlace: ItemPlace?
    @Binding var selectedChecklist: Checklist?
    @Binding var requestedTab: Tab?

    @SceneStorage("selectedTab") private var selected: Tab = .items

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase

    @State private var showItemCapture = false

    @ViewBuilder private func platformView() -> some View {
        if UIDevice.current.isMac {
            MacContentView(selectedItem: $selectedItem, selectedPlace: $selectedPlace, selectedChecklist: $selectedChecklist, requestedTab: $requestedTab)
        } else {
            TabView(selection: $selected) {
                ItemListView(selectedItem: $selectedItem)
                    .tag(Tab.items)
                PlaceListView(selectedPlace: $selectedPlace)
                    .tag(Tab.places)
                ChecklistListView(selectedChecklist: $selectedChecklist)
                    .tag(Tab.checklists)
                // TODO: consider removing settings altogether
//                NavigationView {
//                    Text("Settings")
//                        .navigationTitle("Settings")
//                }
//                .tabItem {
//                    Label("Settings", systemImage: "gear")
//                }
            }
            .onChange(of: requestedTab) { newValue in
                if let tab = newValue {
                    selected = tab
                }
            }
            .onChange(of: selectedItem) { newValue in
                if newValue != nil {
                    selected = .items
                }
            }
            .onChange(of: selectedPlace) { newValue in
                if newValue != nil {
                    selected = .places
                }
            }
            .onChange(of: selectedChecklist) { newValue in
                if newValue != nil {
                    selected = .checklists
                }
            }
        }
    }

    var body: some View {
        platformView()
            .onReceive(NotificationCenter.default.publisher(for: .itemCaptureRequest, object: nil)) { _ in
                showItemCapture = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .checklistSelected, object: nil)) { notification in
                if let checklistID = notification.userInfo?[ChecklistEntryListView.identifierKey] as? UUID {
                    selectedChecklist = Checklist.checklist(with: checklistID, in: viewContext)
                }
            }
            .sheet(isPresented: $showItemCapture) {
                NavigationView {
                    ItemDetailsView(item: nil, allowOpenInSeparateWindow: false, startWithPhoto: true)
                }
            }
            .onChange(of: scenePhase) { phase in
                if phase == .background {
                    UIApplication.shared.shortcutItems = Checklist.recentChecklists(in: viewContext).map { checklist in
                        UIApplicationShortcutItem(type: QuickAction.checklistSelected.rawValue,
                                                  localizedTitle: checklist.title,
                                                  localizedSubtitle: L10n.App.quickActionChecklist.localized,
                                                  icon: UIApplicationShortcutIcon(systemImageName: checklist.icon ?? "list.bullet.rectangle"),
                                                  userInfo: [ChecklistEntryListView.identifierKey: checklist.identifier.uuidString as NSString])
                    }
                }
            }
    }
}
