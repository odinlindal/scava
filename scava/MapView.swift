//
//  MapView.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//
import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var showRoutePreview = false
    @State private var showRouteDetail = false
    
    private let routeLocation = CLLocationCoordinate2D(
        latitude: 47.3113,
        longitude: -122.1780
    )
    
    var body: some View {
        ZStack {
            Map(position: $locationManager.region, interactionModes: .all) {
                UserAnnotation()
                
                MapCircle(center: routeLocation, radius: 200)
                    .foregroundStyle(.red.opacity(0.2))
                    .stroke(.red, lineWidth: 2)
                    .mapOverlayLevel(level: .aboveRoads)
                
                Annotation("", coordinate: routeLocation) {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 200, height: 200) // Made it bigger to match circle size
                        .contentShape(Circle())
                        .onTapGesture {
                            showRoutePreview = true
                        }
                }
                .annotationTitles(.hidden)
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                if !showRouteDetail {
                    showRoutePreview = false
                }
            }
            
            VStack {
                Spacer()
                
                if showRoutePreview {
                    // Route Preview Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Green River College")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text("2.5 miles • Moderate")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showRouteDetail = true
                            showRoutePreview = false
                        }) {
                            Text("View Details")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding()
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        locationManager.requestLocation()
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
        .fullScreenCover(isPresented: $showRouteDetail) {
            RouteDetailView()
        }
    }
}

#Preview {
    MapView()
}
