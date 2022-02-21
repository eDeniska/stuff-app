//
//  ManagePasswordView.swift
//  
//
//  Created by Данис Тазетдинов on 21.02.2022.
//

import SwiftUI
import ViewModels
import Localization

struct AlertMessage {
    let message: String
    let completion: (() -> Void)?
}

struct ManagePasswordView: View {
    
    @State private var existingPassword = ""
    @State private var password1 = ""
    @State private var password2 = ""

    @State private var alertMessage: AlertMessage? = nil

    @StateObject private var viewModel = ManagePasswordViewModel()

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
                    if viewModel.passwordIsSet() {
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
                            if viewModel.passwordIsSet() {
                                let result = viewModel.changePassword(existing: existingPassword, password: password1, repeated: password2)
                                switch result {
                                case .success:
                                    break
                                case .incorrectExisting:
                                    break
                                case .passwordsNotMatch:
                                    alertMessage = AlertMessage(message: "Passwords don't match") {
                                        focusedField = .password1
                                    }
                                }
                            } else {
                                let result = viewModel.setPassword(password: password1, repeated: password2)
                                switch result {
                                case .success:
                                    break
                                case .passwordIsSet:
                                    break
                                case .passwordsNotMatch:
                                    alertMessage = AlertMessage(message: "Passwords don't match") {
                                        focusedField = .password1
                                    }
                                }
                            }
                        }
                    Spacer()
                }
                .alert("Password error",
                       isPresented: Binding { alertMessage != nil } set: { if !$0 { alertMessage = nil } },
                       presenting: alertMessage) { message in
                    Button(role: .cancel) {
                        message.completion?()
                    } label: {
                        Text(L10n.Common.buttonDismiss.localized)
                    }
                } message: { message in
                    Text(message.message)
                }

                Spacer()
            }
        }
    }
}
