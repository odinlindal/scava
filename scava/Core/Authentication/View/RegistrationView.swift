//
//  RegistrationView.swift
//  scava
//
//  Created by Odin Lindal on 4/26/25.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State var email = ""
    @State var password = ""
    @State var fullname = ""
    @State var confirmPassword = ""
    @State private var showAlert = false
    
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
                
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm password", isSecureField: true)
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textOnPrimary)
                        } else {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textOnPrimary)
                        }
                    }
                }
                
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            //SIGN UP BUTTON
            Button {
                Task {
                    await authViewModel.createUser(withEmail: email, password: password, fullname: fullname)
                    if authViewModel.errorMessage != nil {
                        showAlert = true
                    }
                }
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
            .disabled(!formIsVaild)
            .opacity(formIsVaild ? 1.0 : 0.5)
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
        .alert("Sign-Up Failed",
                   isPresented: $showAlert,
                   presenting: authViewModel.errorMessage) { message in
              Button("OK", role: .cancel) {
                // clear it out
                authViewModel.errorMessage = nil
              }
            } message: { message in
              Text(message)
            }
    }
}

//Check if fields are populated
extension RegistrationView: AuthenticationFormProtocol {
    var formIsVaild: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullname.isEmpty
    }
}

#Preview {
    RegistrationView()
}
