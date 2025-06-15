import SwiftUI
import MapKit

struct RouteMetaDataScreen: View {
    @EnvironmentObject private var gameViewModel: GameViewModel
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int
    
    @State private var routeName: String = ""
    @State private var routeDescription: String = ""
    @State private var routeDifficulty: String = "Moderate"
    @State private var showMapBuilder = false
    
    var body: some View {
        ZStack {
            Theme.primaryLight.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // — Custom header —
                    ZStack {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Theme.primary)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            Spacer()
                        }
                        Text("New Route")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textOnPrimary)
                        Spacer()
                    }
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // ─────────── Inputs ───────────
                    InputView(
                        text: $routeName,
                        title: "Route Name",
                        placeholder: "Enter route name"
                    )
                    InputView(
                        text: $routeDescription,
                        title: "Description",
                        placeholder: "Enter description"
                    )
                    
                    // Custom picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Difficulty")
                            .foregroundColor(Theme.textOnPrimary)
                            .fontWeight(.semibold)
                            .font(.footnote)
                        Picker("Difficulty", selection: $routeDifficulty) {
                            Text("Easy").tag("Easy")
                            Text("Moderate").tag("Moderate")
                            Text("Hard").tag("Hard")
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Spacer(minLength: 0)
                    
                    // ─────────── Next Button ───────────
                    Button {
                        showMapBuilder = true
                    } label: {
                        Text("Next")
                            .font(.subheadline)
                            .foregroundColor(Theme.textOnPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(routeName.isEmpty || routeDescription.isEmpty
                                        ? Color.gray
                                        : Theme.success)
                            .cornerRadius(8)
                    }
                    .disabled(routeName.isEmpty || routeDescription.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 50)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .interactiveDismissDisabled()
        .fullScreenCover(isPresented: $showMapBuilder) {
            let route = Route(
                id: UUID(),
                name: routeName,
                description: routeDescription,
                difficulty: routeDifficulty,
                distance: 0,
                estimatedTime: 0,
                landmarks: [],
                imageURL: nil,
                makerID: authViewModel.currentUser?.id ?? ""
            )
            
            // For new routes, use the user's current location
            let initialCameraPosition: MapCameraPosition = {
                if let location = locationManager.location?.coordinate {
                    return .region(MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                }
                return .automatic
            }()
            
            MapBuilder(
                route: route,
                initialCameraPosition: initialCameraPosition,
                isNew: true,
                selectedTab: $selectedTab
            ) {
                showMapBuilder = false
                dismiss()
                Task { await gameViewModel.fetchRoutes() }
            }
            .environmentObject(gameViewModel)
            .environmentObject(locationManager)
        }
    }
}

#Preview {
    let vm      = GameViewModel()
    let locMgr  = LocationManager(gameViewModel: vm)
    let authVM  = AuthViewModel()
    return RouteMetaDataScreen(selectedTab: .constant(0))
        .environmentObject(vm)
        .environmentObject(locMgr)
        .environmentObject(authVM)
}
