//
//  ConfirmationView.swift
//  
//
//  Created by Данис Тазетдинов on 18.02.2022.
//

import SwiftUI
import Localization

struct ConfirmationView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    let details: String?
    let imageName: String
    let imageColor: Color
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 40) {
                Spacer()
                Text(title)
                    .font(.title)
                
                Spacer()
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: proxy.size.width / 3)
                    .foregroundColor(imageColor)
                
                if let details = details {
                    Spacer()
                    Text(details)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text(L10n.Common.buttonDismiss.localized)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}
