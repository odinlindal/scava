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
    
    init(showLoginForm: Bool = false, showSignUpForm: Bool = false) {
        _showLoginForm = State(initialValue: showLoginForm)
        _showSignUpForm = State(initialValue: showSignUpForm)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Button(action: {
                withAnimation {
                    showLoginForm.toggle()
                    if showLoginForm {
                        showSignUpForm = false
                    }
                }
            }) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.textOnPrimary)
                    .foregroundColor(Theme.primary)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if showLoginForm {
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(Theme.textOnPrimary)
                        .background(Theme.textOnPrimary)
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(Theme.textOnPrimary)
                        .background(Theme.textOnPrimary)
                        .cornerRadius(8)
                    
                    Button(action: {
                        // Handle login submission
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.textOnPrimary)
                            .foregroundColor(Theme.primary)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Button(action: {
                withAnimation {
                    showSignUpForm.toggle()
                    if showSignUpForm {
                        showLoginForm = false
                    }
                }
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.textOnPrimary)
                    .foregroundColor(Theme.primary)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if showSignUpForm {
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(Theme.textOnPrimary)
                        .background(Theme.textOnPrimary)
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(Theme.textOnPrimary)
                        .background(Theme.textOnPrimary)
                        .cornerRadius(8)
                    
                    Button(action: {
                        // Handle sign up submission
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.textOnPrimary)
                            .foregroundColor(Theme.primary)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
        }
        .navigationTitle("Profile")
        .background(Theme.primary)
    }
}

#Preview("Default") {
    NavigationView {
        ProfileView()
    }
}

#Preview("Login Form") {
    NavigationView {
        ProfileView(showLoginForm: true)
    }
}

#Preview("Sign Up Form") {
    NavigationView {
        ProfileView(showSignUpForm: true)
    }
}
