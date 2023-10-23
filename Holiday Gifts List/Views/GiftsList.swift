//
//  GiftsList.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI
import SwiftData
import TipKit

struct AddRecipientTip: Tip {
    var title: Text { Text("Add a Recipient") }
    var message: Text? { Text("Create a list for each person you want to give gifts to.") }
    var image: Image? { nil }
}

struct GiftsList: View {
    
    @AppStorage(UserDefaults.Key.showBirthdays) private var showBirthdays = true
    @Environment(\.modelContext) private var modelContext
    @Query var recipients: [Recipient]
    @Query var gifts: [Gift]
    
    @State var showingNewGiftWithoutRecipient = false
    @State var showingSettings = false
    @State var showingNewRecipient = false
    @State var editingRecipient: Recipient?
    @State var recipientName = ""
    
    /// Recipient which will be added to a new gift the user is creating
    @State var newGiftRecipient: Recipient?
    
    private var giftsWithoutRecipients: [Gift] {
        ((try? gifts.filter(#Predicate<Gift> {
            $0.recipient == nil
        })) ?? []).sorted()
    }
    
    var body: some View {
        List {
            ForEach(recipients.sorted()) { recipient in
                Section {
                    ForEach(recipient.gifts?.sorted() ?? []) { gift in
                        GiftRow(gift: gift)
                    }

                    Button {
                        newGiftRecipient = recipient
                    } label: {
                        Label("New Gift", systemImage: "plus")
                    }
                    #if os(watchOS)
                    .foregroundColor(.accentColor)
                    #endif
                } header: {
                    HStack {
                        Image(systemName: "person.fill")
                            .accessibilityHidden(true)
                        
                        VStack(alignment: .leading) {
                            Text(recipient.name ?? "")
                            
                            HStack {
                                if showBirthdays, let daysUntil = recipient.daysUntilBirthday {
                                    ViewThatFits {
                                        Text("\(daysUntil) days left")
                                        Text("\(daysUntil) days")
                                        Text("\(daysUntil)d")
                                    }
                                }
                                
                                Text("\(currencyFormatter.string(from: NSNumber(value: recipient.spentTotal)) ?? "") spent")
                                    .accessibilityLabel("Spent")
                                    .accessibilityValue(currencyFormatter.string(from: NSNumber(value: recipient.spentTotal)) ?? "")
                                    .privacySensitive()
                            }
                            .lineLimit(1)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        #if !os(watchOS)
                        Menu {
                            Button {
                                recipientName = recipient.name ?? ""
                                editingRecipient = recipient
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                modelContext.delete(recipient)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .symbolVariant(.circle)
                                .imageScale(.large)
                                .frame(height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.borderless)
                        .accessibilitySortPriority(-1)
                        #endif
                    }
                }
            }
            
            Section {
                ForEach(giftsWithoutRecipients) { gift in
                    GiftRow(gift: gift)
                }
                
                Button {
                    showingNewGiftWithoutRecipient = true
                } label: {
                    Label("New Gift", systemImage: "plus")
                }
                #if os(watchOS)
                .foregroundColor(.accentColor)
                #endif
            } header: {
                Label("Gifts with no Recipient", systemImage: "questionmark")
            }
        }
        .headerProminence(.increased)
        .navigationTitle("Gifts List")
        .navigationDestination(for: Gift.self) { gift in
            GiftView(gift: gift)
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gear")
                        .accessibilityLabel("Settings")
                }
            }
            #endif
            
            #if os(watchOS)
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingNewRecipient = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .accessibilityLabel("Add Recipient")
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewRecipient = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .accessibilityLabel("Add Recipient")
                }
                .popoverTip(AddRecipientTip())
            }
            #endif
        }
        .sheet(isPresented: $showingNewGiftWithoutRecipient) {
            NavigationStack {
                NewGiftView(recipient: nil)
            }
        }
        .sheet(item: Binding(get: {
            newGiftRecipient
        }, set: { newValue in
            newGiftRecipient = newValue
        })) { recipient in
            NavigationStack {
                NewGiftView(recipient: recipient)
            }
        }
        .sheet(isPresented: $showingNewRecipient) {
            NavigationStack {
                NewRecipientView()
            }
        }
        .sheet(item: $editingRecipient) { recipient in
            NavigationStack {
                RecipientView(recipient: recipient)
            }
        }
        #if os(iOS)
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        #endif
    }
}

#Preview {
    GiftsList()
        #if DEBUG
        .modelContainer(previewContainer)
        #endif
}
