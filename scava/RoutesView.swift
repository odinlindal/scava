//
//  RoutesView.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//
import SwiftUI

struct RoutesView: View {
    @State private var showRouteDetail = false
    @State private var selectedRoute: Route?
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(gameViewModel.routes) { route in
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            if let imageURL = route.imageURL {
                                Image(imageURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 120)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                            
                            Text(route.name)
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("\(String(format: "%.1f", route.distance)) miles • \(route.difficulty)")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.caption)
                            
                            Button(action: {
                                print("🔍 Selected route: \(route.name)")
                                selectedRoute = route
                                print("📍 Selected route data: \(selectedRoute?.name ?? "none")")
                                DispatchQueue.main.async {
                                    showRouteDetail = true
                                }
                            }) {
                                Text("View Route")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .foregroundColor(.red)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                    .groupBoxStyle(RedGroupBoxStyle())
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await gameViewModel.fetchRoutes()
        }
        
        .navigationTitle("Routes")
        .background(Color.red)
        .fullScreenCover(isPresented: $showRouteDetail, onDismiss: {
            selectedRoute = nil
        }) {
            if let route = selectedRoute {
                NavigationView {
                    RouteDetailView(route: route, gameViewModel: gameViewModel)
                }
            } else {
                VStack {
                    Button("Go Back") {
                        showRouteDetail = false
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.red)
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
        .background(Color.red.opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
