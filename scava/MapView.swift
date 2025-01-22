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
    @State private var showCompletionAlert = false
    
    private let routeLocation = CLLocationCoordinate2D(
        latitude: 47.3113,
        longitude: -122.1780
    )
    
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
                } else {
                    // Show preview circle
                    MapCircle(center: routeLocation, radius: 200)
                        .foregroundStyle(.red.opacity(0.2))
                        .stroke(.red, lineWidth: 2)
                        .mapOverlayLevel(level: .aboveRoads)
                }
                
                Annotation("", coordinate: routeLocation) {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 200, height: 200) // Made it bigger to match circle size
                        .contentShape(Circle())
                        .onTapGesture {
                            showRoutePreview = true
                        }
                }
                .annotationTitles(.hidden)
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
                    Text("Next: \(gameViewModel.currentLandmark?.name ?? "Finding next landmark...")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding()
                }
                
                Spacer()
                
                if showRoutePreview {
                    // Route Preview Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Green River College")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text("2.5 miles • Moderate")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showRouteDetail = true
                            showRoutePreview = false
                        }) {
                            Text("View Details")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding()
                }
                
                HStack {
                    if gameViewModel.isRouteActive {
                        Button(action: {
                            gameViewModel.stopRoute()
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
            RouteDetailView(gameViewModel: gameViewModel)
        }
        .alert("Route Completed!", isPresented: $showCompletionAlert) {
            Button("Finish") {
                gameViewModel.stopRoute()
            }
        } message: {
            Text("Congratulations! You've completed all landmarks on this route.")
        }
    }
}
