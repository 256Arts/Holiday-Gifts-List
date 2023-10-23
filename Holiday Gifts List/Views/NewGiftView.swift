//
//  NewGiftView.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2023-04-18.
//

import SwiftUI
import SwiftData

struct NewGiftView: View {
    
    let recipient: Recipient?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var title: String = ""
    @State var price: Double = 0.0
    @State var status: Status = .idea
    @State var notes: String = ""
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $title)
                    #if os(iOS)
                    .textInputAutocapitalization(.words)
                    #endif
                
                TextField("Price", value: $price, formatter: currencyFormatter)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                
                Picker("Status", selection: $status) {
                    Text("Idea")
                        .tag(Status.idea)
                    Text("In Transit")
                        .tag(Status.inTransit)
                    Text("Acquired")
                        .tag(Status.acquired)
                    Text("Wrapped")
                        .tag(Status.wrapped)
                }
                
                #if !os(watchOS)
                TextEditor(text: $notes)
                    .overlay(alignment: .leading) {
                        if notes.isEmpty {
                            Text("Notes")
                                .foregroundColor(.secondary)
                        }
                    }
                #else
                if !notes.isEmpty {
                    Text(notes)
                }
                #endif
            }
        }
        #if !os(watchOS)
        .navigationTitle("New Gift")
        #endif
        .toolbar {
            #if !os(watchOS)
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            #endif
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    let gift = Gift(title: title, price: price, notes: notes, status: status, recipient: recipient)
                    modelContext.insert(gift)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Gift.self, configurations: config)
    
    return NewGiftView(recipient: nil)
        .modelContainer(container)
}
