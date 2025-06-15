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
    var onNext: (String, String, String) -> Void
    
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
                        onNext(routeName, routeDescription, routeDifficulty)
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
    }
}

#Preview {
    let vm      = GameViewModel()
    let locMgr  = LocationManager(gameViewModel: vm)
    let authVM  = AuthViewModel()
    return RouteMetaDataScreen(onNext: { _, _, _ in })
        .environmentObject(vm)
        .environmentObject(locMgr)
        .environmentObject(authVM)
}
