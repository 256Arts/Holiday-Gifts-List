//
//  Gift.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2023-06-09.
//

import Foundation
import SwiftData

enum Status: String, Codable {
    case idea, inTransit, acquired, wrapped
    
    var sortPriority: Int {
        switch self {
        case .idea:
            4
        case .inTransit:
            3
        case .acquired:
            2
        case .wrapped:
            1
        }
    }
}

@Model
final class Gift {
    
    var title: String? //= ""
    var price: Double? //= 0.0
    var notes: String?
    var recipient: Recipient?
    var status: Status? //= .idea
    
    var amazonURL: URL? {
        guard let query = title?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        
        let domain = switch Locale.autoupdatingCurrent.region?.identifier {
        case "CA": "ca"
        default: "com"
        }
        return URL(string: "https://www.amazon.\(domain)/s?k=\(query)")!
    }
    
    init(title: String, price: Double, notes: String? = nil, status: Status = .idea, recipient: Recipient? = nil) {
        self.title = title
        self.price = price
        self.notes = notes
        self.status = status
        self.recipient = recipient
    }
    
}

extension [Gift] {
    func sorted() -> [Gift] {
        sorted(by: {
            let statusSortPriority0 = ($0.status ?? .idea).sortPriority
            let statusSortPriority1 = ($1.status ?? .idea).sortPriority
            
            if statusSortPriority0 == statusSortPriority1 {
                if (($0.price ?? 0) == ($1.price ?? 0)) {
                    return $0.title?.localizedCaseInsensitiveCompare($1.title ?? "") == .orderedAscending
                } else {
                    return (($0.price ?? 0) > ($1.price ?? 0))
                }
            } else {
                return statusSortPriority0 < statusSortPriority1
            }
        })
    }
}
