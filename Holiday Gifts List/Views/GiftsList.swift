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
    
    @AppStorage(UserDefaults.Key.recipientSortBy) private var recipientSortByValue = RecipientSort.defaultSort.rawValue
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Recipient> { $0.name != "<Me>" }) var recipients: [Recipient]
    @Query var gifts: [Gift]
    @Query(sort: \Event.name) var events: [Event]
    
    @State var recipientSortBy: RecipientSort
    @State var includeGivenGifts = false
    @State var showingNewGiftWithoutRecipient = false
    @State var eventFilter: Event?
    @State var newGiftSortOrder = 0
    @State var showingSettings = false
    @State var showingNewRecipient = false
    @State var newRecipientSortOrder = 0
    @State var editingRecipient: Recipient?
    @State var recipientName = ""
    
    /// Recipient which will be added to a new gift the user is creating
    @State var newGiftRecipient: Recipient?
    
    init() {
        recipientSortBy = .init(rawValue: UserDefaults.standard.string(forKey: UserDefaults.Key.recipientSortBy) ?? "") ?? .defaultSort
    }
    
    private var giftsWithoutRecipients: [Gift] {
        ((try? gifts.filter(#Predicate<Gift> {
            $0.recipient == nil
        })) ?? []).sorted()
    }
    
    var body: some View {
        List {
            #if !os(watchOS)
            Section {
                HStack {
                    ForEach(events) { event in
                        Toggle(event.name ?? "", isOn: Binding(get: {
                            eventFilter == event
                        }, set: { newValue in
                            if newValue {
                                eventFilter = event
                            } else {
                                eventFilter = nil
                            }
                        }))
                        .toggleStyle(.button)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .background(Color(uiColor: UIColor.secondarySystemGroupedBackground), in: Capsule())
                    }
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
            }
            #endif
            
            ForEach(recipients.sorted(by: recipientSortBy)) { recipient in
                #if os(watchOS)
                Section {
                    ForEach(filterAndSort(recipient.gifts ?? [])) { gift in
                        GiftRow(gift: gift, showStatus: true)
                    }

                    Button {
                        newGiftSortOrder = (gifts.max(by: { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 })?.sortOrder ?? 0) + 1
                        newGiftRecipient = recipient
                    } label: {
                        Label("New Gift", systemImage: "plus")
                    }
                    .foregroundColor(.accentColor)
                } header: {
                    RecipientRow(recipient: recipient, sortingByBirthday: recipientSortBy == .nearestBirthday, filteredGifts: filterAndSort(recipient.gifts ?? []), recipientName: $recipientName, editingRecipient: $editingRecipient)
                }
                #else
                DisclosureGroup {
                    ForEach(filterAndSort(recipient.gifts ?? [])) { gift in
                        GiftRow(gift: gift, showStatus: true)
                    }
                    
                    Button {
                        newGiftSortOrder = (gifts.max(by: { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 })?.sortOrder ?? 0) + 1
                        newGiftRecipient = recipient
                    } label: {
                        Label("New Gift", systemImage: "plus")
                    }
                } label: {
                    RecipientRow(recipient: recipient, sortingByBirthday: recipientSortBy == .nearestBirthday, filteredGifts: filterAndSort(recipient.gifts ?? []), recipientName: $recipientName, editingRecipient: $editingRecipient)
                }
                #endif
            }
            
            #if !os(watchOS)
            DisclosureGroup {
                ForEach(filterAndSort(giftsWithoutRecipients)) { gift in
                    GiftRow(gift: gift, showStatus: true)
                }
                
                Button {
                    newGiftSortOrder = (gifts.max(by: { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 })?.sortOrder ?? 0) + 1
                    showingNewGiftWithoutRecipient = true
                } label: {
                    Label("New Gift", systemImage: "plus")
                }
                #if os(watchOS)
                .foregroundColor(.accentColor)
                #endif
            } label: {
                HStack {
                    Image(systemName: "person.slash.fill")
                        .accessibilityHidden(true)
                    
                    Text("Gifts with no Recipient")
                        .bold()
                }
                .foregroundStyle(filterAndSort(giftsWithoutRecipients).isEmpty ? .secondary : .primary)
            }
            #endif
        }
        .headerProminence(.increased)
        #if !targetEnvironment(macCatalyst)
        .navigationTitle("Gifts List")
        #endif
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
                    newRecipientSortOrder = (recipients.max(by: { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 })?.sortOrder ?? 0) + 1
                    showingNewRecipient = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .accessibilityLabel("Add Recipient")
                }
                .popoverTip(AddRecipientTip())
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Filter", systemImage: "line.3.horizontal.decrease") {
                    Toggle("Include Given Gifts", isOn: $includeGivenGifts)
                    Picker("Sort By", selection: $recipientSortBy) {
                        ForEach(RecipientSort.allCases) { sort in
                            Text(sort.title)
                                .tag(sort)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            #endif
        }
        .sheet(isPresented: $showingNewGiftWithoutRecipient) {
            NavigationStack {
                NewGiftView(recipient: nil, sortOrder: newGiftSortOrder)
            }
        }
        .sheet(item: Binding(get: {
            newGiftRecipient
        }, set: { newValue in
            newGiftRecipient = newValue
        })) { recipient in
            NavigationStack {
                NewGiftView(recipient: recipient, sortOrder: newGiftSortOrder)
            }
        }
        .sheet(isPresented: $showingNewRecipient) {
            NavigationStack {
                NewRecipientView(sortOrder: newRecipientSortOrder)
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
        .onChange(of: recipientSortBy) { _, newValue in
            recipientSortByValue = newValue.rawValue
        }
        .onAppear {
            if events.isEmpty {
                modelContext.insert(Event(name: "Birthday", date: .distantPast))
                modelContext.insert(Event(name: "Holidays", date: Calendar.current.date(from: DateComponents(month: 12, day: 25))))
            }
        }
    }
    
    private func filterAndSort(_ gifts: [Gift]) -> [Gift] {
        gifts
            .filter { includeGivenGifts || $0.status != .given }
            .filter { eventFilter == nil || eventFilter == $0.event }
            .sorted()
    }
}

#Preview {
    GiftsList()
        #if DEBUG
        .modelContainer(previewContainer)
        #endif
}
