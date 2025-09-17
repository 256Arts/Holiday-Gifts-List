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
    
    enum SpecialCase: String, Codable {
        case birthday, holidays
    }
    
    var name: String?
    var date: Date?
    var specialCase: SpecialCase?
    var gifts: [Gift]?
    
    @Transient
    var icon: Image? {
        switch specialCase {
        case .birthday:
            Image(systemName: "birthday.cake")
        case .holidays:
            Image(systemName: "snowflake")
        default:
            nil
        }
    }
    
    init(name: String, date: Date?, specialCase: SpecialCase? = nil) {
        self.name = name
        self.date = date
        self.specialCase = specialCase
        self.gifts = []
    }
    
}
