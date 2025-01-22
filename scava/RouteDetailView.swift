import SwiftUI
import MapKit

struct RouteDetailView: View {
    let route: Route?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameViewModel: GameViewModel
    @StateObject private var locationManager: LocationManager
    @State private var showStartRouteAlert = false
    @AppStorage("selectedTab") var selectedTab: Int = 0
    
    init(route: Route?, gameViewModel: GameViewModel) {
        print("📍 Initializing RouteDetailView")
        if let route = route {
            print("📱 Route data received: \(route.name)")
        }
        self.route = route
        _locationManager = StateObject(wrappedValue: LocationManager(gameViewModel: gameViewModel))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.red.ignoresSafeArea()
            
            if let route = route {
                // Full route detail view
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .imageScale(.large)
                                .padding()
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            if let imageURL = route.imageURL {
                                Image(imageURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 100)
                                    .clipped()
                                    .cornerRadius(12)
                            }
                            
                            Text(route.name)
                                .font(.title)
                                .foregroundColor(.white)
                            
                            Text("Distance: \(String(format: "%.1f", route.distance)) miles")
                                .foregroundColor(.white)
                            
                            Text("Difficulty: \(route.difficulty)")
                                .foregroundColor(.white)
                            
                            Text(route.description)
                                .foregroundColor(.white)
                                .padding(.top, 8)
                            
                            Map(initialPosition: .region(MKCoordinateRegion(
                                center: CLLocationCoordinate2D(
                                    latitude: route.latitude,
                                    longitude: route.longitude
                                ),
                                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                    )
                                ),
                                    interactionModes: []
                            ) {
                                // Show route markers
                                ForEach(route.landmarks) { landmark in
                                    Marker(landmark.name, coordinate: landmark.coordinate)
                                        .tint(.red)
                                }
                                
                                // Show route center
                                MapCircle(center: CLLocationCoordinate2D(
                                    latitude: route.latitude,
                                    longitude: route.longitude
                                ), radius: 200)
                                    .foregroundStyle(.red.opacity(0.2))
                                    .stroke(.red, lineWidth: 2)
                            }
                            .frame(height: 150)
                            .cornerRadius(12)
                            .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                        
                        Button(action: {
                            showStartRouteAlert = true
                        }) {
                            Text("Start Route")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.red)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            } else {
                // Error view with working back button
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .imageScale(.large)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                    
                    Text("Unable to load route details")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Button("Go Back") {
                        dismiss()
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.red)
                    .cornerRadius(10)
                    .padding(.top)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Start Route", isPresented: $showStartRouteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Start") {
                if let route = route {
                    locationManager.startTracking()
                    gameViewModel.startRoute(route)
                    selectedTab = 1
                    dismiss()
                }
            }
        } message: {
            Text("Are you ready to begin this route?")
        }
    }
}
