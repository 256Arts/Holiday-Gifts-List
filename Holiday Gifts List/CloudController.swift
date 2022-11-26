//
//  CloudController.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import Foundation

final class CloudController: ObservableObject {
    
    enum FetchError: Error {
        case noObjectForKey
    }
    
    static let shared = CloudController()
    
    let metadataQuery = NSMetadataQuery()

    @Published var giftsData: GiftsData?
    
    init() {
        metadataQuery.notificationBatchingInterval = 1
        metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        metadataQuery.predicate = NSPredicate(format: "%K LIKE 'Gifts Data.json'", NSMetadataItemFSNameKey)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(metadataQueryDidFinishGathering),
            name: Notification.Name.NSMetadataQueryDidFinishGathering,
            object: metadataQuery)
        metadataQuery.start()
    }

    @objc func metadataQueryDidFinishGathering(_ notification: Notification) {
        metadataQuery.disableUpdates()
        if metadataQuery.results.isEmpty {
            print("No cloud files found. Creating new file.")
            giftsData = GiftsData(fileVersion: GiftsData.newestFileVersion, gifts: [], recipients: [])
        } else {
            do {
                giftsData = try fetchGiftsData()
            } catch {
                print("Failed to fetch data after query gather")
            }
        }
        metadataQuery.enableUpdates()
    }
    
    func fetchGiftsData() throws -> GiftsData? {
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: fileURL)
            do {
                let attributes = try fileURL.resourceValues(forKeys: [URLResourceKey.ubiquitousItemDownloadingStatusKey])
                if let status: URLUbiquitousItemDownloadingStatus = attributes.allValues[URLResourceKey.ubiquitousItemDownloadingStatusKey] as? URLUbiquitousItemDownloadingStatus {
                    switch status {
                    case .current, .downloaded:
                        let savedData = try Data(contentsOf: fileURL)
                        return try loadFinancialData(data: savedData)
                    default:
                        // Download again
                        return try fetchGiftsData()
                    }
                }
            } catch {
                print(error)
            }

            let savedData = try Data(contentsOf: fileURL)
            return try loadFinancialData(data: savedData)
        } catch {
            print(error)
            
            guard let savedData = NSUbiquitousKeyValueStore.default.object(forKey: UserDefaults.Key.giftsData) as? Data else {
                throw FetchError.noObjectForKey
            }
            // Remove old data
            NSUbiquitousKeyValueStore.default.removeObject(forKey: UserDefaults.Key.giftsData)
            return try loadFinancialData(data: savedData)
        }
    }

    func loadFinancialData(data: Data) throws -> GiftsData {
        // Upgrade data here if needed
        return try JSONDecoder().decode(GiftsData.self, from: data)
    }
    
}
