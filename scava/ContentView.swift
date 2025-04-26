//
//  ContentView.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var selectedTab = 0
    @State private var selectedRoute: Route?
    @State private var showRouteDetail = false
    
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
        navBarAppearance.backgroundColor = UIColor(Theme.primary)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                RoutesView(selectedTab: $selectedTab, selectedRoute: $selectedRoute, showRouteDetail: $showRouteDetail)
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
                .tabItem {
                    Label("Map", systemImage: "location")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
        }
        .accentColor(Theme.secondary)
        .onAppear {
            // optional fallback
            if UserDefaults.standard.bool(forKey: "activeRouteInProgress") {
                selectedTab = 1
            }
        }
        .onChange(of: gameViewModel.shouldResumeToMapTab) {
            if gameViewModel.shouldResumeToMapTab {
                selectedTab = 1
                gameViewModel.shouldResumeToMapTab = false
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
        .environmentObject(LocationManager(gameViewModel: GameViewModel()))
}
