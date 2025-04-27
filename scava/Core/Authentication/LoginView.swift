//
//  ProfileView.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var showLoginForm: Bool
    @State private var showSignUpForm: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var loginError: String?
    
    init(showLoginForm: Bool = false, showSignUpForm: Bool = false) {
        _showLoginForm = State(initialValue: showLoginForm)
        _showSignUpForm = State(initialValue: showSignUpForm)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Log In")
                .font(.largeTitle)
                .colorInvert()
                .bold()
                .padding(.bottom, 40)
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            if let msg = loginError {
                            Text(msg)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal)
                        }
            Button(action: attemptLogin) {
                            Text("Log In")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background((email.isEmpty || password.isEmpty) ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        // Disable until both fields have text
                        .disabled(email.isEmpty || password.isEmpty)

                        Spacer()
        }
        .padding(.top, 80)
        .background(Theme.primary)
    }
    private func attemptLogin() {
            // replace with your auth logic
            if email == "test@example.com" && password == "secret" {
                print("✅ Logged in!")
                loginError = nil
                // e.g. switch view, set a logged-in flag, etc.
            } else {
                loginError = "Invalid email or password"
            }
        }
}

#Preview("Default") {
    NavigationView {
        ProfileView()
    }
}
