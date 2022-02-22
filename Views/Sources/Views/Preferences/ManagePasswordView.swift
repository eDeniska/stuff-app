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
    let title: String
    let message: String
    let completion: (() -> Void)?

    init(title: String, message: String, completion: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.completion = completion
    }
}

struct ManagePasswordView: View {
    
    @State private var existingPassword = ""
    @State private var password1 = ""
    @State private var password2 = ""

    @Environment(\.dismiss) private var dismissAction

    @State private var errorMessage: AlertMessage? = nil
    @State private var confirmationMessage: AlertMessage? = nil
    @State private var actionCompleted = false

    private let passwordIsSet: Bool

    @StateObject private var viewModel: ManagePasswordViewModel

    @FocusState private var focusedField: Field?

    init() {
        let vm = ManagePasswordViewModel()
        _viewModel = StateObject(wrappedValue: vm)
        passwordIsSet = vm.passwordIsSet()
    }

    private enum Field: Hashable {
        case existingPassword
        case password1
        case password2
    }

    private func clearPassword() {
        switch viewModel.clearPassword(existing: existingPassword) {
        case .success:
            actionCompleted = true
            confirmationMessage = AlertMessage(title: L10n.ManagePassword.PasswordRemoved.title.localized,
                                               message: L10n.ManagePassword.PasswordRemoved.message.localized) {
                dismissAction()
            }

        case .incorrectExisting:
            focusedField = .existingPassword
            errorMessage = AlertMessage(title: L10n.ManagePassword.IncorrectPassword.title.localized,
                                        message: L10n.ManagePassword.IncorrectPassword.message.localized)
        }

    }

    private func changePassword() {
        if passwordIsSet {
            let result = viewModel.changePassword(existing: existingPassword, password: password1, repeated: password2)
            switch result {
            case .success:
                actionCompleted = true
                confirmationMessage = AlertMessage(title: L10n.ManagePassword.PasswordChanged.title.localized,
                                                   message: L10n.ManagePassword.PasswordChanged.message.localized) {
                    dismissAction()
                }
            case .incorrectExisting:
                focusedField = .existingPassword
                errorMessage = AlertMessage(title: L10n.ManagePassword.IncorrectPassword.title.localized,
                                            message: L10n.ManagePassword.IncorrectPassword.message.localized)
            case .passwordsNotMatch:
                focusedField = .password1
                errorMessage = AlertMessage(title: L10n.ManagePassword.PasswordsDontMatch.title.localized,
                                            message: L10n.ManagePassword.PasswordsDontMatch.message.localized)
            case .emptyPassword:
                focusedField = .password1
                errorMessage = AlertMessage(title: L10n.ManagePassword.EmptyPassword.title.localized,
                                            message: L10n.ManagePassword.EmptyPassword.message.localized)
            }
        } else {
            let result = viewModel.setPassword(password: password1, repeated: password2)
            switch result {
            case .success:
                actionCompleted = true
                confirmationMessage = AlertMessage(title: L10n.ManagePassword.PasswordSet.title.localized,
                                                   message: L10n.ManagePassword.PasswordSet.message.localized) {
                    dismissAction()
                }
            case .passwordIsSet:
                errorMessage = AlertMessage(title: L10n.ManagePassword.InconsistencyError.title.localized,
                                            message: L10n.ManagePassword.InconsistencyError.message.localized)
            case .passwordsNotMatch:
                focusedField = .password1
                errorMessage = AlertMessage(title: L10n.ManagePassword.PasswordsDontMatch.title.localized,
                                            message: L10n.ManagePassword.PasswordsDontMatch.message.localized)
            case .emptyPassword:
                focusedField = .password1
                errorMessage = AlertMessage(title: L10n.ManagePassword.EmptyPassword.title.localized,
                                            message: L10n.ManagePassword.EmptyPassword.message.localized)
            }
        }
    }

    private func cancel() {
        dismissAction()
    }


    @ViewBuilder
    private func existingPasswordGroup(size: CGSize) -> some View {
        GroupBox {
            VStack(spacing: 20) {
                SecureField(L10n.ManagePassword.existingPasswordPlaceholder.localized,
                            text: $existingPassword)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .existingPassword)
                    .frame(width: size.width / 3, alignment: .center)
                    .onSubmit {
                        focusedField = .password1
                    }
                Button(role: .destructive, action: clearPassword) {
                    Text(L10n.ManagePassword.clearPasswordButton.localized)
                }
            }
            .padding()
        } label: {
            Text(L10n.ManagePassword.existingPasswordTitle.localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func newPasswordGroup(size: CGSize) -> some View {
        GroupBox {
            VStack(spacing: 20) {
                SecureField(L10n.ManagePassword.password1Placeholder.localized, text: $password1)
                    .textContentType(.newPassword)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .password1)
                    .frame(width: size.width / 3, alignment: .center)
                    .onSubmit {
                        focusedField = .password2
                    }
                SecureField(L10n.ManagePassword.password2Placeholder.localized, text: $password2)
                    .textContentType(.newPassword)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .password2)
                    .frame(width: size.width / 3, alignment: .center)
                    .onSubmit(changePassword)
                Button(action: changePassword) {
                    Text(passwordIsSet ? L10n.ManagePassword.changePasswordButton.localized : L10n.ManagePassword.newPasswordTitle.localized)
                }
            }
            .padding()
        } label: {
            Text(L10n.ManagePassword.newPasswordTitle.localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            HStack {
                Spacer()
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: actionCompleted ? "checkmark.circle" : "lock")
                        .font(.title)
                        .imageScale(.large)
                        .foregroundColor(.secondary)
                    Text(L10n.ManagePassword.title.localized)
                        .font(.title)
                        .foregroundColor(.secondary)
                    if passwordIsSet {
                        existingPasswordGroup(size: proxy.size)
                    }
                    newPasswordGroup(size: proxy.size)
                    Button(role: .cancel, action: cancel) {
                        Text(L10n.Common.buttonCancel.localized)
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                    Spacer()
                }
                .alert(confirmationMessage?.title ?? L10n.ManagePassword.genericSuccess.localized,
                       isPresented: Binding { confirmationMessage != nil } set: { if !$0 { confirmationMessage = nil } },
                       presenting: confirmationMessage) { message in
                    Button(role: .cancel) {
                        message.completion?()
                    } label: {
                        Text(L10n.Common.buttonDismiss.localized)
                    }
                } message: { message in
                    Text(message.message)
                }
                .alert(errorMessage?.title ?? L10n.ManagePassword.genericError.localized,
                       isPresented: Binding { errorMessage != nil } set: { if !$0 { errorMessage = nil } },
                       presenting: errorMessage) { message in
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
