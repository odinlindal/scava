//
//  InputView.swift
//  scava
//
//  Created by Odin Lindal on 4/26/25.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundColor(Theme.textOnPrimary)
                .fontWeight(.semibold)
                .font(.footnote)
            if isSecureField {
                SecureField(
                    "", 
                    text: $text,
                    prompt: Text(placeholder)
                        .foregroundColor(Theme.textOnPrimary.opacity(0.5))
                        .font(.system(size: 14))
                )
                .font(.system(size: 14))
                .foregroundColor(Theme.textOnPrimary)
            } else {
                TextField(
                    "", 
                    text: $text,
                    prompt: Text(placeholder)
                        .foregroundColor(Theme.textOnPrimary.opacity(0.5))
                        .font(.system(size: 14))
                )
                .font(.system(size: 14))
                .foregroundColor(Theme.textOnPrimary)
            }
            Divider()
                .background(Theme.textOnPrimary)
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "email", placeholder: "1@2.com", isSecureField: false)
}
