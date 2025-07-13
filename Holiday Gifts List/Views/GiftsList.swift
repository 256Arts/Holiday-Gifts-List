//
//  GiftsList.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI
import SwiftData
import TipKit
import LocalAuthentication

struct AddRecipientTip: Tip {
    var title: Text { Text("Add a Recipient") }
    var message: Text? { Text("Create a list for each person you want to give gifts to.") }
    var image: Image? { nil }
}

struct GiftsList: View {
    
    @AppStorage(UserDefaults.Key.requireAuthenication) private var requireAuthenication = false
    @AppStorage(UserDefaults.Key.recipientSummaryInfo) private var recipientSummaryInfoValue = RecipientSummaryInfo.defaultInfo.rawValue
    @AppStorage(UserDefaults.Key.recipientSortBy) private var recipientSortByValue = RecipientSort.defaultSort.rawValue
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityAssistiveAccessEnabled) private var isAssistiveAccessEnabled
    @Query(filter: #Predicate<Recipient> { $0.name != "<Me>" }) var recipients: [Recipient]
    @Query var gifts: [Gift]
    @Query(sort: \Event.name) var events: [Event]
    
    @State var recipientSortBy: RecipientSort
    @State var includeGivenGifts = false
    @State var showingNewGiftWithoutRecipient = false
    @State var eventFilter: Event?
    @State var newGiftSortOrder = 0
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
    
    private var biometryType: LABiometryType {
        LAContext().biometryType
    }
    
    var body: some View {
        List {
            #if !os(watchOS)
            if !isAssistiveAccessEnabled {
                Section {
                    Picker("Event Filter", selection: $eventFilter) {
                        ForEach(events) { event in
                            Text(event.name ?? "")
                                .tag(event as Event?)
                        }
                        
                        Text("All")
                            .tag(nil as Event?)
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                .listSectionSpacing(.compact)
            }
            #endif
            
            ForEach(recipients.sorted(by: recipientSortBy)) { recipient in
                #if os(watchOS)
                Section {
                    ForEach(filterAndSort(recipient.gifts ?? [])) { gift in
                        GiftRow(gift: gift, showStatus: true)
                    }

                    Button("New Gift", systemImage: "plus") {
                        newGiftSortOrder = (gifts.max(by: { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 })?.sortOrder ?? 0) + 1
                        newGiftRecipient = recipient
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
                    
                    Button("New Gift", systemImage: "plus") {
                        newGiftSortOrder = (gifts.max(by: { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 })?.sortOrder ?? 0) + 1
                        newGiftRecipient = recipient
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
                
                Button("New Gift", systemImage: "plus") {
                    newGiftSortOrder = (gifts.max(by: { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 })?.sortOrder ?? 0) + 1
                    showingNewGiftWithoutRecipient = true
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
            ToolbarItemGroup(placement: .secondaryAction) {
                Toggle("Require \(biometryType == .faceID ? "Face ID" : "Touch ID")", systemImage: biometryType == .faceID ? "faceid" : "touchid", isOn: $requireAuthenication)
                
                Section {
                    Button(includeGivenGifts ? "Hide Given Gifts" : "Show Given Gifts", systemImage: includeGivenGifts ? "eye.slash" : "eye") {
                        includeGivenGifts.toggle()
                    }
                    Picker("Recipient Info", systemImage: "person", selection: $recipientSummaryInfoValue) {
                        ForEach(RecipientSummaryInfo.allCases) { info in
                            Text(info.title)
                                .tag(info.rawValue)
                        }
                    }
                    Picker("Sort By", systemImage: "arrow.up.arrow.down", selection: $recipientSortBy) {
                        ForEach(RecipientSort.allCases) { sort in
                            Text(sort.title)
                                .tag(sort)
                        }
                    }
                }
                
                if !isAssistiveAccessEnabled {
                    Section {
                        Link(destination: URL(string: "https://www.256arts.com/")!) {
                            Label("Developer Website", systemImage: "safari")
                        }
                        Link(destination: URL(string: "https://www.256arts.com/joincommunity/")!) {
                            Label("Join Community", systemImage: "bubble.left.and.bubble.right")
                        }
                        Link(destination: URL(string: "https://github.com/256Arts/Holiday-Gifts-List")!) {
                            Label("Contribute on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                        }
                    }
                }
            }
            #endif
            
            #if os(watchOS)
            ToolbarItem(placement: .topBarLeading) {
                Button("Add Recipient", systemImage: "person.badge.plus") {
                    showingNewRecipient = true
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Button("Add Recipient", systemImage: "person.badge.plus") {
                    newRecipientSortOrder = (recipients.max(by: { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 })?.sortOrder ?? 0) + 1
                    showingNewRecipient = true
                }
                .popoverTip(AddRecipientTip())
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
