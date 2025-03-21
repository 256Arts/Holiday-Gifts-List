//
//  Event.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2025-03-20.
//

import SwiftUI
import SwiftData

@Model
final class Event {
    
    var name: String?
    var date: Date?
    var gifts: [Gift]?
    
    @Transient
    var icon: Image? {
        switch name {
        case "Birthday":
            Image(systemName: "birthday.cake")
        case "Holidays":
            Image(systemName: "snowflake")
        default:
            nil
        }
    }
    
    init(name: String, date: Date?) {
        self.name = name
        self.date = date
        self.gifts = []
    }
    
}
