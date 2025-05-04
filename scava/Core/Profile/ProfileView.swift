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
    @State private var isCreatingRoute = false
    @Binding var selectedTab: Int
    @Binding var selectedRoute: Route?
    @Binding var showRouteDetail: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var locationManager: LocationManager

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

                    ColoredSectionListView("General") {
                        HStack {
                            SettingsRowView(imageName: "gear", title: "Version")
                            Spacer()
                            Text("ALPHA")
                                .font(.subheadline)
                                .foregroundColor(Theme.textPrimary)
                        }
                        if(user.devUser) {
                            Button {
                                isCreatingRoute = true
                            } label: {
                                SettingsRowView(
                                    imageName: "arrow.right.circle.fill",
                                    title: "Make Route"
                                )
                            }
                        }
                        NavigationLink {
                            // Before the list appears, fetch them
                            RoutesView(
                              routesToShow: gameViewModel.myRoutes,
                              selectedTab: $selectedTab,
                              selectedRoute: $selectedRoute,
                              showRouteDetail: $showRouteDetail
                            )
                            .environmentObject(gameViewModel)
                            .task {
                              await gameViewModel.fetchMyRoutes()
                            }
                          } label: {
                            SettingsRowView(
                              imageName: "list.bullet",
                              title: "My Routes"
                            )
                          }
                    }

                    ColoredSectionListView("Account") {
                        Button {
                            showSignOutAlert = true
                        } label: {
                            SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out")
                        }

                        Button {
                            showDeleteAccountAlert = true
                        } label: {
                            SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account")
                        }
                    }
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
        .sheet(isPresented: $isCreatingRoute) {
                RouteMetaDataScreen()
                .environmentObject(gameViewModel)
                .environmentObject(locationManager)
            }
    }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    let mockUser = User(
      id: "123",
      fullname: "John Doe",
      email: "john.doe@example.com",
      devUser: true
    )
    let authVM = AuthViewModel()
    authVM.currentUser = mockUser
    let gameVM = GameViewModel()
    let locMgr = LocationManager(gameViewModel: gameVM)

    return ProfileView(
      selectedTab: .constant(0),
      selectedRoute: .constant(nil),
      showRouteDetail: .constant(false)
    )
    .environmentObject(authVM)
    .environmentObject(gameVM)
    .environmentObject(locMgr)
  }
}
