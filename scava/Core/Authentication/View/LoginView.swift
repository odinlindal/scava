//
//  ProfileView.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            VStack() {
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 120)
                    .padding(.vertical, 32)
                
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                        .autocapitalization(.none)
                    
                    InputView(text: $password, title: "Password", placeholder: "Enter password", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                //SIGN IN BUTTON
                Button {
                    Task{
                        await authViewModel.signIn(withEmail: email, password: password)
                        if authViewModel.errorMessage != nil {
                            showAlert = true
                        }
                    }
                } label: {
                    HStack {
                        Text("Sign In")
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
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 5) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textOnPrimary)
                }
                .padding(.top, 20)
                Spacer()
                
            }
            .background(Theme.primary)
            .alert("Login Failed",
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
}

//Check if fields are populated
extension LoginView: AuthenticationFormProtocol {
    var formIsVaild: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview("Default") {
    NavigationView {
        LoginView()
    }
}
