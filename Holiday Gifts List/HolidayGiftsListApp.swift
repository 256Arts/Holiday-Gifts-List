//
//  HolidayGiftsListApp.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI

@main
struct HolidayGiftsListApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var biometrics = BiometricAuthentication()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
            }
            .redacted(reason: biometrics.isAuthenticated ? [] : .privacy)
        }
        .onChange(of: scenePhase) { phase in
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
