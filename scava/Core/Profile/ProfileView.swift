//
//  ProfileView.swift
//  scava
//
//  Created by Odin Lindal on 4/26/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            if let user = authViewModel.currentUser {
                List {
                    Section {
                        HStack {
                            Text(user.initials)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.textOnPrimary)
                                .frame(width: 72, height: 72)
                                .background(Color(Theme.primaryDark))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullname)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                                    .foregroundColor(Theme.primaryDark)

                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundColor(Theme.primary)
                            }
                        }
                    }
                    .listRowBackground(Theme.primary.opacity(0.05))

                    Section("General") {
                        HStack {
                            SettingsRowView(imageName: "gear", title: "Version", tintColor: Theme.primary)
                            Spacer()
                            Text("ALPHA")
                                .font(.subheadline)
                                .foregroundColor(Theme.textPrimary)
                        }
                    }
                    .listRowBackground(Theme.primary.opacity(0.05))

                    Section("Account") {
                        Button {
                            showSignOutAlert = true
                        } label: {
                            SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: Theme.primary)
                        }

                        Button {
                            showDeleteAccountAlert = true
                        } label: {
                            SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: Theme.primary)
                        }
                    }
                    .listRowBackground(Theme.primary.opacity(0.05))
                }
                .scrollContentBackground(.hidden)
                .background(Theme.background)
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Theme.primary, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .alert("Sign Out?", isPresented: $showSignOutAlert) {
                                    Button("Cancel", role: .cancel) { }
                                    Button("Sign Out", role: .destructive) {
                                        authViewModel.signOut()
                                    }
                                } message: {
                                    Text("Are you sure you want to sign out?")
                                }
                .alert("Delete Account?", isPresented: $showDeleteAccountAlert) {
                                    Button("Cancel", role: .cancel) { }
                                    Button("Yes", role: .destructive) {
                                        Task {
                                            try await authViewModel.deleteAccount()
                                        }
                                    }
                                } message: {
                                    Text("Are you sure you want to delete your account?")
                                }
            } else {
                Text("No user logged in")
                    .foregroundColor(Theme.textSecondary)
                    .navigationTitle("Profile")
            }
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

/*#Preview {
    let mockUser = User(
        id: "123",
        email: "john.doe@example.com",
        fullname: "John Doe"
    )
    let authViewModel = AuthViewModel()
    authViewModel.currentUser = mockUser

    ProfileView()
        .environmentObject(authViewModel)
}
*/
