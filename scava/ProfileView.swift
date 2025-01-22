//
//  ProfileView.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var showLoginForm = false
    @State private var showSignUpForm = false
    @State private var email = ""
    @State private var password = ""
    
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
                    .background(Color.white)
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if showLoginForm {
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.white)
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.white)
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    Button(action: {
                        // Handle login submission
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.red)
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
                    .background(Color.white)
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if showSignUpForm {
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.white)
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.white)
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    Button(action: {
                        // Handle sign up submission
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
        }
        .navigationTitle("Profile")
        .background(Color.red)
    }
}
