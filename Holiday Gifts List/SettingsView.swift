//
//  SettingsView.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var giftsData: GiftsData
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage(UserDefaults.Key.requireAuthenication) private var requireAuthenication = false
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Lock with Biometrics", isOn: $requireAuthenication)
                Button("Erase All Data", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
            
            Section {
                Link(destination: URL(string: "https://www.jaydenirwin.com/")!) {
                    Label("Developer Website", systemImage: "safari")
                }
                Link(destination: URL(string: "https://www.256arts.com/joincommunity/")!) {
                    Label("Join Community", systemImage: "bubble.left.and.bubble.right")
                }
                Link(destination: URL(string: "https://github.com/256Arts/Holiday-Gifts-List")!) {
                    Label("Contribute on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                }
            } header: {
                Text("More")
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .alert("Delete All Data?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel, action: { })
            Button("Delete", role: .destructive) {
                giftsData.gifts.removeAll()
                giftsData.recipients.removeAll()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
