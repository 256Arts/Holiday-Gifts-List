//
//  ShoppingList.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2023-10-22.
//

import SwiftUI
import SwiftData

struct ShoppingList: View {
    
    @Query private var gifts: [Gift]
    
    private var giftIdeas: [Gift] {
        gifts.filter({ $0.status == .idea }).sorted()
    }
    
    var body: some View {
        List(giftIdeas.sorted()) { gift in
            ShoppingRow(gift: gift)
        }
        .navigationTitle("Shopping List")
        .navigationDestination(for: Gift.self) { gift in
            GiftView(gift: gift)
        }
    }
}

#Preview {
    ShoppingList()
        #if DEBUG
        .modelContainer(previewContainer)
        #endif
}
