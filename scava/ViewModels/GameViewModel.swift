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
    
    init() {
        // Load sample routes for testing
        let grcLandmarks = [
            Landmark(
                name: "Welcome Center",
                latitude: 47.3119,
                longitude: -122.1785,
                triggerRadius: 100,  // Increased from 50 to 100 meters for easier testing
                question: "How many floors does the Welcome Center have?",
                correctAnswer: "2"
            )
            // Comment out other landmarks for now
        ]
        
        routes = [
            Route(
                name: "Green River College Tour",
                description: "Explore the historic Green River College campus and learn about its rich history through this interactive tour.",
                difficulty: "Easy",
                distance: 0.5,
                estimatedTime: 30,
                landmarks: grcLandmarks,
                imageURL: "grcroute"
            )
        ]
        
        // Load completed landmarks from UserDefaults
        if let saved = UserDefaults.standard.array(forKey: "CompletedLandmarks") as? [String] {
            completedLandmarks = Set(saved.compactMap { UUID(uuidString: $0) })
        }
    }
    
    func startRoute(_ route: Route) {
        print("🚀 Starting route: \(route.name)")
        stopRoute() // Clear any existing route state
        activeRoute = route
        isRouteActive = true
    }
    
    func stopRoute() {
        print("🛑 Stopping route")
        activeRoute = nil
        isRouteActive = false
        currentLandmark = nil
        showQuestion = false
        showCompletionAlert = false
        completedLandmarks.removeAll() // Clear completed landmarks
        saveProgress()
    }
    
    func checkLocation(_ location: CLLocation) {
        guard isRouteActive, let route = activeRoute else { 
            print("🚫 No active route")
            return 
        }
        
        // Don't check again if we're already showing a question
        if showQuestion {
            print("❗️ Question already showing, skipping location check")
            return
        }
        
        print("📍 Checking location: \(location.coordinate)")
        
        for landmark in route.landmarks where !completedLandmarks.contains(landmark.id) {
            let landmarkLocation = CLLocation(latitude: landmark.latitude, longitude: landmark.longitude)
            let distance = location.distance(from: landmarkLocation)
            
            print("📏 Distance to \(landmark.name): \(distance) meters (trigger radius: \(landmark.triggerRadius)m)")
            if distance <= landmark.triggerRadius {
                print("❗️ Within range! Triggering question for \(landmark.name)")
                currentLandmark = landmark
                showQuestion = true
                break
            }
        }
    }
    
    func validateAnswer(_ answer: String) -> Bool {
        guard let landmark = currentLandmark else { return false }
        
        let isCorrect = answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
            landmark.correctAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isCorrect {
            completedLandmarks.insert(landmark.id)
            saveProgress()
            
            // Check if all landmarks are completed
            if let route = activeRoute {
                let allCompleted = Set(route.landmarks.map { $0.id }).isSubset(of: completedLandmarks)
                if allCompleted {
                    print("🎉 Route completed!")
                    showCompletionAlert = true
                    currentLandmark = nil  // Clear current landmark
                }
            }
        }
        
        return isCorrect
    }
    
    private func saveProgress() {
        let completedIds = completedLandmarks.map { $0.uuidString }
        UserDefaults.standard.set(completedIds, forKey: "CompletedLandmarks")
    }
}

