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
                Tab("Gifts", systemImage: "gift") {
                    NavigationStack {
                        GiftsList()
                    }
                }
                
                Tab("My Wishlist", systemImage: "heart") {
                    NavigationStack {
                        MyWishlistView()
                    }
                }
                
                Tab("Shopping List", systemImage: "list.bullet") {
                    NavigationStack {
                        ShoppingList()
                    }
                }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .redacted(reason: biometrics.isAuthenticated ? [] : .privacy)
            .task {
                // Configure and load your tips at app launch.
                try? Tips.configure([
                    .displayFrequency(.immediate),
                    .datastoreLocation(.applicationDefault)
                ])
            }
        }
        #if targetEnvironment(macCatalyst)
        .defaultSize(CGSize(width: 400, height: 600))
        #else
        .defaultSize(CGSize(width: 500, height: 700))
        #endif
        #if targetEnvironment(simulator)
        .modelContainer(previewContainer)
        #else
        .modelContainer(for: [Gift.self, Recipient.self, Event.self])
        #endif
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                Task {
                    await biometrics.authenticate()
                }
            case .background:
                #if !os(macOS) && !targetEnvironment(macCatalyst)
                biometrics.isAuthenticated = false
                #endif
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
