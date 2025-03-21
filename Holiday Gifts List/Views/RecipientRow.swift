//
//  RecipientRow.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2025-03-20.
//

import SwiftUI

struct RecipientRow: View {
    
    let recipient: Recipient
    let sortingByBirthday: Bool
    let filteredGifts: [Gift]
    
    var spentTotal: Double {
        filteredGifts.filter({ $0.status != .idea && $0.status != .given }).reduce(0.0, { $0 + ($1.price ?? 0) })
    }
    
    @Environment(\.modelContext) private var modelContext
    
    @Binding var recipientName: String
    @Binding var editingRecipient: Recipient?
    
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundStyle(filteredGifts.isEmpty ? .secondary : .primary)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading) {
                Text(recipient.name ?? "")
                    .bold()
                    .foregroundStyle(filteredGifts.isEmpty ? .secondary : .primary)
                
                HStack {
                    if sortingByBirthday, let daysUntil = recipient.daysUntilBirthday {
                        ViewThatFits {
                            Text("\(daysUntil) days left")
                            Text("\(daysUntil) days")
                            Text("\(daysUntil)d")
                        }
                    }
                    
                    Text("\(currencyFormatter.string(from: NSNumber(value: spentTotal)) ?? "") spent")
                        .accessibilityLabel("Spent")
                        .accessibilityValue(currencyFormatter.string(from: NSNumber(value: spentTotal)) ?? "")
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
