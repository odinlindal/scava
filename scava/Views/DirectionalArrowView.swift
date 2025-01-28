import SwiftUI
import CoreLocation

struct DirectionalArrowView: View {
    let userLocation: CLLocation
    let targetLocation: CLLocation
    @StateObject private var locationManager: LocationManager
    @State private var heading: Double = 0
    
    init(userLocation: CLLocation, targetLocation: CLLocation, gameViewModel: GameViewModel) {
        self.userLocation = userLocation
        self.targetLocation = targetLocation
        _locationManager = StateObject(wrappedValue: LocationManager(gameViewModel: gameViewModel))
    }
    
    private var arrowRotation: Double {
        let bearing = calculateBearing()
        // Subtract the device heading to make it compass-like
        return bearing - (locationManager.heading?.trueHeading ?? 0)
    }
    
    private func calculateBearing() -> Double {
        let lat1 = userLocation.coordinate.latitude.radians
        let lon1 = userLocation.coordinate.longitude.radians
        let lat2 = targetLocation.coordinate.latitude.radians
        let lon2 = targetLocation.coordinate.longitude.radians
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x)
        
        return bearing.degrees
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 100, height: 100)
            
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundColor(.green)
                .rotationEffect(.degrees(arrowRotation))
                .animation(.smooth, value: arrowRotation)
        }
    }
}

// Helper extensions
extension Double {
    var radians: Double { self * .pi / 180 }
    var degrees: Double { self * 180 / .pi }
}
