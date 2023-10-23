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
    
    let nick = Recipient(name: "Nicholas")
    let noelle = Recipient(name: "Noelle")
    let chris = Recipient(name: "Chris")
    for recip in [nick, noelle, chris] {
        container.mainContext.insert(recip)
    }
    
    let gifts = [
        Gift(title: "Yoga Mat", price: 25, status: .wrapped, recipient: nick),
        Gift(title: "Blanket", price: 25, status: .acquired, recipient: nick),
        Gift(title: "Candle", price: 25, status: .idea, recipient: nick),
        Gift(title: "iPad", price: 500, status: .wrapped, recipient: noelle),
        Gift(title: "Frying Pans", price: 100, status: .inTransit, recipient: noelle),
        Gift(title: "Winter Sweater", price: 100, status: .idea, recipient: noelle),
        Gift(title: "LEGO Death Star", price: 900, status: .inTransit, recipient: chris),
        Gift(title: "Hot Chocolate", price: 20, status: .idea, recipient: chris)
    ]
    for gift in gifts {
        container.mainContext.insert(gift)
    }
    
    return container
}()
#endif
