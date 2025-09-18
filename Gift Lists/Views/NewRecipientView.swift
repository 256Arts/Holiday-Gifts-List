//
//  NewRecipientView.swift
//  Holiday Gifts List
//
//  Created by 256 Arts Developer on 2023-07-24.
//

import Contacts
import SwiftUI
import SwiftData

struct NewRecipientView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    let sortOrder: Int
    
    @State var contact: CNContact?
    @State var name: String = ""
    @State var hasBirthday: Bool = false
    @State var birthday: Date = .now.addingTimeInterval(-30.0 * 365 * 24 * 60 * 60)
    @State var spendGoal: Double?
    
    var body: some View {
        Form {
            #if !os(watchOS) && !os(macOS)
            Section {
                ContactPickerButton(contact: $contact) {
                    Label("Autofill from Contact", systemImage: "person.crop.circle")
                        .fixedSize()
                }
                .fixedSize()
                .onChange(of: contact) { _, newValue in
                    if let newValue {
                        name = "\(newValue.givenName) \(newValue.familyName)"
                        if let birthdayComponents = newValue.birthday, let birthday = Calendar.autoupdatingCurrent.date(from: birthdayComponents) {
                            self.hasBirthday = true
                            self.birthday = birthday
                        }
                    }
                }
            }
            #endif
            
            TextField("Name", text: $name)
                #if os(iOS)
                .textInputAutocapitalization(.words)
                #endif
            
            #if !os(watchOS)
            LabeledContent("Birthday") {
                VStack(alignment: .trailing) {
                    Toggle("Birthday", isOn: $hasBirthday)
                    if hasBirthday {
                        DatePicker("Birthday", selection: $birthday, in: Date.distantPast...Date.now, displayedComponents: .date)
                    }
                }
                .labelsHidden()
            }
            #endif
        }
        #if !os(watchOS)
        .navigationTitle("New Recipient")
        #endif
        .toolbar {
            #if !os(watchOS)
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
            #endif
            ToolbarItem(placement: .confirmationAction) {
                Button("Add", systemImage: "checkmark") {
                    let recipient = Recipient(name: name, sortOrder: sortOrder, birthday: hasBirthday ? birthday : nil, spendGoal: spendGoal)
                    modelContext.insert(recipient)
                    dismiss()
                }
                .disabled(name == Recipient.userName)
            }
        }
    }
}

#Preview {
    NewRecipientView(sortOrder: 0)
        #if DEBUG
        .modelContainer(previewContainer)
        #endif
}
