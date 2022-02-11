//
//  ContentView.swift
//  StuffMac
//
//  Created by Danis Tazetdinov on 23.01.2022.
//

import SwiftUI
import CoreData
import DataModel
import Views

struct ContentView: View {
    var body: some View {
        TabView {
            ItemListView()
            PlaceListView()
        }
    }
}
