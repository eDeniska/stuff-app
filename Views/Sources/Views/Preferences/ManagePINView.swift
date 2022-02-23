//
//  ManagePINView.swift
//  
//
//  Created by Danis Tazetdinov on 22.02.2022.
//

import SwiftUI
import Localization
import LocalAuthentication
import ViewModels

struct ManagePINView<ViewModel: PINViewModelProtocol>: View {

    @Environment(\.dismiss) private var dismiss

    @State private var pin = ""

    @StateObject private var viewModel: ViewModel

    private let showsCancel: Bool
    private var biometryAuthentication: (() -> Void)?
    init(viewModel: ViewModel, showsCancel: Bool, biometryAuthentication: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.showsCancel = showsCancel
        self.biometryAuthentication = biometryAuthentication
    }

    private func height(for size: CGSize) -> CGFloat {
        if UIDevice.current.isPhone {
            return size.height
        } else {
            return max(size.width, size.height) / 2
        }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 40){
                Color.clear
                    .frame(idealHeight: 40, maxHeight: 40)
                PINKeypadView(pin: $pin, lockState: $viewModel.lockState, message: $viewModel.message, biometryType: viewModel.biometryType) { entered in
                    switch viewModel.enter(pin: entered) {
                    case .incorrect:
                        pin = ""
                        return false

                    case .success:
                        dismiss()
                        return true

                    case .next:
                        pin = ""
                        return true
                    }
                } biometryAction: {
                    biometryAuthentication?()
                }
                .frame(idealHeight: height(for: proxy.size), alignment: .bottom)
                if showsCancel {
                    Button {
                        dismiss()
                    } label: {
                        Text(L10n.Common.buttonCancel.localized)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                } else {
                    Color.clear
                        .frame(idealHeight: 40, maxHeight: 40)
                }
            }
        }
    }
}

