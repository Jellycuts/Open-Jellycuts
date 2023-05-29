//
//  DictionaryAddValueSheet.swift
//  Jellycuts
//
//  Created by Taylor Lineman on 5/29/23.
//

import SwiftUI

struct DictionaryAddValueSheet: View, ErrorHandler {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var dictionaryHandler: DictionaryHandler
    @Binding var dictionary: DictionaryHandler.JellycutsDictionary
    
    @State internal var lastError: Error?
    @State internal var presentErrorView: Bool = false
    @State internal var shouldPresentView: Bool = true
    
    @State var key: String = ""
    @State var valueType: DictionaryHandler.JellycutsDictionary.Value.ValueType = .boolean
    @State var booleanValue: Bool = false
    @State var stringValue: String = ""
    @State var numberValue: Double = 0.0
    
    var body: some View {
        NavigationView {
            List {
                Section("General") {
                    ScrollView([.horizontal]) {
                        HStack {
                            ForEach(DictionaryHandler.JellycutsDictionary.Value.ValueType.allCases, id: \.rawValue) { valueType in
                                HStack {
                                    Image(systemName: valueType.imageName)
                                    Text(valueType.rawValue)
                                        .padding(5)
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                }
                                .padding(.horizontal, 5)
                                .background(Color(uiColor: self.valueType == valueType ? .systemGray3 : .systemGray5))
                                .cornerRadius(7)
                                .onTapGesture {
                                    self.valueType = valueType
                                }
                            }
                        }
                    }
                    TextField("Key", text: $key)
                }
                switch valueType {
                case .boolean:
                    Section("Value") {
                        Toggle("Value", isOn: $booleanValue)
                    }
                case .string:
                    Section("Value") {
                        TextEditor(text: $stringValue)
                    }
                case .number:
                    Section("Value") {
                        TextField("Enter a value", value: $numberValue, format: .number)
                    }
                default:
                    EmptyView()
                }
            }
            .navigationTitle("Add Value")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .cancel) {
                        save()
                    } label: {
                        Text("Save")
                    }
                }
            }
            .alert("An Error Occurred", isPresented: $presentErrorView) {
                errorMessageButtons()
            } message: {
                errorMessageContent()
            }
        }
    }
    
    private func save() {
        let value = DictionaryHandler.JellycutsDictionary.Value(type: valueType)
        switch valueType {
        case .boolean:
            value.boolean = booleanValue
        case .string:
            value.string = stringValue
        case .number:
            value.number = numberValue
        default:
            break
        }
        do {
            try dictionary.set(key: key, value: value)
            try dictionaryHandler.saveDictionaries()
            
            dismiss()
        } catch {
            handle(error: error)
        }
    }
}

struct DictionaryAddValueSheet_Previews: PreviewProvider {
    static var previews: some View {
        if let dictionary = DictionaryHandler().dictionaries.first {
            DictionaryAddValueSheet(dictionary: .constant(dictionary))
                .environmentObject(DictionaryHandler())
        } else {
            Text("No Dictionaries")
        }

    }
}
