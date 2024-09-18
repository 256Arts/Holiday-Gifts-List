//
//  GiftRow.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI

struct GiftRow: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var gift: Gift
    
    var body: some View {
        NavigationLink(value: gift) {
            HStack {
                Text(gift.title ?? "")
                    .privacySensitive()
                
                Spacer()
                
                Text(currencyFormatter.string(from: NSNumber(value: gift.price ?? .nan)) ?? "")
                    .foregroundColor(.secondary)
                    .privacySensitive()
                
                Group {
                    switch gift.status {
                    case .idea:
                        Image(systemName: "lightbulb")
                            .accessibilityRepresentation {
                                Text("Idea")
                            }
                    case .inTransit:
                        Image(systemName: "truck.box")
                            .accessibilityRepresentation {
                                Text("In Transit")
                            }
                    case .acquired:
                        Image(systemName: "house")
                            .accessibilityRepresentation {
                                Text("Acquired")
                            }
                    case .wrapped:
                        Image(systemName: "gift")
                            .accessibilityRepresentation {
                                Text("Wrapped")
                            }
                    case nil:
                        Image(systemName: "questionmark.square.dashed")
                            .accessibilityRepresentation {
                                Text("Unknown Status")
                            }
                    }
                }
                .symbolVariant(.fill)
                .imageScale(.small)
                .foregroundColor(.secondary)
                .frame(width: 20)
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
