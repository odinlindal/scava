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
    
    private var randomizedLandmarks: [Landmark] = []
    
    private let firestoreService = FirestoreService()
    
    init() {
        if let saved = UserDefaults.standard.array(forKey: "CompletedLandmarks") as? [String] {
            let uuids = saved.compactMap { UUID(uuidString: $0) }
            if uuids.count == saved.count {
                completedLandmarks = Set(uuids)
            } else {
                print("⚠️ Skipped loading invalid UUIDs from CompletedLandmarks")
                completedLandmarks = []
            }
        } else {
            completedLandmarks = []
        }
        
        // Try loading routes from cache
        if let cached = loadRoutesFromCache() {
            routes = cached
            print("📦 Loaded \(routes.count) routes from cache")
        }

        // Then fetch latest from Firestore
        Task {
            await fetchRoutes()
        }
    }
    
    @MainActor
    func fetchRoutes() async {
        do {
            let freshRoutes = try await firestoreService.fetchRoutes()
            routes = freshRoutes
            saveRoutesToCache(freshRoutes)
            print("📱 Fetched \(routes.count) routes from Firestore and updated cache")
        } catch {
            print("❌ Error fetching routes: \(error.localizedDescription)")
        }
    }
    
    func startRoute(_ route: Route) {
        print("🚀 Starting route: \(route.name)")
        print("Previous route active state: \(isRouteActive)")
        print("Previous route: \(activeRoute?.name ?? "none")")
        
        stopRoute() // Clear any existing route state
        
        // Create a new route with randomized landmarks
        randomizedLandmarks = route.landmarks.shuffled()
        activeRoute = Route(
            id: route.id,
            name: route.name,
            description: route.description,
            difficulty: route.difficulty,
            distance: route.distance,
            estimatedTime: route.estimatedTime,
            landmarks: randomizedLandmarks,  // Use randomized landmarks
            imageURL: route.imageURL,
            latitude: route.latitude,
            longitude: route.longitude
        )
        
        isRouteActive = true
        isRouteCompleted = false
        
        print("New route active state: \(isRouteActive)")
        print("New active route: \(activeRoute?.name ?? "none")")
        print("🎲 Landmarks randomized: \(randomizedLandmarks.map { $0.name })")
    }
    
    func stopRoute() {
        print("🛑 Stopping route")
        activeRoute = nil
        isRouteActive = false
        currentLandmark = nil
        showQuestion = false
        showCompletionAlert = false
        isRouteCompleted = false
        completedLandmarks.removeAll()
        randomizedLandmarks.removeAll()  // Clear randomized landmarks
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
        
        // Only check the next uncompleted landmark
        if let nextLandmark = nextLandmark {
            let landmarkLocation = CLLocation(
                latitude: nextLandmark.latitude,
                longitude: nextLandmark.longitude
            )
            
            let distance = location.distance(from: landmarkLocation)
            if distance <= nextLandmark.triggerRadius {
                print("📍 Within range of next landmark: \(nextLandmark.name)")
                currentLandmark = nextLandmark
                showQuestion = true
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
    
    private func saveRoutesToCache(_ routes: [Route]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(routes) {
            UserDefaults.standard.set(data, forKey: "CachedRoutes")
        }
    }
    
    private func loadRoutesFromCache() -> [Route]? {
        if let data = UserDefaults.standard.data(forKey: "CachedRoutes") {
            let decoder = JSONDecoder()
            return try? decoder.decode([Route].self, from: data)
        }
        return nil
    }
}

