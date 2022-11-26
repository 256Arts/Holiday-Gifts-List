//
//  Recipient.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import Foundation

struct Recipient: Codable, Identifiable {
    
    let id: UUID
    var name: String
    
    var priceTotal: Int {
        CloudController.shared.giftsData?.gifts.filter({ $0.recipientID == id }).reduce(0, { $0 + $1.price }) ?? 0
    }
    
}
