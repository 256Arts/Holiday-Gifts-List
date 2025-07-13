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
    
    let showStatus: Bool
    
    var body: some View {
        NavigationLink(value: gift) {
            HStack {
                Text(gift.title ?? "")
                    .privacySensitive()
                
                Spacer()
                
                Text(currencyFormatter.string(from: NSNumber(value: gift.price ?? .nan)) ?? "")
                    .foregroundColor(.secondary)
                    .privacySensitive()
                
                if showStatus {
                    Group {
                        switch gift.status {
                        case .idea:
                            gift.status?.icon
                                .foregroundStyle(.secondary)
                                .accessibilityRepresentation {
                                    Text("Idea")
                                }
                        case .inTransit:
                            gift.status?.icon
                                .foregroundStyle(Color.red)
                                .accessibilityRepresentation {
                                    Text("In Transit")
                                }
                        case .acquired:
                            gift.status?.icon
                                .foregroundStyle(Color.yellow)
                                .accessibilityRepresentation {
                                    Text("Acquired")
                                }
                        case .wrapped:
                            gift.status?.icon
                                .foregroundStyle(Color.green)
                                .accessibilityRepresentation {
                                    Text("Wrapped")
                                }
                        case .given:
                            gift.status?.icon
                                .foregroundStyle(Color.purple)
                                .accessibilityRepresentation {
                                    Text("Given")
                                }
                        case nil:
                            Image(systemName: "questionmark.square.dashed")
                                .foregroundStyle(.secondary)
                                .accessibilityRepresentation {
                                    Text("Unknown Status")
                                }
                        }
                    }
                    .symbolVariant(.fill)
                    .imageScale(.small)
                    .frame(width: 20)
                }
            }
        }
        .accessibilityRemoveTraits(.isSelected)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Delete", systemImage: "trash", role: .destructive) {
                modelContext.delete(gift)
            }
        }
    }
}
