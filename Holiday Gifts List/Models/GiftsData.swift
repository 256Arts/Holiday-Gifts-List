//
//  GiftsData.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import Foundation

final class GiftsData: Codable, ObservableObject {
    
    static let newestFileVersion = 1

    let fileVersion: Int
    
    @Published var gifts: [Gift] {
        didSet {
            save()
        }
    }
    @Published var recipients: [Recipient] {
        didSet {
            save()
        }
    }
    
    var giftsWithoutRecipients: [Gift] {
        get {
            gifts.filter({ $0.recipientID == nil })
        }
        set {
            for updatedGift in newValue {
                if let index = gifts.firstIndex(where: { $0.id == updatedGift.id }) {
                    gifts[index] = updatedGift
                }
            }
        }
    }
    
    init(fileVersion: Int, gifts: [Gift], recipients: [Recipient]) {
        self.fileVersion = fileVersion
        self.gifts = gifts
        self.recipients = recipients
    }
    
    enum CodingKeys: String, CodingKey {
        case fileVersion, gifts, recipients
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fileVersion = try values.decode(Int.self, forKey: .fileVersion)
        gifts = try values.decode([Gift].self, forKey: .gifts)
        recipients = try values.decode([Recipient].self, forKey: .recipients)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileVersion, forKey: .fileVersion)
        try container.encode(gifts, forKey: .gifts)
        try container.encode(recipients, forKey: .recipients)
    }
    
    func save() {
        do {
            let encoded = try JSONEncoder().encode(self)
            try encoded.write(to: CloudController.shared.fileURL, options: .atomic)
        } catch {
            print("Failed to save")
        }
    }
    
}
