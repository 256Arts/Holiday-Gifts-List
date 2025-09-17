//
//  GiftListsApp.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct GiftListsApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var biometrics = BiometricAuthentication()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .redacted(reason: biometrics.isAuthenticated ? [] : .privacy)
                .task {
                    // Configure and load your tips at app launch.
                    try? Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
        #if os(macOS)
        .defaultSize(CGSize(width: 600, height: 600))
        #else
        .defaultSize(CGSize(width: 500, height: 700))
        #endif
        #if targetEnvironment(simulator) || (os(macOS) && DEBUG)
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
                #if !os(macOS)
                biometrics.isAuthenticated = false
                #endif
            default:
                break
            }
        }
    }
}

let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 0
    return formatter
}()
