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
import Localization

@MainActor
class ToolbarDelegate: NSObject {
    var selectionChanged: ((Int) -> Void)?

#if targetEnvironment(macCatalyst)
    var selectedIndex = 0 {
        didSet {
            guard oldValue != selectedIndex else { return }
            tabSelector?.setSelected(true, at: selectedIndex)
            Logger.default.info("[MACTABBAR] setting tab to \(selectedIndex)")
        }
    }
    private weak var tabSelector: NSToolbarItemGroup?
#else
    var selectedIndex = 0
#endif
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
            let labels = [L10n.App.toolbarItems.localized, L10n.App.toolbarPlaces.localized, L10n.App.toolbarChecklists.localized]
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
        selectionChanged?(selectedIndex)
    }
}
#endif

@MainActor
struct MacContentView: View {
    @SceneStorage("selectedTab") private var selected = Tab.items {
        didSet {
            guard oldValue != selected else { return }
            toolbarDelegate.selectedIndex = selected.rawValue
            updateSceneTitle()
        }
    }

    @Binding private var selectedItem: Item?
    @Binding private var selectedPlace: ItemPlace?
    @Binding private var selectedChecklist: Checklist?

    @Binding private var requestedTab: Tab?

    @State private var toolbarDelegate = ToolbarDelegate()

    @State private var scene: UIWindowScene?

    init(selectedItem: Binding<Item?>, selectedPlace: Binding<ItemPlace?>, selectedChecklist: Binding<Checklist?>, requestedTab: Binding<Tab?>) {
        _selectedItem = selectedItem
        _selectedPlace = selectedPlace
        _selectedChecklist = selectedChecklist
        _requestedTab = requestedTab
    }

    private func updateSceneTitle() {
        switch selected {
        case .items:
            scene?.title = L10n.App.titleItems.localized
        case .places:
            scene?.title = L10n.App.titlePlaces.localized
        case .checklists:
            scene?.title = L10n.App.titleChecklists.localized
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

                toolbarDelegate.selectionChanged = { index in
                    guard let tab = Tab(rawValue: index) else {
                        return
                    }
                    selected = tab
                }

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
            .onChange(of: selectedItem) { newValue in
                if newValue != nil {
                    selected = .items
                    toolbarDelegate.selectedIndex = selected.rawValue
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
            .onChange(of: requestedTab) { newValue in
                if let tab = newValue {
                    selected = tab
                }
            }
            .onAppear {
                toolbarDelegate.selectedIndex = selected.rawValue
                updateSceneTitle()
            }
    }
}
