//
//  RoutesView.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//
import SwiftUI

struct RoutesView: View {
    let routesToShow: [Route]
    @Binding var selectedTab: Int
    @Binding var selectedRoute: Route?
    @Binding var showRouteDetail: Bool
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var locationManager: LocationManager
    @State private var isCreatingRoute = false
    
    private var isLoading: Bool { gameViewModel.isLoading }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                        .padding(.top, 200)
                }
                else if routesToShow.isEmpty {
                    Spacer()
                    Text("No routes available")
                        .font(.title2)
                        .foregroundColor(Theme.textPrimary)
                    Button("Refresh") {
                        Task { await gameViewModel.fetchRoutes() }
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(routesToShow) { route in
                                RouteCard(
                                    route: route,
                                    selectedRoute: $selectedRoute,
                                    showRouteDetail: $showRouteDetail
                                )
                            }
                        }
                        .padding()
                    }
                    .refreshable { await gameViewModel.fetchRoutes() }
                }
            }
            .fullScreenCover(isPresented: $isCreatingRoute) {
                RouteMetaDataScreen()
                    .environmentObject(gameViewModel)
                    .environmentObject(locationManager)
            }
        }
        .onAppear {
            if routesToShow.isEmpty {
                Task { await gameViewModel.fetchRoutes() }
            }
        }
    }
}

struct RedGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding(.top, 8)
        .background(Theme.primary.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.primary.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct RouteCard: View {
    let route: Route
    @Binding var selectedRoute: Route?
    @Binding var showRouteDetail: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private var ratingText: String {
        if route.totalRatings == 0 {
            return "No ratings yet"
        }
        return String(format: "%.1f ★ (%d)", route.averageRating, route.totalRatings)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageURL = route.imageURL {
                Image(imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Color.clear
                    .frame(height: 120)
            }
            
            Text(route.name)
                .font(.title2)
                .foregroundColor(Theme.textPrimary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(String(format: "%.1f", route.distance)) miles • \(route.difficulty)")
                    .foregroundColor(Theme.textSecondary)
                    .font(.caption)
                
                Text(ratingText)
                    .foregroundColor(Theme.textSecondary)
                    .font(.caption)
            }
            
            Button {
                selectedRoute = route
                showRouteDetail = true
            } label: {
                Text(authViewModel.currentUser?.id == route.makerID ? "View/Edit Route" : "View Route")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primary)
                    .foregroundColor(Theme.textOnPrimary)
                    .cornerRadius(8)
            }
            .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.primary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.primary.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct RoutesView_Previews: PreviewProvider {
    static var previews: some View {
        let gameVM = GameViewModel()
        let authVM = AuthViewModel()
        authVM.currentUser = User(
            id: "user123",
            fullname: "Jane Doe",
            email: "jane@example.com",
            devUser: true
        )
        let sampleRoute = Route(
            id: UUID(),
            name: "Sample Route",
            description: "A fun test route",
            difficulty: "Easy",
            distance: 2.5,
            estimatedTime: 50,
            landmarks: [],
            imageURL: "grcroute",
            makerID: "user123",
            totalRatings: 3,
            averageRating: 4.3
        )
        let routes = [sampleRoute]
        
        return RoutesView(
            routesToShow: routes,
            selectedTab: .constant(0),
            selectedRoute: .constant(nil),
            showRouteDetail: .constant(false)
        )
        .environmentObject(gameVM)
        .environmentObject(authVM)
    }
}
