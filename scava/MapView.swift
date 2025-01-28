//
//  MapView.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//
import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @StateObject private var locationManager: LocationManager
    @State private var showRoutePreview = false
    @State private var showRouteDetail = false
    @State private var userAnswer = ""
    @AppStorage("selectedTab") var selectedTab: Int = 0
    @State private var showStartRouteAlert = false
    @StateObject private var hapticManager = HapticManager.shared
    
    init(gameViewModel: GameViewModel) {
        _locationManager = StateObject(wrappedValue: LocationManager(gameViewModel: gameViewModel))
    }
    
    var body: some View {
        ZStack {
            // Base Map Layer
            Map(position: $locationManager.region, interactionModes: gameViewModel.isRouteActive ? [] : .all) {
                UserAnnotation()
                
                if gameViewModel.isRouteActive, let nextLandmark = gameViewModel.nextLandmark {
                    Marker(nextLandmark.name, coordinate: nextLandmark.coordinate)
                        .tint(.red)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                if !showRouteDetail {
                    showRoutePreview = false
                }
            }
            
            // Active Route UI
            if gameViewModel.isRouteActive {
                activeRouteOverlay
            } else {
                // Inactive Route UI (just the location button)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            locationManager.requestLocation()
                        }) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            
            // Question View Overlay
            if gameViewModel.showQuestion {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                if let landmark = gameViewModel.currentLandmark {
                    QuestionView(
                        landmark: landmark,
                        userAnswer: $userAnswer,
                        isPresented: $gameViewModel.showQuestion,
                        keyboardFocus: .constant(false)
                    ) { answer in
                        let isCorrect = gameViewModel.validateAnswer(answer)
                        if isCorrect {
                            gameViewModel.showQuestion = false
                            userAnswer = ""
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showRouteDetail) {
            if let route = gameViewModel.activeRoute {
                RouteDetailView(route: route, gameViewModel: gameViewModel)
            }
        }
        .alert("End Route?", isPresented: $showStartRouteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Route", role: .destructive) {
                withAnimation {
                    gameViewModel.stopRoute()
                    showRouteDetail = false
                }
            }
        } message: {
            Text("Are you sure you want to end this route?")
        }
        .alert("Route Completed!", isPresented: $gameViewModel.showCompletionAlert) {
            Button("Finish") {
                print("🏁 Finishing route")
                if gameViewModel.isRouteCompleted {
                    withAnimation {
                        gameViewModel.stopRoute()
                        showRouteDetail = false
                        selectedTab = 0
                    }
                }
            }
        } message: {
            Text("Congratulations! You've completed all landmarks on this route.")
        }
        .interactiveDismissDisabled(true)
    }
    
    // Active Route UI Components
    private var activeRouteOverlay: some View {
        VStack {
            // Top landmark label
            Text("Next: \(gameViewModel.nextLandmark?.name ?? "Finding next landmark...")")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
                .padding()
            
            Spacer()
            
            if let nextLandmark = gameViewModel.nextLandmark,
               let userLocation = locationManager.location {
                let targetLocation = CLLocation(
                    latitude: nextLandmark.latitude,
                    longitude: nextLandmark.longitude
                )
                
                let distance = userLocation.distance(from: targetLocation)
                
                // Arrow and bottom controls
                VStack {
                    let _ = hapticManager.startMonitoring(
                        for: distance,
                        triggerRadius: nextLandmark.triggerRadius,
                        isQuestionShowing: gameViewModel.showQuestion
                    )
                    
                    // Conditionally show the arrow based on the question state
                    if !gameViewModel.showQuestion {
                        DirectionalArrowView(
                            userLocation: userLocation,
                            targetLocation: targetLocation,
                            gameViewModel: gameViewModel
                        )
                        .frame(width: 120, height: 120)
                        .padding(.bottom, 30)
                    }
                    
                    // Bottom controls
                    if !gameViewModel.showQuestion{
                        HStack {
                            ZStack {
                                Text(String(format: "%.1fm", hapticManager.currentDistance))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 14)
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showStartRouteAlert = true
                            }) {
                                Text("End \nRoute")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
                .onDisappear {
                    hapticManager.stopPulse()
                }
            }
        }
    }
}

#Preview {
    MapView(gameViewModel: GameViewModel())
        .environmentObject(GameViewModel())
}

// Optional: Add a preview with an active route
#Preview("Active Route") {
    let viewModel = GameViewModel()
    viewModel.isRouteActive = true
    viewModel.activeRoute = Route(
        name: "Test Route",
        description: "A test route",
        distance: 1.0,
        estimatedTime: 30,
        landmarks: [
            Landmark(
                name: "Test Landmark",
                latitude: 47.3119,
                longitude: -122.1785,
                triggerRadius: 5,
                question: "Test Question?",
                correctAnswer: "Test"
            )
        ],
        latitude: 47.3119,
        longitude: -122.1785
    )
    
    return MapView(gameViewModel: viewModel)
        .environmentObject(viewModel)
}
