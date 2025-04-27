import SwiftUI

struct RouteMetaDataScreen: View {
    @EnvironmentObject private var gameViewModel: GameViewModel
    @EnvironmentObject private var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    @Binding var isCreatingRoute: Bool
    @State private var routeName: String = ""
    @State private var routeDescription: String = ""
    @State private var routeDifficulty: String = "Moderate"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Route Name", text: $routeName)
                TextField("Description", text: $routeDescription)
                Picker("Difficulty", selection: $routeDifficulty) {
                    Text("Easy").tag("Easy")
                    Text("Moderate").tag("Moderate")
                    Text("Hard").tag("Hard")
                }
                Section {
                    NavigationLink("Next") {
                        MapBuilder(
                            routeName: routeName,
                            routeDescription: routeDescription,
                            routeDifficulty: routeDifficulty,
                            isCreatingRoute: $isCreatingRoute
                        )
                        .environmentObject(gameViewModel)
                        .environmentObject(locationManager)
                    }
                    .disabled(routeName.isEmpty || routeDescription.isEmpty)
                }
            }
            .navigationTitle("New Route")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isCreatingRoute = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Theme.textOnPrimary)
                    }
                }
            }
        }
    }
}

#Preview {
    let vm = GameViewModel()
    let locManager = LocationManager(gameViewModel: vm)
    return RouteMetaDataScreen(isCreatingRoute: .constant(true))
        .environmentObject(vm)
        .environmentObject(locManager)
}
