import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedTab = 0
    @State private var selectedRoute: Route?
    @State private var showRouteDetail = false
    @State private var isCreatingRoute = false
    
    init() {
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Theme.primary)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        // Configure navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(Theme.primaryDark)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }

    var body: some View {
        Group {
            if gameViewModel.isRouteActive {
                // When route is active, only show the MapView
                MapView(selectedTab: $selectedTab)
                    .environmentObject(gameViewModel)
                    .environmentObject(locationManager)
            } else {
                // When no route is active, show the full TabView
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        RoutesView(
                            routesToShow: gameViewModel.routes,
                            selectedTab: $selectedTab,
                            selectedRoute: $selectedRoute,
                            showRouteDetail: $showRouteDetail
                        )
                        .environmentObject(gameViewModel)
                        .sheet(isPresented: $showRouteDetail) {
                            if let route = selectedRoute {
                                RouteDetailView(route: route, selectedTab: $selectedTab)
                            }
                        }
                    }
                    .tabItem {
                        Label("Routes", systemImage: "map")
                    }
                    .tag(0)

                    MapView(selectedTab: $selectedTab)
                        .environmentObject(gameViewModel)
                        .environmentObject(locationManager)
                        .tabItem {
                            Label("Map", systemImage: "location")
                        }
                        .tag(1)

                    Group {
                        if authViewModel.userSession != nil && authViewModel.currentUser != nil {
                            ProfileView(
                                selectedTab: $selectedTab,
                                selectedRoute: $selectedRoute,
                                showRouteDetail: $showRouteDetail
                            )
                            .environmentObject(authViewModel)
                            .environmentObject(gameViewModel)
                            .environmentObject(locationManager)
                        } else {
                            LoginView()
                                .environmentObject(authViewModel)
                        }
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(2)
                }
                .accentColor(Theme.secondary)
            }
        }
        .onAppear {
            // optional fallback
            if UserDefaults.standard.bool(forKey: "activeRouteInProgress") {
                selectedTab = 1
            }
        }
        .onChange(of: gameViewModel.shouldResumeToMapTab) { newValue in
            if newValue {
                selectedTab = 1
                gameViewModel.shouldResumeToMapTab = false
            }
        }
    }
}

#Preview {
    let gameVM = GameViewModel()
    let authVM = AuthViewModel()
    let locManager = LocationManager(gameViewModel: gameVM)
    return ContentView()
        .environmentObject(gameVM)
        .environmentObject(authVM)
        .environmentObject(locManager)
}
