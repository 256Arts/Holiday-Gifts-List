//
//  GiftView.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI
import SwiftData

struct GiftView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query var recipients: [Recipient]
    
    @Bindable var gift: Gift
    
    @State var title: String
    @State var price: Double
    @State var status: Status
    @State var notes: String
    
    init(gift: Gift) {
        self.gift = gift
        self._title = State(initialValue: gift.title ?? "")
        self._price = State(initialValue: gift.price ?? 0)
        self._status = State(initialValue: gift.status ?? .idea)
        self._notes = State(initialValue: gift.notes ?? "")
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $title, onCommit: {
                    gift.title = title
                })
                    #if os(iOS)
                    .textInputAutocapitalization(.words)
                    #endif
                    .privacySensitive()
                
                TextField("Price", value: $price, formatter: currencyFormatter, onCommit: {
                    gift.price = price
                })
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .privacySensitive()
                
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
            Section {
                Picker("Recipient", selection: $gift.recipient) {
                    Text("None")
                        .tag(nil as Recipient?)
                    
                    Divider()
                    
                    ForEach(recipients) { recipient in
                        Text(recipient.name ?? "")
                            .tag(recipient as Recipient?)
                    }
                }
            }
            #if !os(watchOS)
            Section {
                if let url = gift.amazonURL {
                    Link(destination: url) {
                        Label("Search Amazon", systemImage: "magnifyingglass")
                    }
                }
            }
            #endif
            Section {
                Button("Delete", role: .destructive) {
                    modelContext.delete(gift)
                    dismiss()
                }
            }
        }
        .navigationTitle("Gift")
        .onChange(of: status) { _, newValue in
            gift.status = newValue
        }
        .onChange(of: notes) { _, newValue in
            gift.notes = newValue
        }
    }
}
