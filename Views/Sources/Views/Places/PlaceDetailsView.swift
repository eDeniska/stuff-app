//
//  File.swift
//  
//
//  Created by Danis Tazetdinov on 24.01.2022.
//

import SwiftUI
import DataModel
import CoreData
import Logger

// TODO: need empty place view

struct PlaceDetailsView: View {

    @ObservedObject var place: ItemPlace
    @Environment(\.managedObjectContext) private var viewContext

    private var items: SectionedFetchResults<String, Item> { itemsRequest.wrappedValue }
    private var itemsRequest: SectionedFetchRequest<String, Item>

    private let allowOpenInSeparateWindow: Bool

    public init(place: ItemPlace, allowOpenInSeparateWindow: Bool = true) {
        self.place = place

        itemsRequest = SectionedFetchRequest(entity: Item.entity(),
                                             sectionIdentifier: \Item.categoryTitle,
                                             sortDescriptors: [
                                                NSSortDescriptor(key: #keyPath(Item.category.order), ascending: false),
                                                NSSortDescriptor(key: #keyPath(Item.category.title), ascending: true),
                                                NSSortDescriptor(key: #keyPath(Item.lastModified), ascending: true)
                                             ],
                                             predicate: NSPredicate(format: "\(#keyPath(Item.place)) == %@", place),
                                             animation: .default)
        self.allowOpenInSeparateWindow = UIApplication.shared.supportsMultipleScenes && allowOpenInSeparateWindow
    }


    func title(for sectionIdentifier: SectionedFetchResults<String, Item>.Section.ID) -> String {
        if sectionIdentifier.isEmpty {
            return "<Unnamed>"
        } else {
            return sectionIdentifier
        }
    }

    public var body: some View {
        List {
            ForEach(items) { section in
                Section(header: Text(title(for: section.id))) {
                    ForEach(section) { item in
                        Button {

                        } label: {
                            ItemListElement(item: item)
                        }
                        .buttonStyle(.plain)
                        // TODO: present item details
                        // ItemDetailsView(item: item)
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
        .navigationTitle(place.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if allowOpenInSeparateWindow {
                    Button {
                        SinglePlaceView.activateSession(place: place)
                    } label: {
                        Label("Open in separate window", systemImage: "square.on.square")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }
}
