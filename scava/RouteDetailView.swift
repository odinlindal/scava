import SwiftUI
import MapKit

struct RouteDetailView: View {
    let route: Route
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showStartRouteAlert = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showMapBuilder = false
    @State private var showErrorAlert = false
    @State private var deleteAlert = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack(alignment: .top) {
            Theme.primary.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        //REPLACE WITH ASYNC IMAGE WHEN USING URLS @ SOME POINT
                        /*if let imageURL = route.imageURL {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .clipped()
                        }*/
                        
                        Image("grcroute")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 140)
                            .clipped()
                            .cornerRadius(8)
                        
                        Text(route.name)
                            .font(.title)
                            .foregroundColor(Theme.textOnPrimary)
                        
                        Text("Distance: \(String(format: "%.1f", route.distance)) miles")
                            .foregroundColor(Theme.textOnPrimary)
                        
                        Text("Difficulty: \(route.difficulty)")
                            .foregroundColor(Theme.textOnPrimary)
                        
                        Text(route.description)
                            .foregroundColor(Theme.textOnPrimary)
                            .padding(.top, 8)
                        
                        Map(position: $cameraPosition,
                            interactionModes: []) {
                            ForEach(route.landmarks) { landmark in
                                Marker(landmark.name, coordinate: landmark.coordinate)
                            }
                        }
                            .frame(height: 180)
                            .cornerRadius(12)
                            .padding(.top, 8)
                            .onAppear {
                                // compute bounding region and wrap it as a MapCameraPosition
                                let region = boundingRegion(for: route.landmarks)
                                cameraPosition = .region(region)
                            }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        showStartRouteAlert = true
                    }) {
                        Text("Start Route")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.textOnPrimary)
                            .foregroundColor(Theme.primary)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    if (authViewModel.currentUser?.id == route.makerID) {
                        Button {
                            showMapBuilder = true
                        } label: {
                            Text("Edit Route")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.secondary)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        Button {
                            deleteAlert = true
                        } label: {
                            Text("Delete Route")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.error.opacity(0.5))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(route.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Theme.textOnPrimary)
                    }
                }
            }
        .alert("Start Route", isPresented: $showStartRouteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Start") {
                locationManager.startTracking()
                gameViewModel.startRoute(route)
                selectedTab = 1
                dismiss()
            }
        } message: {
            Text("Are you ready to begin this route?")
        }
        .alert("Failed to delete route", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text(errorMessage)
        }
        .alert("Delete Route", isPresented: $deleteAlert) {
            Button("Yes") {
                handleDelete()
                dismiss()
            }
            Button("No", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this route?")
        }
        .fullScreenCover(isPresented: $showMapBuilder) {
            MapBuilder(route: route, initialCameraPosition: cameraPosition, isNew: false)
        }
    }
    private func handleDelete() {
        Task {
            do {
                try await gameViewModel.deleteRouteAsync(route)
                await gameViewModel.fetchRoutes()
            } catch {
                errorMessage   = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}

private func boundingRegion(for landmarks: [Landmark]) -> MKCoordinateRegion {
  let lats = landmarks.map { $0.coordinate.latitude }
  let lons = landmarks.map { $0.coordinate.longitude }
  guard let minLat = lats.min(),
        let maxLat = lats.max(),
        let minLon = lons.min(),
        let maxLon = lons.max() else {
    // Fallback if no landmarks
    return MKCoordinateRegion(center: .init(latitude: 0, longitude: 0),
                              span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
  }
  // Center is midpoint
  let center = CLLocationCoordinate2D(
    latitude: (minLat + maxLat) / 2,
    longitude: (minLon + maxLon) / 2
  )
  // Span covers full range + 30% padding
  let latDelta = (maxLat - minLat) * 1.3
  let lonDelta = (maxLon - minLon) * 1.3
  return MKCoordinateRegion(
    center: center,
    span: MKCoordinateSpan(
      latitudeDelta: max(latDelta, 0.005),
      longitudeDelta: max(lonDelta, 0.005)
    )
  )
}

#Preview {
    NavigationView {
        RouteDetailView(
            route: Route(
                id: UUID(),
                name: "Sample Route",
                description: "A beautiful route through the city",
                difficulty: "Easy",
                distance: 2.5,
                estimatedTime: 30,
                landmarks: [
                    Landmark(
                        id: UUID(),
                        name: "First Stop",
                        latitude: 37.7749,
                        longitude: -122.4194,
                        triggerRadius: 50,
                        question: "What is the name of this landmark?",
                        correctAnswer: "First Stop"
                    ),
                    Landmark(
                        id: UUID(),
                        name: "Second Stop",
                        latitude: 37.7750,
                        longitude: -122.4195,
                        triggerRadius: 50,
                        question: "What is the name of this landmark?",
                        correctAnswer: "Second Stop"
                    )
                ],
                imageURL: "grcroute",
                makerID: ""
            ),
            selectedTab: .constant(0)
        )
        .environmentObject(GameViewModel())
        .environmentObject(LocationManager(gameViewModel: GameViewModel()))
        .environmentObject(AuthViewModel())
    }
}
