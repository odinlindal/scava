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
    
    init(gameViewModel: GameViewModel) {
        _locationManager = StateObject(wrappedValue: LocationManager(gameViewModel: gameViewModel))
    }
    
    var body: some View {
        ZStack {
            Map(position: $locationManager.region, interactionModes: gameViewModel.isRouteActive ? [] : .all) {
                UserAnnotation()
                
                if gameViewModel.isRouteActive, let route = gameViewModel.activeRoute {
                    // Show route landmarks
                    ForEach(route.landmarks) { landmark in
                        let isCompleted = gameViewModel.completedLandmarks.contains(landmark.id)
                        Marker(landmark.name, coordinate: landmark.coordinate)
                            .tint(isCompleted ? .green : .red)
                    }
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
            
            VStack {
                if gameViewModel.isRouteActive {
                    // Next landmark label at top
                    Text("Next: \(gameViewModel.nextLandmark?.name ?? "Finding next landmark...")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding()
                }
                
                Spacer()
                
                HStack {
                    if gameViewModel.isRouteActive {
                        Button(action: {
                            showStartRouteAlert = true
                        }) {
                            Text("End Route")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    if !gameViewModel.isRouteActive {
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
                    }
                }
                .padding()
            }
            
            if gameViewModel.showQuestion {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                let _ = print("Showing question for: \(gameViewModel.currentLandmark?.name ?? "unknown")")
                
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
        .onChange(of: gameViewModel.isRouteActive) { _, isActive in
            if !isActive {
                showRouteDetail = false
            }
        }
    }
}
