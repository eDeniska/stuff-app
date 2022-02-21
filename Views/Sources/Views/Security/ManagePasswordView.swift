//
//  ManagePasswordView.swift
//  
//
//  Created by Данис Тазетдинов on 21.02.2022.
//

import SwiftUI

struct ManagePasswordView: View {
    
    @State private var hasExistingPassword = true
    @State private var existingPassword = ""
    @State private var password1 = ""
    @State private var password2 = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case existingPassword
        case password1
        case password2
    }

    var body: some View {
        GeometryReader { proxy in
            HStack {
                Spacer()
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "lock")
                        .font(.title)
                        .imageScale(.large)
                        .foregroundColor(.secondary)
                    Text("viewModel.message")
                        .font(.title)
                        .foregroundColor(.secondary)
                    if hasExistingPassword {
                        SecureField("Existing password", text: $existingPassword)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .existingPassword)
                            .padding()
                            .frame(width: proxy.size.width / 3, alignment: .center)
                            .onSubmit {
                                focusedField = .password1
                            }
                    }
                    SecureField("New password", text: $password1)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .password1)
                        .padding()
                        .frame(width: proxy.size.width / 3, alignment: .center)
                        .onSubmit {
                            focusedField = .password2
                        }
                    SecureField("Repeat password", text: $password2)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .password2)
                        .padding()
                        .frame(width: proxy.size.width / 3, alignment: .center)
                        .onSubmit {
                        }
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
