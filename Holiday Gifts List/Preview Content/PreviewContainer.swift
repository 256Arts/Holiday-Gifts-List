//
//  PreviewContainer.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2023-10-22.
//

#if DEBUG
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Gift.self, configurations: config)
    
    let nick = Recipient(name: "Nicholas", sortOrder: 0)
    let noelle = Recipient(name: "Noelle", sortOrder: 1)
    let chris = Recipient(name: "Chris", sortOrder: 2)
    for recip in [nick, noelle, chris] {
        container.mainContext.insert(recip)
    }
    
    let gifts = [
        Gift(title: "Yoga Mat", sortOrder: 0, price: 25, status: .wrapped, recipient: nick),
        Gift(title: "Blanket", sortOrder: 1, price: 25, status: .acquired, recipient: nick),
        Gift(title: "Candle", sortOrder: 2, price: 25, status: .idea, recipient: nick),
        Gift(title: "iPad", sortOrder: 3, price: 500, status: .wrapped, recipient: noelle),
        Gift(title: "Frying Pans", sortOrder: 4, price: 100, status: .inTransit, recipient: noelle),
        Gift(title: "Winter Sweater", sortOrder: 5, price: 100, status: .idea, recipient: noelle),
        Gift(title: "LEGO Death Star", sortOrder: 6, price: 900, status: .inTransit, recipient: chris),
        Gift(title: "Hot Chocolate", sortOrder: 7, price: 20, status: .idea, recipient: chris)
    ]
    for gift in gifts {
        container.mainContext.insert(gift)
    }
    
    return container
}()
#endif
