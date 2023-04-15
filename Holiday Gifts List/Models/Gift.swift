//
//  Gift.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import Foundation

struct Gift: Codable, Identifiable {
    
    let id: UUID
    var title: String
    var recipientID: UUID?
    var price: Int
    var isPurchased: Bool
    var notes: String = ""
    
}
