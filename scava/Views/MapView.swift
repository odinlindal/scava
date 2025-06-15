//
//  MapView.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//
import SwiftUI
import MapKit

struct MapView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var locationManager: LocationManager
    @State private var showRoutePreview = false
    @State private var showRouteDetail = false
    @State private var userAnswer = ""
    @State private var showStartRouteAlert = false
    @StateObject private var hapticManager = HapticManager.shared
    
    var body: some View {
        ZStack {
            // Base Map Layer
            Map(position: $locationManager.region, interactionModes: gameViewModel.isRouteActive ? [] : .all) {
                UserAnnotation()
                
                if gameViewModel.isRouteActive, let nextLandmark = gameViewModel.nextLandmark {
                    Marker(nextLandmark.name, coordinate: nextLandmark.coordinate)
                        .tint(Theme.primary)
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
            .toolbar(gameViewModel.isRouteActive ? .hidden : .visible, for: .navigationBar)
            
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
                                .foregroundColor(Theme.textOnPrimary)
                                .padding()
                                .background(Theme.primary)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $gameViewModel.showQuestion) {
            if let landmark = gameViewModel.currentLandmark {
                QuestionView(
                    landmark: landmark,
                    userAnswer: $userAnswer,
                    isPresented: $gameViewModel.showQuestion,
                    keyboardFocus: .constant(false),
                    onSubmit: { answer in
                        let isCorrect = gameViewModel.validateAnswer(answer)
                        if isCorrect {
                            gameViewModel.showQuestion = false
                            // Only clear the answer when the question is dismissed
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                userAnswer = ""
                            }
                        }
                    },
                    onGiveUp: {
                        gameViewModel.giveUpOnLandmark()
                        userAnswer = ""
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showRouteDetail) {
            if let route = gameViewModel.activeRoute {
                RouteDetailView(route: route, selectedTab: $selectedTab)
            }
        }
        .fullScreenCover(isPresented: $gameViewModel.showCompletionView) {
            if let route = gameViewModel.activeRoute,
               let elapsedTime = gameViewModel.elapsedTime {
                RouteCompletionView(
                    route: route,
                    elapsedTime: elapsedTime,
                    isPresented: $gameViewModel.showCompletionView
                )
                .environmentObject(gameViewModel)
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
        .interactiveDismissDisabled(true)
    }
    
    // Active Route UI Components
    private var activeRouteOverlay: some View {
        VStack {
            // Top landmark label and counter
            HStack {
                Text("Next: \(gameViewModel.nextLandmark?.name ?? "Finding next landmark...")")
                    .font(.headline)
                    .foregroundColor(Theme.textOnPrimary)
                    .padding()
                    .background(Theme.primary)
                    .cornerRadius(10)
                
                if let route = gameViewModel.activeRoute {
                    Text("\(gameViewModel.completedLandmarks.count)/\(route.landmarks.count)")
                        .font(.headline)
                        .foregroundColor(Theme.textOnPrimary)
                        .padding()
                        .background(Theme.primary)
                        .cornerRadius(10)
                }
            }
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
                            targetLocation: targetLocation
                        )
                        .frame(width: 120, height: 120)
                        .padding(.bottom, 30)
                    }
                    
                    // Bottom controls
                    if !gameViewModel.showQuestion {
                        HStack {
                            // Distance label
                            Text(String(format: "%.1fm", hapticManager.currentDistance))
                                .font(.subheadline)
                                .foregroundColor(Theme.textOnPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .background(Theme.primary)
                                .cornerRadius(10)
                            
                            Spacer()

                            Button(action: {
                                showStartRouteAlert = true
                            }) {
                                Text("End \nRoute")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textOnPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Theme.primary)
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
    // 1) Build your view model in a closure so it's all one expression
    let vm: GameViewModel = {
        let m = GameViewModel()
        m.isRouteActive = true
        m.activeRoute = Route(
            id: UUID(),
            name: "Test Route",
            description: "A test route…",
            difficulty: "Easy",
            distance: 1.0,
            estimatedTime: 30,
            landmarks: [
                Landmark(
                    id: UUID(),
                    name: "Test Landmark",
                    latitude: 47.3119,
                    longitude: -122.1785,
                    triggerRadius: 50,
                    question: "What is the capital of France?",
                    correctAnswer: "Paris"
                )
            ],
            imageURL: "grcroute",
            makerID: "1234"
        )
        m.currentLandmark = m.activeRoute?.landmarks[0]
        m.showQuestion = true
        return m
    }()

    // 2) A single view expression
    MapView(selectedTab: .constant(1))
        .environmentObject(vm)
        .environmentObject(LocationManager(gameViewModel: vm))
}
