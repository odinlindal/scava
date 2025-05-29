import SwiftUI
import MapKit

struct RepositionMapView: View {
    @Binding var spot: RouteSpotDraft          // the one we’re moving
    var otherSpots: [RouteSpotDraft]           // the rest of the route’s landmarks
    @Environment(\.dismiss) private var dismiss
    
    @State private var region: MKCoordinateRegion
    
    init(spot: Binding<RouteSpotDraft>,
         otherSpots: [RouteSpotDraft]) {
        _spot = spot
        self.otherSpots = otherSpots
        let coord = spot.wrappedValue.coordinate
        _region = State(initialValue: MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ZStack {
            // — Render all spots (including the one under the crosshair) as MapAnnotations —
            Map(coordinateRegion: $region,
                annotationItems: otherSpots + [spot]) { draft in
                MapAnnotation(coordinate: draft.coordinate) {
                    // style the “fixed” pins smaller or different color:
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                        .background(Circle().fill(draft.id == spot.id ? Color.clear : Color.gray.opacity(0.7)))
                        .frame(width: 16, height: 16)
                }
            }
                .ignoresSafeArea()
            
            // — Crosshair for the moving spot —
            Image(systemName: "xmark")
                .font(.largeTitle)
                .foregroundColor(Theme.textOnPrimary)
                .shadow(radius: 1)
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .padding()
                            .background(Theme.primary)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                    Text("Moving landmark: \(spot.landmarkName)")
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
                        //ADD CENTER ON USER
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
                        spot.coordinate = region.center
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
    }
}

struct RepositionMapView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample spots
        let movingSpot = RouteSpotDraft(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            landmarkName: "Moving Pin",
            question: "",
            correctAnswer: "",
            triggerRadius: 50
        )
        let fixedSpot1 = RouteSpotDraft(
            coordinate: CLLocationCoordinate2D(latitude: 37.7793, longitude: -122.4192),
            landmarkName: "Fixed A",
            question: "",
            correctAnswer: "",
            triggerRadius: 50
        )
        let fixedSpot2 = RouteSpotDraft(
            coordinate: CLLocationCoordinate2D(latitude: 37.7700, longitude: -122.4300),
            landmarkName: "Fixed B",
            question: "",
            correctAnswer: "",
            triggerRadius: 50
        )
        
        RepositionMapView(
            spot: .constant(movingSpot),
            otherSpots: [fixedSpot1, fixedSpot2]
        )
    }
}
