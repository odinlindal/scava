import SwiftUI
import MapKit

// Draft model representing a spot during route creation
struct RouteSpotDraft: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var landmarkName: String = ""
    var question: String = ""
    var correctAnswer: String = ""
    var triggerRadius: Int = 50
}

// A basic MKMapView wrapper to support dropping landmarks onto the map
struct DraggableMapView: UIViewRepresentable {
    @Binding var spots: [RouteSpotDraft]
    var onLandmarkDrop: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.showsUserLocation = true              // ← show the blue dot
        map.userTrackingMode = .none              // ← start with no auto‐follow
        map.addInteraction(UIDropInteraction(delegate: context.coordinator))
        let lp = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handleLongPress(_:))
        )
        lp.minimumPressDuration = 0.5
        map.addGestureRecognizer(lp)
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        let annotations = spots.map { draft -> MKPointAnnotation in
            let ann = MKPointAnnotation()
            ann.coordinate = draft.coordinate
            ann.title = draft.landmarkName.isEmpty ? "Untitled" : draft.landmarkName
            return ann
        }
        uiView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIDropInteractionDelegate {
        var parent: DraggableMapView
        init(_ parent: DraggableMapView) { self.parent = parent }

        func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
            guard let mapView = interaction.view as? MKMapView else { return }
            session.loadObjects(ofClass: NSString.self) { _ in
                let point = session.location(in: mapView)
                let coord = mapView.convert(point, toCoordinateFrom: mapView)
                DispatchQueue.main.async {
                    self.parent.onLandmarkDrop(coord)
                }
            }
        }

        func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
            session.canLoadObjects(ofClass: NSString.self)
        }

        @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
            guard recognizer.state == .began,
                  let mapView = recognizer.view as? MKMapView
            else { return }
            let pt = recognizer.location(in: mapView)
            let coord = mapView.convert(pt, toCoordinateFrom: mapView)
            DispatchQueue.main.async {
                self.parent.onLandmarkDrop(coord)
            }
        }
    }
}

// Main builder view accepting metadata and allowing landmark placement
struct MapBuilder: View {
    let routeName: String
    let routeDescription: String
    let routeDifficulty: String
    @Binding var isCreatingRoute: Bool

    @EnvironmentObject private var gameViewModel: GameViewModel
    @EnvironmentObject private var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss

    @State private var spots: [RouteSpotDraft] = []
    @State private var editingSpot: RouteSpotDraft?
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            DraggableMapView(spots: $spots) { coord in
                let newSpot = RouteSpotDraft(coordinate: coord)
                spots.append(newSpot)
                editingSpot = newSpot
            }
            .ignoresSafeArea()
            .navigationTitle(routeName)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            
            VStack {
                            HStack {
                                Button{
                                    isCreatingRoute = false
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Theme.primary)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding(.horizontal, 20)
                                Spacer()
                                Button{
                                    print("search")
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Theme.primary)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding(.horizontal, 20)
                            }
                            Spacer()
                HStack {
                    Button {
                        // simply jump the map to the user:
                        locationManager.requestLocation()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Theme.primary)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                    Button {
                        guard spots.count >= 2 else { return }
                        Task {
                            do {
                                try await gameViewModel.createRouteAsync(
                                    with: spots,
                                    name: routeName,
                                    description: routeDescription,
                                    difficulty: routeDifficulty
                                )
                                showSuccessAlert = true
                            } catch {
                                errorMessage = error.localizedDescription
                                showErrorAlert = true
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(spots.count >= 2 ? Color.green : Color.gray)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .disabled(spots.count < 2)
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .alert("Route created!", isPresented: $showSuccessAlert) {
                    Button("OK", role: .cancel) {
                        isCreatingRoute = false
                    }
                }
                .alert("Failed to create route", isPresented: $showErrorAlert) {
                    Button("OK", role: .cancel) {
                        isCreatingRoute = false
                    }
                } message: {
                    Text(errorMessage)
                }
            }
            .sheet(item: $editingSpot) { spot in
                SingleQuestionEditor(spot: binding(for: spot),
                                     onCancel: {
                    spots.removeAll { $0.id == spot.id }
                })
            }
        }
    }

    private func binding(for spot: RouteSpotDraft) -> Binding<RouteSpotDraft> {
        guard let idx = spots.firstIndex(where: { $0.id == spot.id }) else {
            fatalError("Spot not found")
        }
        return $spots[idx]
    }
}

#Preview("Map Builder") {
    let vm = GameViewModel()
    let loc = LocationManager(gameViewModel: vm)
    return MapBuilder(
        routeName: "Test Route",
        routeDescription: "A sample route",
        routeDifficulty: "Easy",
        isCreatingRoute: .constant(true)
    )
    .environmentObject(vm)
    .environmentObject(loc)
}
