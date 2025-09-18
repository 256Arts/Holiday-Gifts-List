//
//  GiftListsApp.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI
import SwiftData
import TipKit
import LocalAuthentication

@main
struct GiftListsApp: App {
    
    @AppStorage(UserDefaults.Key.requireAuthenication) private var requireAuthenication = false
    @AppStorage(UserDefaults.Key.recipientSummaryInfo) private var recipientSummaryInfoValue = RecipientSummaryInfo.defaultInfo.rawValue
    @AppStorage(UserDefaults.Key.showEventWallpaper) private var showEventWallpaper = true
    @AppStorage(UserDefaults.Key.showHolidayCountdown) private var showHolidayCountdown = true
    @AppStorage(UserDefaults.Key.recipientSortBy) private var recipientSortByValue = RecipientSort.defaultSort.rawValue
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var biometrics = BiometricAuthentication()
    
    private var biometryType: LABiometryType {
        LAContext().biometryType
    }
    
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
        .commands {
            CommandGroup(after: .newItem) {
                Toggle("Require \(biometryType.name ?? "")", systemImage: biometryType.systemImageName ?? "", isOn: $requireAuthenication)
            }
            
            CommandGroup(before: .toolbar) {
                Toggle("Show Wallpaper", systemImage: "photo", isOn: $showEventWallpaper)
                
                Toggle("Show Countdown", systemImage: "timer", isOn: $showHolidayCountdown)
                
                Picker("Recipient Shows", systemImage: "person", selection: $recipientSummaryInfoValue) {
                    ForEach(RecipientSummaryInfo.allCases) { info in
                        Text(info.title)
                            .tag(info.rawValue)
                    }
                }
                
                Picker("Sort By", systemImage: "arrow.up.arrow.down", selection: $recipientSortByValue) {
                    ForEach(RecipientSort.allCases) { sort in
                        Text(sort.title)
                            .tag(sort.rawValue)
                    }
                }
            }
        }
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
