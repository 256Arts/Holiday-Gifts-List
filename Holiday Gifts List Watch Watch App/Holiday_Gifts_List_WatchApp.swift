//
//  Holiday_Gifts_List_WatchApp.swift
//  Holiday Gifts List Watch Watch App
//
//  Created by 256 Arts Developer on 2023-07-24.
//

import SwiftUI

@main
struct Holiday_Gifts_List_Watch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                GiftsList()
            }
        }
        #if targetEnvironment(simulator)
        .modelContainer(previewContainer)
        #else
        .modelContainer(for: [Gift.self, Recipient.self])
        #endif
    }
}

let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 0
    return formatter
}()
