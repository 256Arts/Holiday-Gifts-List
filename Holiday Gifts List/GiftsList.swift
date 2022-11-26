//
//  GiftsList.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI

struct GiftsList: View {
    
    @EnvironmentObject var giftsData: GiftsData
    
    @State var showingSettings = false
    @State var showingRecipientNameField = false
    @State var editingRecipientID: UUID?
    @State var recipientName = ""
    
    var body: some View {
        List {
            ForEach(giftsData.recipients) { recipient in
                Section {
                    ForEach(giftsData.gifts.filter({ $0.recipientID == recipient.id })) { gift in
                        GiftRow(gift: Binding(get: {
                            gift
                        }, set: { newValue in
                            if let index = giftsData.gifts.firstIndex(where: { $0.id == gift.id }) {
                                giftsData.gifts[index] = newValue
                            }
                        }))
                    }
                    
                    Button {
                        giftsData.gifts.append(Gift(id: UUID(), title: "", recipientID: recipient.id, price: 0, isPurchased: false))
                    } label: {
                        Label("New Gift", systemImage: "plus")
                    }
                } header: {
                    HStack {
                        Image(systemName: "person.fill")
                        Text(recipient.name)
                            .privacySensitive()
                        Menu {
                            Button {
                                recipientName = recipient.name
                                editingRecipientID = recipient.id
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                giftsData.gifts.removeAll(where: { $0.recipientID == recipient.id })
                                giftsData.recipients.removeAll(where: { $0.id == recipient.id })
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                        Spacer()
                        Text(currencyFormatter.string(from: NSNumber(value: recipient.priceTotal)) ?? "")
                            .privacySensitive()
                    }
                }
            }
            
            Section {
                ForEach($giftsData.giftsWithoutRecipients) { $gift in
                    GiftRow(gift: $gift)
                }
                
                Button {
                    giftsData.gifts.append(Gift(id: UUID(), title: "", recipientID: nil, price: 0, isPurchased: false))
                } label: {
                    Label("New Gift", systemImage: "plus")
                }
            } header: {
                Label("Gifts with no Recipient", systemImage: "questionmark")
            }
        }
        .headerProminence(.increased)
        .navigationTitle("Holiday Gifts List")
        .toolbar {
            #if !os(macOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gear")
                }
            }
            #endif
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingRecipientNameField = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
        .alert("New Recipient", isPresented: $showingRecipientNameField, actions: {
            TextField("Recipient Name", text: $recipientName)
            Button("Cancel", role: .cancel) {
                recipientName = ""
            }
            Button("Add") {
                giftsData.recipients.append(Recipient(id: UUID(), name: recipientName))
                recipientName = ""
            }
        })
        .alert("Edit Recipient", isPresented: Binding(get: {
            editingRecipientID != nil
        }, set: { newValue in
            if !newValue {
                editingRecipientID = nil
            }
        })) {
            TextField("Recipient Name", text: $recipientName)
            Button("Cancel", role: .cancel) {
                recipientName = ""
            }
            Button("Save") {
                if let index = giftsData.recipients.firstIndex(where: { $0.id == editingRecipientID }) {
                    giftsData.recipients[index].name = recipientName
                }
                recipientName = ""
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
            }
        }
    }
}

struct GiftsList_Previews: PreviewProvider {
    static var previews: some View {
        GiftsList()
    }
}
