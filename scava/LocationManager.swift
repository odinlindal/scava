//
//  LocationManager.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//

import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var region = MapCameraPosition.userLocation(fallback: MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3361, longitude: -122.0380),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )))
    @Published var location: CLLocation?
    private var gameViewModel: GameViewModel?
    
    private var isInitialLocation = true
    
    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        print("Starting location tracking")
        locationManager.startUpdatingLocation()
    }
    
    func requestLocation() {
        isInitialLocation = false
        if let location = locationManager.location {
            region = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        
        // Always update region when tracking
        if gameViewModel?.isRouteActive == true {
            region = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)  // Closer zoom
            ))
        } else if isInitialLocation {
            region = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
            isInitialLocation = false
        }
        
        // Check location for route
        if let gameViewModel = gameViewModel {
            gameViewModel.checkLocation(location)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}
