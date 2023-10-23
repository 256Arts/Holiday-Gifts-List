//
//  Recipient.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import Foundation
import SwiftData

@Model
final class Recipient {
    
    var name: String? //= ""
    var birthday: Date?
    var spendGoal: Double?
    var gifts: [Gift]? //= []
    
    @Transient
    var spentTotal: Double {
        (gifts ?? []).filter({ $0.status != .idea }).reduce(0.0, { $0 + ($1.price ?? 0) })
    }
    
    @Transient
    var nextBirthday: Date? {
        guard let birthday else { return nil }
        
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.month, .day], from: birthday)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: .now) ?? .now
        return calendar.nextDate(after: yesterday, matching: components, matchingPolicy: .nextTime)
    }
    
    @Transient
    var daysUntilBirthday: Int? {
        if let nextBirthday {
            let calendar = Calendar.autoupdatingCurrent
            return calendar.dateComponents([.day], from: calendar.startOfDay(for: .now), to: nextBirthday).day
        } else {
            return nil
        }
    }
    
    init(name: String, birthday: Date? = nil, spendGoal: Double? = nil) {
        self.name = name
        self.birthday = birthday
        self.spendGoal = spendGoal
        self.gifts = []
    }
    
}

extension [Recipient] {
    func sorted() -> [Recipient] {
        sorted(by: {
            if $0.daysUntilBirthday == $1.daysUntilBirthday {
                return $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending
            } else {
                return $0.daysUntilBirthday ?? Int.max < $1.daysUntilBirthday ?? Int.max
            }
        })
    }
}
