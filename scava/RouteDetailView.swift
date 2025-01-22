import SwiftUI
import MapKit

struct RouteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameViewModel: GameViewModel
    @StateObject private var locationManager: LocationManager
    @State private var showStartRouteAlert = false
    @AppStorage("selectedTab") var selectedTab: Int = 0
    
    init(gameViewModel: GameViewModel) {
        _locationManager = StateObject(wrappedValue: LocationManager(gameViewModel: gameViewModel))
    }
    
    private let routeLocation = CLLocationCoordinate2D(
        latitude: 47.3113,
        longitude: -122.1780
    )
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.red.ignoresSafeArea()
            
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
                    Image("grcroute")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .clipped()
                        .cornerRadius(12)
                    
                    Text("Green River College")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text("Distance: 2.5 miles")
                        .foregroundColor(.white)
                    
                    Text("Difficulty: Moderate")
                        .foregroundColor(.white)
                    
                    Text("Description: A scenic route through the Green River College campus, featuring beautiful architecture and natural landscapes.")
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: routeLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
                    )), interactionModes: []) {
                        MapCircle(center: routeLocation, radius: 200)
                            .foregroundStyle(.red.opacity(0.2))
                            .stroke(.red, lineWidth: 2)
                    }
                    .frame(height: 150)
                    .cornerRadius(12)
                    .padding(.top, 8)
                }
                .padding(.horizontal)
                
                Spacer()
                
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
        .navigationBarBackButtonHidden(true)
        .alert("Start Route", isPresented: $showStartRouteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Start") {
                if let route = gameViewModel.routes.first {
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

#Preview {
    let gameViewModel = GameViewModel()
    return RouteDetailView(gameViewModel: gameViewModel)
        .environmentObject(gameViewModel)
}
