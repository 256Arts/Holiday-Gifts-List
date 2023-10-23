//
//  HolidayGiftsListApp.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct HolidayGiftsListApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var biometrics = BiometricAuthentication()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    GiftsList()
                }
                .tabItem {
                    Label("Gifts", systemImage: "gift")
                }
                NavigationStack {
                    ShoppingList()
                }
                .tabItem {
                    Label("Shopping List", systemImage: "list.bullet")
                }
            }
            .redacted(reason: biometrics.isAuthenticated ? [] : .privacy)
            .task {
                // Configure and load your tips at app launch.
                try? Tips.configure([
                    .displayFrequency(.immediate),
                    .datastoreLocation(.applicationDefault)
                ])
            }
        }
//        .modelContainer(for: [Gift.self, Recipient.self])
        #if DEBUG
        .modelContainer(previewContainer)
        #endif
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                Task {
                    await biometrics.authenticate()
                }
            case .background:
                biometrics.isAuthenticated = false
            default:
                break
            }
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
                .scenePadding()
        }
        #endif
    }
}

let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 0
    return formatter
}()
