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
            VStack(spacing: 24) {
                ZStack {
                    HStack {
                        Button {
                            isCreatingRoute = false
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
                    MapBuilder(
                        routeName:        routeName,
                        routeDescription: routeDescription,
                        routeDifficulty:  routeDifficulty,
                        isCreatingRoute:  $isCreatingRoute
                    )
                    .environmentObject(gameViewModel)
                    .environmentObject(locationManager)
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
    let vm = GameViewModel()
    let locManager = LocationManager(gameViewModel: vm)
    return RouteMetaDataScreen(isCreatingRoute: .constant(true))
        .environmentObject(vm)
        .environmentObject(locManager)
}
