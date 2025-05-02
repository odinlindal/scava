import SwiftUI
import MapKit

struct RouteMetaDataScreen: View {
    @EnvironmentObject private var gameViewModel: GameViewModel
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var routeName: String = ""
    @State private var routeDescription: String = ""
    @State private var routeDifficulty: String = "Moderate"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
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
                Text("")
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
                
                // Custom picker (you can leave it as-is or wrap in its own view)
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
                
                Spacer()
                
                // ─────────── Next Button ───────────
                NavigationLink {
                    // build & hand off a complete Route
                    let newRoute = Route(
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
                    MapBuilder(
                        route: newRoute,
                        initialCameraPosition: .region(
                            MKCoordinateRegion(
                                center: locationManager.location?.coordinate ?? .init(latitude: 0, longitude: 0),
                                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        ),
                        isNew: true
                    )
                        .environmentObject(gameViewModel)
                        .environmentObject(locationManager)
                        .environmentObject(authViewModel)
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
            // ─────────── Styling ───────────
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16)
            .padding(.bottom, 50)
            .background(Color(Theme.primaryLight))
        }
        .interactiveDismissDisabled(
            routeName.trimmingCharacters(in: .whitespaces).isEmpty ||
            routeDescription.trimmingCharacters(in: .whitespaces).isEmpty
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    let vm      = GameViewModel()
    let locMgr  = LocationManager(gameViewModel: vm)
    let authVM  = AuthViewModel()
    RouteMetaDataScreen()
        .environmentObject(vm)
        .environmentObject(locMgr)
        .environmentObject(authVM)
}
