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

struct PlaceDetailsView: View {

    @ObservedObject var place: ItemPlace
    @Environment(\.managedObjectContext) private var viewContext

    @SectionedFetchRequest(
        sectionIdentifier: \Item.categoryTitle,
        sortDescriptors: [
            SortDescriptor(\Item.category?.title),
            SortDescriptor(\Item.lastModified)
                         ],
        animation: .default)
    private var items: SectionedFetchResults<String, Item>
    @State private var readyForDisplay = false

    public init(place: ItemPlace) {
        self.place = place
    }


    func title(for sectionIdentifier: SectionedFetchResults<String, Item>.Section.ID) -> String {
        if sectionIdentifier.isEmpty {
            return "<Unnamed>"
        } else {
            return sectionIdentifier
        }
    }

    public var body: some View {
        if readyForDisplay {
            List {
                ForEach(items) { section in
                    Section(header: Text(title(for: section.id))) {
                        ForEach(section) { item in
                            Button {

                            } label: {
                                ItemListElement(item: item)
                            }
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
            .navigationTitle(place.title ?? "Unnamed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .onAppear {
                print(FileStorageManager.shared.urls(withPrefix: "S"))
            }
        } else {
            Color.clear
                .onAppear {
                    items.nsPredicate = NSPredicate(format: "\(#keyPath(Item.place)) == %@", place)
                    readyForDisplay = true
                }
        }
    }
}
