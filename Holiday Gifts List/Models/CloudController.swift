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
    
    let filename = "Gifts Data.json"
    var fileURL: URL {
        let directoryURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directoryURL.appending(path: filename, directoryHint: .notDirectory)
    }
    
    let finishGatheringQuery = NSMetadataQuery()
    let updateQuery = NSMetadataQuery()

    @Published var giftsData: GiftsData?
    
    init() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(queryDidFinishGathering),
            name: Notification.Name.NSMetadataQueryDidFinishGathering,
            object: finishGatheringQuery)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryDidUpdate),
            name: NSNotification.Name.NSMetadataQueryDidUpdate,
            object: updateQuery)
        
        finishGatheringQuery.notificationBatchingInterval = 1
        finishGatheringQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        finishGatheringQuery.predicate = NSPredicate(format: "%K LIKE '\(filename)'", NSMetadataItemFSNameKey)
        finishGatheringQuery.start()
        
        updateQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        updateQuery.valueListAttributes = [NSMetadataUbiquitousItemPercentDownloadedKey, NSMetadataUbiquitousItemDownloadingStatusKey]
        updateQuery.predicate = NSPredicate(format: "%K LIKE '\(filename)'", NSMetadataItemFSNameKey)
        updateQuery.start()
    }

    @objc func queryDidFinishGathering(_ notification: Notification) {
        finishGatheringQuery.disableUpdates()
        Task { @MainActor in
            if finishGatheringQuery.results.isEmpty {
                print("No cloud files found. Creating new file.")
                giftsData = GiftsData(fileVersion: GiftsData.newestFileVersion, gifts: [], recipients: [])
            } else {
                do {
                    giftsData = try await fetchGiftsData()
                } catch {
                    print("Failed to fetch data after query gather")
                }
            }
            finishGatheringQuery.enableUpdates()
        }
    }
    
    @objc func queryDidUpdate(_ notification: Notification) {
        updateQuery.disableUpdates()
        Task { @MainActor in
            if updateQuery.results.isEmpty {
                print("No cloud files found. Creating new file.")
                giftsData = GiftsData(fileVersion: GiftsData.newestFileVersion, gifts: [], recipients: [])
            } else {
                do {
                    giftsData = try await fetchGiftsData()
                } catch {
                    print("Failed to fetch data after query gather")
                }
            }
            updateQuery.enableUpdates()
        }
    }
    
    func fetchGiftsData() async throws -> GiftsData? {
        try FileManager.default.startDownloadingUbiquitousItem(at: fileURL)
        let attributes = try fileURL.resourceValues(forKeys: [URLResourceKey.ubiquitousItemDownloadingStatusKey])
        if let status: URLUbiquitousItemDownloadingStatus = attributes.allValues[URLResourceKey.ubiquitousItemDownloadingStatusKey] as? URLUbiquitousItemDownloadingStatus {
            switch status {
            case .current, .downloaded:
                let savedData = try Data(contentsOf: fileURL)
                return try loadGiftsData(data: savedData)
            default:
                #if os(macOS)
                return nil // Bug workaround
                #else
                // Download again
                try await Task.sleep(for: .seconds(0.1))
                return try await fetchGiftsData()
                #endif
            }
        }

        let savedData = try Data(contentsOf: fileURL)
        return try loadGiftsData(data: savedData)
    }

    func loadGiftsData(data: Data) throws -> GiftsData {
        // Upgrade data here if needed
        return try JSONDecoder().decode(GiftsData.self, from: data)
    }
    
}
