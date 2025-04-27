//
//  RegistrationView.swift
//  scava
//
//  Created by Odin Lindal on 4/26/25.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State var email = ""
    @State var password = ""
    @State var fullname = ""
    @State var confirmPassword = ""
    
    var body: some View {
        VStack() {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 120)
                .padding(.vertical, 32)
            
            VStack(spacing: 24) {
                InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                    .autocapitalization(.none)
                
                InputView(text: $fullname, title: "Full Name", placeholder: "Enter your name")
                
                InputView(text: $password, title: "Password", placeholder: "Enter password", isSecureField: true)
                
                InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm password", isSecureField: true)
                
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Button {
                print("Sign user up..")
            } label: {
                HStack {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(Theme.textPrimary)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Theme.textOnPrimary)
            .cornerRadius(8)
            .padding(.top, 24)
                        
            Button {
                dismiss()
            } label: {
                HStack(spacing: 5) {
                    Text("Already have an account?")
                    Text("Sign in")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
                .foregroundColor(Theme.textOnPrimary)
            }
            .padding(.top, 20)
            Spacer()
        }
        .background(Theme.primary)
    }
}

#Preview {
    RegistrationView()
}
