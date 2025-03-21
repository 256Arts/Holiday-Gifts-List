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
    let sortOrder: Int
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Query(sort: \Event.name) var events: [Event]
    
    @State var title: String = ""
    @State var price: Double = 0.0
    @State var status: Status = .idea
    @State var notes: String = ""
    @State var event: Event?
    
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
                    ForEach(Status.allCases) { status in
                        Label {
                            Text(status.title)
                        } icon: {
                            status.icon
                        }
                        .tag(status)
                    }
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
            
            Section {
                Picker("Event", selection: $event) {
                    Text("None")
                        .tag(nil as Event?)
                    
                    Divider()
                    
                    ForEach(events) { event in
                        Label {
                            Text(event.name ?? "")
                        } icon: {
                            event.icon ?? Image("")
                        }
                        .tag(event as Event?)
                    }
                }
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
                    let gift = Gift(title: title, sortOrder: sortOrder, price: price, notes: notes, status: status, recipient: recipient, event: event)
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
    
    return NewGiftView(recipient: nil, sortOrder: 0)
        .modelContainer(container)
}
