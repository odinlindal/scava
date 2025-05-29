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

// Custom annotation carrying the spot's UUID
private class SpotAnnotation: MKPointAnnotation {
    let spotID: UUID
    init(spotID: UUID) {
        self.spotID = spotID
        super.init()
    }
}

// A map view that supports dropping new landmarks and tapping existing ones
struct DraggableMapView: UIViewRepresentable {
    @Binding var spots: [RouteSpotDraft]
    let initialCameraPosition: MapCameraPosition
    @Binding var cameraPosition: MapCameraPosition
    var onLandmarkDrop: (CLLocationCoordinate2D) -> Void
    var onSpotTap: (RouteSpotDraft) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.userTrackingMode = .none
        if let region = initialCameraPosition.region {
            map.setRegion(region, animated: false)
        }
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
        if let region = cameraPosition.region {
            uiView.setRegion(region, animated: true)
        }
        uiView.removeAnnotations(uiView.annotations)
        for draft in spots {
            let annotation = SpotAnnotation(spotID: draft.id)
            annotation.coordinate = draft.coordinate
            annotation.title = draft.landmarkName.isEmpty ? "Untitled" : draft.landmarkName
            uiView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, UIDropInteractionDelegate {
        var parent: DraggableMapView
        init(_ parent: DraggableMapView) { self.parent = parent }
        
        // Handle dropping of new landmarks
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
        
        // Handle taps on existing annotations
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let ann = view.annotation as? SpotAnnotation,
                  let spot = parent.spots.first(where: { $0.id == ann.spotID })
            else { return }
            DispatchQueue.main.async {
                self.parent.onSpotTap(spot)
            }
        }
    }
}

// Main builder view accepting metadata and allowing landmark placement
struct MapBuilder: View {
    var route: Route
    let isNew: Bool
    let initialCameraPosition: MapCameraPosition
    @EnvironmentObject private var gameViewModel: GameViewModel
    @EnvironmentObject private var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var spots: [RouteSpotDraft] = []
    @State private var editingSpot: RouteSpotDraft?
    @State private var isExisting: Bool = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    init(route: Route, initialCameraPosition: MapCameraPosition, isNew: Bool = false) {
        self.route = route
        self.initialCameraPosition = initialCameraPosition
        self.isNew = isNew
        let initialSpots = route.landmarks.map { lm -> RouteSpotDraft in
            var draft = RouteSpotDraft(
                coordinate: .init(latitude: lm.latitude, longitude: lm.longitude)
            )
            draft.landmarkName = lm.name
            draft.question = lm.question
            draft.correctAnswer = lm.correctAnswer
            draft.triggerRadius = Int(lm.triggerRadius)
            return draft
        }
        _spots = State(initialValue: initialSpots)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DraggableMapView(
                    spots: $spots,
                    initialCameraPosition: initialCameraPosition,
                    cameraPosition: $cameraPosition,
                    onLandmarkDrop: { coord in
                        isExisting = false
                        let newSpot = RouteSpotDraft(coordinate: coord)
                        spots.append(newSpot)
                        editingSpot = newSpot
                    },
                    onSpotTap: { spot in
                        isExisting = true
                        editingSpot = spot
                    }
                )
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Button {
                            dismiss()
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
                        Text("Add Landmarks")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .background(Theme.background)
                            .foregroundColor(Theme.primary)
                            .cornerRadius(8)
                            .padding(.horizontal, 10)
                        Spacer()
                        Button {
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
                    .padding(.vertical, 10)
                    Spacer()
                    HStack {
                        Button {
                            locationManager.requestLocation()
                            if let coord = locationManager.location?.coordinate {
                                let span   = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                let region = MKCoordinateRegion(center: coord, span: span)
                                cameraPosition = .region(region)
                                // no need to reset to .automatic if we only ever care about the tap
                            }
                            DispatchQueue.main.async {
                                cameraPosition = .automatic
                            }
                            
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
                            handleDone()
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
                    }
                }
            }
            .sheet(item: $editingSpot) { spot in
                SingleQuestionEditor(
                    spot: binding(for: spot),
                    allSpots: $spots,
                    isExisting: isExisting,
                    onCancel: { spots.removeAll { $0.id == spot.id } }
                )
            }
            .alert("Route Saved Successfully", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { dismiss() }
            }
            .alert("Failed to create route", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text(errorMessage)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private func binding(for spot: RouteSpotDraft) -> Binding<RouteSpotDraft> {
        guard let idx = spots.firstIndex(where: { $0.id == spot.id }) else {
            fatalError("Spot not found")
        }
        return $spots[idx]
    }
    
    private func handleDone() {
        Task {
            do {
                if isNew {
                    try await gameViewModel.createRoute(
                        base:   route,
                        with:   spots
                    )
                } else {
                    try await gameViewModel.updateRoute(
                        base:   route,
                        with:   spots
                    )
                }
                showSuccessAlert = true
            } catch {
                errorMessage   = error.localizedDescription
                showErrorAlert = true
            }
            await gameViewModel.fetchRoutes()
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

struct MapBuilder_Previews: PreviewProvider {
    static var previews: some View {
        // 1️⃣ Create a shared GameViewModel + LocationManager
        let gameVM = GameViewModel()
        let locMgr = LocationManager(gameViewModel: gameVM)
        //gameVM.locationManager = locMgr  // if your VM exposes it
        
        // 2️⃣ Sample landmarks
        let sampleLandmarks = [
            Landmark(
                id: UUID(),
                name: "Golden Gate",
                latitude: 37.8199,
                longitude: -122.4783,
                triggerRadius: 50,
                question: "What color is the bridge?",
                correctAnswer: "Orange"
            ),
            Landmark(
                id: UUID(),
                name: "Alcatraz",
                latitude: 37.8270,
                longitude: -122.4230,
                triggerRadius: 50,
                question: "What was Alcatraz used for?",
                correctAnswer: "Prison"
            )
        ]
        
        // 3️⃣ A sample Route
        let sampleRoute = Route(
            id: UUID(),
            name: "SF Highlights",
            description: "A quick tour of San Francisco's icons",
            difficulty: "Easy",
            distance: 2.0,
            estimatedTime: 40,
            landmarks: sampleLandmarks,
            imageURL: nil,
            makerID: "preview_user"
        )
        
        // 4️⃣ The MapBuilder in "creating" mode
        MapBuilder(
            route: sampleRoute,
            initialCameraPosition: .region(
                MKCoordinateRegion(
                    center: .init(latitude: 0, longitude: 0),
                    span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            )
        )
        .environmentObject(gameVM)
        .environmentObject(locMgr)
        .previewDevice("iPhone 14")
    }
}
