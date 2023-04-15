//
//  GiftRow.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI

struct GiftRow: View {
    
    @EnvironmentObject var giftsData: GiftsData
    
    @Binding var gift: Gift
    
    var body: some View {
        NavigationLink {
            GiftView(gift: $gift)
        } label: {
            HStack {
                Text(gift.title)
                    .privacySensitive()
                if gift.isPurchased {
                    Image(systemName: "checkmark.circle")
                        .symbolVariant(.fill)
                        .imageScale(.small)
                        .foregroundColor(.secondary)
                        .accessibilityRepresentation {
                            Text("Purchased")
                        }
                }
                Spacer()
                Text(currencyFormatter.string(from: NSNumber(value: gift.price)) ?? "")
                    .foregroundColor(.secondary)
                    .privacySensitive()
            }
        }
        .accessibilityRemoveTraits(.isSelected)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                if let index = giftsData.gifts.firstIndex(where: { $0.id == gift.id }) {
                    giftsData.gifts.remove(at: index)
                }
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}

struct GiftRow_Previews: PreviewProvider {
    static var previews: some View {
        GiftRow(gift: .constant(Gift(id: UUID(), title: "Title", price: 20, isPurchased: true)))
    }
}
