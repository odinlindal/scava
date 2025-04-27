//
//  scavaApp.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

@main
struct scavaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var gameViewModel = GameViewModel()
    @StateObject private var locationManager = LocationManager(gameViewModel: GameViewModel())
    @StateObject var authViewModel = AuthViewModel()
    @State private var isLoading = true
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if isLoading {
                ZStack {
                    Theme.background.ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.primary))
                        .scaleEffect(1.5)
                }
                .onAppear {
                    // Wait for initial routes to load
                    Task {
                        while gameViewModel.isLoading {
                            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                        }
                        locationManager.gameViewModel = gameViewModel
                        isLoading = false
                    }
                }
            } else {
                ContentView()
                    .environmentObject(gameViewModel)
                    .environmentObject(locationManager)
                    .environmentObject(authViewModel)
            }
        }
    }
}

