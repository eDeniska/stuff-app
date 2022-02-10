//
//  MacContentView.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 08.02.2022.
//

import SwiftUI
import Views
import Logger
import DataModel
import CoreData

@MainActor
class ToolbarDelegate: NSObject {
    var selectionChanged: ((Int) -> Void)?

#if targetEnvironment(macCatalyst)
    var selectedIndex = 0 {
        didSet {
            tabSelector?.setSelected(true, at: selectedIndex)
            Logger.default.info("[MACTABBAR] setting tab to \(selectedIndex)")
        }
    }
    private weak var tabSelector: NSToolbarItemGroup?
#else
    var selectedIndex = 0
#endif
}

extension Notification.Name {
    static let itemsTabSelected = Notification.Name("com.tazetdinov.stuff.toolbar.tab-items")
    static let placesTabSelected = Notification.Name("com.tazetdinov.stuff.toolbar.tab-places")
    static let checklistsTabSelected = Notification.Name("com.tazetdinov.stuff.toolbar.tab-checklists")
}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let activeScreenSelector = NSToolbarItem.Identifier("com.tazetdinov.stuff.toolbar.screenSelector")
}

extension ToolbarDelegate: NSToolbarDelegate {

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItem.Identifier] = [
//            .toggleSidebar,
//            .flexibleSpace,
            .activeScreenSelector
        ]
        return identifiers
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        switch itemIdentifier {
        case .activeScreenSelector:
            let configuration = UIImage.SymbolConfiguration(scale: .large)
            let images = [UIImage(systemName: "tag", withConfiguration: configuration)!,
                          UIImage(systemName: "house", withConfiguration: configuration)!,
                          UIImage(systemName: "list.bullet.rectangle", withConfiguration: configuration)!]
            let labels = ["Items", "Places", "Checklists"]
            let item = NSToolbarItemGroup(itemIdentifier: itemIdentifier,
                                          images: images,
                                          selectionMode: .selectOne,
                                          labels: labels,
                                          target: self,
                                          action: #selector(ToolbarDelegate.toolbarSelectionChanged))
            tabSelector = item
            item.setSelected(true, at: selectedIndex)
            Logger.default.info("[MACTABBAR] setting tab to \(selectedIndex)")

            return item

        default:
            return nil
        }
    }

    @objc private func toolbarSelectionChanged(_ sender: NSToolbarItemGroup) {
        selectedIndex = sender.selectedIndex
        switch sender.selectedIndex {
        case 0:
            NotificationCenter.default.post(name: .itemsTabSelected, object: nil)
        case 1:
            NotificationCenter.default.post(name: .placesTabSelected, object: nil)
        case 2:
            NotificationCenter.default.post(name: .checklistsTabSelected, object: nil)
        default:
            break
        }
    }


}
#endif

@MainActor
struct MacContentView: View {
    @SceneStorage("selectedTab") private var selected = Tab.items {
        didSet {
            updateSceneTitle()
        }
    }

    // TODO: selection is not properly updated
    @Binding private var selectedItem: Item?
    @Binding private var selectedPlace: ItemPlace?
    @Binding private var selectedChecklist: Checklist?

    @State private var toolbarDelegate = ToolbarDelegate()

    @State private var scene: UIWindowScene?

    init(selectedItem: Binding<Item?>, selectedPlace: Binding<ItemPlace?>, selectedChecklist: Binding<Checklist?>) {
        _selectedItem = selectedItem
        _selectedPlace = selectedPlace
        _selectedChecklist = selectedChecklist
    }

    private func updateSceneTitle() {
        switch selected {
        case .items:
            scene?.title = "Stuff – Items"
        case .places:
            scene?.title = "Stuff – Places"
        case .checklists:
            scene?.title = "Stuff – Checklists"
        }
    }

    var body: some View {
        ZStack {
            ItemListView(selectedItem: $selectedItem)
                .opacity(selected == .items ? 1 : 0)
            PlaceListView(selectedPlace: $selectedPlace)
                .opacity(selected == .places ? 1 : 0)
            ChecklistListView(selectedChecklist: $selectedChecklist)
                .opacity(selected == .checklists ? 1 : 0)
        }
            .withWindow { window in
#if targetEnvironment(macCatalyst)
                guard let windowScene = window?.windowScene else { return }
                guard windowScene.titlebar?.toolbar?.delegate !== toolbarDelegate else { return }

                let toolbar = NSToolbar(identifier: "main")
                toolbar.displayMode = .iconOnly
                toolbar.centeredItemIdentifier = .activeScreenSelector
                toolbar.delegate = toolbarDelegate
                windowScene.titlebar?.toolbar = toolbar
                windowScene.titlebar?.toolbarStyle = .unified
                self.scene = windowScene
                updateSceneTitle()
#endif
            }
            .onReceive(NotificationCenter.default.publisher(for: .itemsTabSelected, object: nil)) { _ in
                selected = .items
            }
            .onReceive(NotificationCenter.default.publisher(for: .placesTabSelected, object: nil)) { _ in
                selected = .places
            }
            .onReceive(NotificationCenter.default.publisher(for: .checklistsTabSelected, object: nil)) { _ in
                selected = .checklists
            }
            .onChange(of: selectedItem) { newValue in
                if newValue != nil {
                    selected = .items
                    toolbarDelegate.selectedIndex = selected.rawValue
                }
            }
            .onChange(of: selectedPlace) { newValue in
                if newValue != nil {
                    selected = .places
                    toolbarDelegate.selectedIndex = selected.rawValue
                }
            }
            .onChange(of: selectedChecklist) { newValue in
                if newValue != nil {
                    selected = .checklists
                    toolbarDelegate.selectedIndex = selected.rawValue
                }
            }
            .onAppear {
                toolbarDelegate.selectedIndex = selected.rawValue
                updateSceneTitle()
            }
    }
}
