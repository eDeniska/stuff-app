//
//  StuffWidgetBundle.swift
//  StuffWidgetExtension
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import Foundation
import WidgetKit
import SwiftUI

@main
struct StuffWidgetBundle: WidgetBundle {
    
    @WidgetBundleBuilder var body: some Widget {
        RecentChecklistsWidget()
        ChecklistEntriesWidget()
    }
}
