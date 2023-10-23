//
//  ShoppingRow.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2023-10-22.
//

import SwiftUI

struct ShoppingRow: View {
    
    @AppStorage(UserDefaults.Key.showBirthdays) private var showBirthdays = true
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var gift: Gift
    
    var body: some View {
        NavigationLink(value: gift) {
            HStack {
                VStack(alignment: .leading) {
                    Text(gift.title ?? "")
                        .privacySensitive()
                    
                    if let recipient = gift.recipient {
                        HStack(spacing: 4) {
                            if let name = recipient.name {
                                Text("For \(name)")
                            }
                            if showBirthdays, let daysUntilBirthday = recipient.daysUntilBirthday {
                                Text("in \(daysUntilBirthday) days")
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let url = gift.amazonURL {
                    Link(destination: url) {
                        Image(systemName: "magnifyingglass")
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .accessibilityRemoveTraits(.isSelected)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                modelContext.delete(gift)
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}
