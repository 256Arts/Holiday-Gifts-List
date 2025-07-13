//
//  MyWishlistView.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2024-12-04.
//

import SwiftUI
import SwiftData

struct MyWishlistView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Recipient> { $0.name == "<Me>" }) var mes: [Recipient]
    @Query var gifts: [Gift]
    
    @State var showingNewGift = false
    @State var newGiftSortOrder = 0
    
    var me: Recipient? {
        mes.first
    }
    
    var body: some View {
        List {
            ForEach(me?.gifts?.sorted() ?? []) { gift in
                GiftRow(gift: gift, showStatus: false)
            }
            
            Button("New Gift", systemImage: "plus") {
                if me == nil {
                    modelContext.insert(Recipient(name: Recipient.userName, sortOrder: -1))
                }
                newGiftSortOrder = (gifts.max(by: { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 })?.sortOrder ?? 0) + 1
                showingNewGift = true
            }
            #if os(watchOS)
            .foregroundColor(.accentColor)
            #endif
        }
        .headerProminence(.increased)
        #if !targetEnvironment(macCatalyst)
        .navigationTitle("My Wishlist")
        #endif
        .navigationDestination(for: Gift.self) { gift in
            GiftView(gift: gift)
        }
        .sheet(isPresented: $showingNewGift) {
            NavigationStack {
                NewGiftView(recipient: me, sortOrder: newGiftSortOrder)
            }
        }
    }
}
