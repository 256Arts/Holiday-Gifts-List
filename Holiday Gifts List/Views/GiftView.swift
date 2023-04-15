//
//  GiftView.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2022-11-19.
//

import SwiftUI

struct GiftView: View {
    
    @EnvironmentObject var data: GiftsData
    
    @Binding var gift: Gift
    @State var titleCopy = ""
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $titleCopy)
                    #if os(iOS)
                    .textInputAutocapitalization(.words)
                    #endif
                    .privacySensitive()
                TextField("Price", value: $gift.price, formatter: currencyFormatter)
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
                    .privacySensitive()
                Toggle("Purchased", isOn: $gift.isPurchased)
                TextEditor(text: $gift.notes)
                    .overlay(alignment: .leading) {
                        if gift.notes.isEmpty {
                            Text("Notes")
                                .foregroundColor(.secondary)
                        }
                    }
            }
            Section {
                if let query = titleCopy.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    Link(destination: URL(string: "https://www.amazon.com/s?k=\(query)")!) {
                        Label("Search Amazon", systemImage: "magnifyingglass")
                    }
                }
            }
        }
        .navigationTitle("Gift")
        .onAppear {
            titleCopy = gift.title
        }
        .onDisappear {
            gift.title = titleCopy
        }
    }
}

struct GiftView_Previews: PreviewProvider {
    static var previews: some View {
        GiftView(gift: .constant(Gift(id: UUID(), title: "Title", price: 20, isPurchased: true)))
    }
}
