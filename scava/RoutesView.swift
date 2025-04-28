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
    
    private var isLoading: Bool {
        gameViewModel.isLoading
      }

    var body: some View {
        NavigationStack {
            VStack {
                if gameViewModel.isLoading {
                    ScrollView {
                        VStack {
                            Spacer(minLength: 200)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Theme.primary))
                                .scaleEffect(1.5)
                                .padding()
                            Spacer()
                        }
                    }
                } else if routesToShow.isEmpty {
                    VStack {
                        Text("No routes available")
                            .foregroundColor(Theme.textPrimary)
                            .font(.title2)
                        Button("Refresh") {
                            Task {
                                await gameViewModel.fetchRoutes()
                            }
                        }
                        .padding()
                        .background(Theme.primary)
                        .foregroundColor(Theme.textOnPrimary)
                        .cornerRadius(10)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) { // ✅ Use LazyVStack
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
                    .refreshable {
                        await gameViewModel.fetchRoutes()
                    }
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Routes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                if routesToShow.isEmpty {
                    Task {
                        await gameViewModel.fetchRoutes()
                    }
                }
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

            Text("\(String(format: "%.1f", route.distance)) miles • \(route.difficulty)")
                .foregroundColor(Theme.textSecondary)
                .font(.caption)

            Button(action: {
                selectedRoute = route
                showRouteDetail = true
            }) {
                Text("View Route")
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
