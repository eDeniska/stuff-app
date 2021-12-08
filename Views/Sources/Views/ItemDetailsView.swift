//
//  ItemDetailsView.swift
//  
//
//  Created by Danis Tazetdinov on 08.12.2021.
//

import SwiftUI
import DataModel
import CoreData

public struct ItemDetailsView: View {
    private let item: Item

    public init(item: Item) {
        self.item = item
    }

    public var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//struct ItemDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemDetailsView()
//    }
//}
