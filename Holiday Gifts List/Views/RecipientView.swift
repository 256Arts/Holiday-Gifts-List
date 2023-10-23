//
//  RecipientView.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2023-07-24.
//

import SwiftUI

struct RecipientView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var recipient: Recipient
    
    @State var name: String
    @State var hasBirthday: Bool
    @State var birthday: Date
    @State var spendGoal: Double?
    
    init(recipient: Recipient) {
        self.recipient = recipient
        self._name = State(initialValue: recipient.name ?? "")
        self._hasBirthday = State(initialValue: recipient.birthday != nil)
        self._birthday = State(initialValue: recipient.birthday ?? .now.addingTimeInterval(-30 * 365 * 24 * 60 * 60))
        self._spendGoal = State(initialValue: recipient.spendGoal)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name, onCommit: {
                    recipient.name = name
                })
                #if os(iOS)
                .textInputAutocapitalization(.words)
                #endif
                
                LabeledContent("Birthday") {
                    VStack(alignment: .trailing) {
                        Toggle("Birthday", isOn: $hasBirthday)
                        if hasBirthday {
                            DatePicker("Birthday", selection: $birthday, in: Date.distantPast...Date.now, displayedComponents: .date)
                        }
                    }
                    .labelsHidden()
                }
            }
            
            Section {
                LabeledContent("Spent") {
                    Text(currencyFormatter.string(from: NSNumber(value: recipient.spentTotal)) ?? "")
                }
            }
        }
        .navigationTitle("Recipient")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    dismiss()
                }
            }
        }
        .onChange(of: birthday) { _, newValue in
            if hasBirthday {
                recipient.birthday = newValue
            } else {
                recipient.birthday = nil
            }
        }
    }
}
