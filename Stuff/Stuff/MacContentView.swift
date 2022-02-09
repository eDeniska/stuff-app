//
//  MacContentView.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 08.02.2022.
//

import SwiftUI
import Views
import Logger

@MainActor
class ToolbarDelegate: NSObject {
    var selectionChanged: ((Int) -> Void)?
#if targetEnvironment(macCatalyst)
    var selectedIndex = 0 {
        didSet {
            tabSelector?.setSelected(true, at: selectedIndex)
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
            .flexibleSpace,
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

struct MacContentView: View {
    @SceneStorage("selectedTab") private var selected = 0
    private let toolbarDelegate = ToolbarDelegate()

    init() {
    }

    var body: some View {
        ZStack {
            ItemListView()
                .opacity(selected == 0 ? 1 : 0)
            PlaceListView()
                .opacity(selected == 1 ? 1 : 0)
            ChecklistListView()
                .opacity(selected == 2 ? 1 : 0)
        }
            .withWindow { window in
#if targetEnvironment(macCatalyst)
                guard let windowScene = window?.windowScene else { return }

                let toolbar = NSToolbar(identifier: "main")
                toolbar.delegate = toolbarDelegate
                toolbar.displayMode = .iconOnly
                toolbar.centeredItemIdentifier = .activeScreenSelector

                windowScene.titlebar?.toolbar = toolbar
                windowScene.titlebar?.toolbarStyle = .unified
#endif
            }
            .onReceive(NotificationCenter.default.publisher(for: .itemsTabSelected, object: nil)) { _ in
                selected = 0
            }
            .onReceive(NotificationCenter.default.publisher(for: .placesTabSelected, object: nil)) { _ in
                selected = 1
            }
            .onReceive(NotificationCenter.default.publisher(for: .checklistsTabSelected, object: nil)) { _ in
                selected = 2
            }
            .onAppear {
                toolbarDelegate.selectedIndex = selected
            }
    }
}
