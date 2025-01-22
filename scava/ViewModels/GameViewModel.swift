import SwiftUI
import CoreLocation

class GameViewModel: ObservableObject {
    @Published var routes: [Route] = []
    @Published var activeRoute: Route?
    @Published var completedLandmarks: Set<UUID> = []
    @Published var currentLandmark: Landmark?
    @Published var showQuestion: Bool = false {
        willSet {
            if newValue {
                if let landmark = currentLandmark {
                    print("📝 Showing question sheet for: \(landmark.name)")
                }
            }
        }
    }
    @Published var showCompletionAlert: Bool = false
    @Published var isRouteActive: Bool = false
    @Published var isRouteCompleted = false
    
    private let firestoreService = FirestoreService()
    
    init() {
        // Load completed landmarks from UserDefaults
        if let saved = UserDefaults.standard.array(forKey: "CompletedLandmarks") as? [String] {
            completedLandmarks = Set(saved.compactMap { UUID(uuidString: $0) })
        }
        
        // Fetch routes from Firestore
        Task {
            await fetchRoutes()
        }
    }
    
    @MainActor
    func fetchRoutes() async {
        do {
            routes = try await firestoreService.fetchRoutes()
            print("📱 Fetched \(routes.count) routes from Firestore")
        } catch {
            print("❌ Error fetching routes: \(error.localizedDescription)")
        }
    }
    
    func startRoute(_ route: Route) {
        print("🚀 Starting route: \(route.name)")
        print("Previous route active state: \(isRouteActive)")
        print("Previous route: \(activeRoute?.name ?? "none")")
        
        stopRoute() // Clear any existing route state
        activeRoute = route
        isRouteActive = true
        isRouteCompleted = false
        
        print("New route active state: \(isRouteActive)")
        print("New active route: \(activeRoute?.name ?? "none")")
    }
    
    func stopRoute() {
        print("🛑 Stopping route - Stack trace:")
        // Print the stack trace to see where this is called from
        Thread.callStackSymbols.forEach { print($0) }
        
        activeRoute = nil
        isRouteActive = false
        currentLandmark = nil
        showQuestion = false
        showCompletionAlert = false
        isRouteCompleted = false
        completedLandmarks.removeAll()
        saveProgress()
    }
    
    func checkLocation(_ location: CLLocation) {
        guard isRouteActive, let route = activeRoute else { 
            print("🚫 No active route - Active: \(isRouteActive), Route: \(activeRoute?.name ?? "none")")
            return 
        }
        
        // Don't check again if we're already showing a question
        if showQuestion {
            print("❗️ Question already showing, skipping location check")
            return
        }
        
        // Check if all landmarks are completed
        if completedLandmarks.count == route.landmarks.count {
            print("🎉 All landmarks completed!")
            isRouteCompleted = true
            showCompletionAlert = true
            return
        }
        
        // Find the next uncompleted landmark
        for landmark in route.landmarks {
            if !completedLandmarks.contains(landmark.id) {
                let landmarkLocation = CLLocation(
                    latitude: landmark.latitude,
                    longitude: landmark.longitude
                )
                
                let distance = location.distance(from: landmarkLocation)
                if distance <= landmark.triggerRadius {
                    print("📍 Within range of landmark: \(landmark.name)")
                    currentLandmark = landmark
                    showQuestion = true
                    break
                }
            }
        }
    }
    
    func validateAnswer(_ answer: String) -> Bool {
        guard let landmark = currentLandmark else { return false }
        
        let isCorrect = answer.lowercased() == landmark.correctAnswer.lowercased()
        if isCorrect {
            completedLandmarks.insert(landmark.id)
            
            // Check if this was the last landmark
            if let route = activeRoute, completedLandmarks.count == route.landmarks.count {
                print("🎉 Route completed!")
                isRouteCompleted = true
                showCompletionAlert = true
            }
        }
        return isCorrect
    }
    
    private func saveProgress() {
        let completedIds = completedLandmarks.map { $0.uuidString }
        UserDefaults.standard.set(completedIds, forKey: "CompletedLandmarks")
    }
    
    var nextLandmark: Landmark? {
        guard let route = activeRoute else { return nil }
        
        // Find the first uncompleted landmark
        return route.landmarks.first { landmark in
            !completedLandmarks.contains(landmark.id)
        }
    }
}

