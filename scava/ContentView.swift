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
    @StateObject private var gameViewModel = GameViewModel()
    @AppStorage("selectedTab") var selectedTab: Int = 0
    
    init() {
        // Set the tab bar to be red with white icons
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .red
        
        // Set unselected items to white with 60% opacity
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .white.withAlphaComponent(0.6)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        
        // Set selected items to pure white
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .white
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Set the navigation bar to be red with white text
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .red
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = .white
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                RoutesView()
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color.red)
            }
            .tabItem {
                Label("Routes", systemImage: "map.fill")
            }
            .tag(0)
            
            MapView(gameViewModel: gameViewModel)
                .tabItem {
                    Label("Map", systemImage: "location.fill")
                }
                .tag(1)
            
            NavigationStack {
                ProfileView()
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color.red)
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(2)
        }
        .tint(.white)
        .environmentObject(gameViewModel)
    }
}

#Preview {
    ContentView()
}
