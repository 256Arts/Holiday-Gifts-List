//
//  RootView.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI

struct RootView: View {
    
    @ObservedObject private var cloudController: CloudController = .shared
    
    var body: some View {
        if let giftsData = cloudController.giftsData {
            GiftsList()
                .environmentObject(giftsData)
        } else {
            ProgressView()
                .controlSize(.large)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
