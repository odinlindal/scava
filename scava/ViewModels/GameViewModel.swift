import SwiftUI
import CoreLocation

class GameViewModel: ObservableObject {
    @Published var routes: [Route] = []
    @Published var activeRoute: Route?
    @Published var shouldResumeToMapTab: Bool = false
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
    @Published var isLoading: Bool = true
    
    private var randomizedLandmarks: [Landmark] = []
    
    private let firestoreService = FirestoreService()
    
    private struct RouteState: Codable {
        let route: Route
        let completedLandmarkIDs: [String]
        let randomizedLandmarks: [Landmark]
    }
    
    init() {
        // Load completed landmarks
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
        
        // Try loading routes from cache first
        if let cached = loadRoutesFromCache() {
            routes = cached
            print("📦 Loaded \(routes.count) routes from cache")
            isLoading = false
        }

        // Then fetch latest from Firestore
        Task {
            await fetchRoutes()
        }
    }
    
    @MainActor
    func fetchRoutes() async {
        isLoading = true
        do {
            let freshRoutes = try await firestoreService.fetchRoutes()
            routes = freshRoutes
            saveRoutesToCache(freshRoutes)
            print("📱 Fetched \(routes.count) routes from Firestore and updated cache")
        } catch {
            print("❌ Error fetching routes: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func restoreAppStateIfNeeded() {
        print("\n🔄 Checking for saved state...")
        
        let hasActiveRoute = UserDefaults.standard.bool(forKey: "activeRouteInProgress")
        print("📍 Has active route flag: \(hasActiveRoute)")
        
        guard hasActiveRoute else {
            print("❌ No active route flag found")
            return
        }
        
        guard let data = UserDefaults.standard.data(forKey: "ActiveRouteState") else {
            print("❌ No saved state data found")
            return
        }
        
        print("📦 Found saved state data: \(data.count) bytes")
        
        let decoder = JSONDecoder()
        do {
            let state = try decoder.decode(RouteState.self, from: data)
            print("✅ Successfully decoded state for route: \(state.route.name)")
            
            // Restore route and landmarks
            activeRoute = state.route
            randomizedLandmarks = state.randomizedLandmarks
            
            // Restore completed landmarks
            completedLandmarks = Set(state.completedLandmarkIDs.compactMap { UUID(uuidString: $0) })
            
            // Set active state
            isRouteActive = true
            shouldResumeToMapTab = true
            
            debugPrintState("After Restoring State")
        } catch {
            print("❌ Failed to decode state: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
        }
    }
    
    func startRoute(_ route: Route) {
        print("🚀 Starting route: \(route.name)")
        print("Previous route active state: \(isRouteActive)")
        print("Previous route: \(activeRoute?.name ?? "none")")
        
        stopRoute() // Clear any existing route state
        
        UserDefaults.standard.set(true, forKey: "activeRouteInProgress")
        saveCurrentRouteState()
        
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
            imageURL: route.imageURL
        )
        
        isRouteActive = true
        isRouteCompleted = false
        
        print("New route active state: \(isRouteActive)")
        print("New active route: \(activeRoute?.name ?? "none")")
        print("🎲 Landmarks randomized: \(randomizedLandmarks.map { $0.name })")
    }
    
    func stopRoute() {
        print("🛑 Stopping route")
        // Clear saved state first
        UserDefaults.standard.set(false, forKey: "activeRouteInProgress")
        UserDefaults.standard.removeObject(forKey: "ActiveRouteState")
        
        // Then clear memory state
        activeRoute = nil
        isRouteActive = false
        currentLandmark = nil
        showQuestion = false
        showCompletionAlert = false
        isRouteCompleted = false
        completedLandmarks.removeAll()
        randomizedLandmarks.removeAll()
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
            saveCurrentRouteState()
            
            // Check if this was the last landmark
            if let route = activeRoute, completedLandmarks.count == route.landmarks.count {
                print("🎉 Route completed!")
                isRouteCompleted = true
                showCompletionAlert = true
            }
        }
        return isCorrect
    }
    
    func endRouteAndReturnHome(selectedTab: Binding<Int>, dismiss: DismissAction?) {
        stopRoute()
        selectedTab.wrappedValue = 0
        dismiss?()
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
    
    func saveCurrentRouteState() {
        guard let route = activeRoute else {
            print("❌ Cannot save state: no active route")
            return
        }
        
        debugPrintState("Before Saving State")
        
        let state = RouteState(
            route: route,
            completedLandmarkIDs: completedLandmarks.map { $0.uuidString },
            randomizedLandmarks: randomizedLandmarks
        )
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(state)
            UserDefaults.standard.set(data, forKey: "ActiveRouteState")
            UserDefaults.standard.set(true, forKey: "activeRouteInProgress")
            UserDefaults.standard.synchronize() // Force immediate save
            print("✅ State saved successfully")
            print("📦 Saved data size: \(data.count) bytes")
            
            // Verify the save worked
            if let savedData = UserDefaults.standard.data(forKey: "ActiveRouteState") {
                print("✅ Verified saved data exists: \(savedData.count) bytes")
            } else {
                print("❌ Failed to verify saved data")
            }
        } catch {
            print("❌ Failed to encode state: \(error)")
        }
    }

    private func loadCurrentRouteState() {
        if UserDefaults.standard.bool(forKey: "activeRouteInProgress"),
           let data = UserDefaults.standard.data(forKey: "ActiveRoute") {
            let decoder = JSONDecoder()
            if let route = try? decoder.decode(Route.self, from: data) {
                randomizedLandmarks = route.landmarks
                activeRoute = route
                isRouteActive = true
                shouldResumeToMapTab = true // ✅ Trigger tab change
            }
        }
    }
    
    private func debugPrintState(_ prefix: String) {
        print("\n=== \(prefix) ===")
        print("🟢 Active Route: \(activeRoute?.name ?? "none")")
        print("🟢 Is Route Active: \(isRouteActive)")
        print("🟢 Completed Landmarks: \(completedLandmarks.count)")
        print("🟢 Randomized Landmarks: \(randomizedLandmarks.map { $0.name })")
        print("================\n")
    }
    
    func simulateAppRelaunch() {
        print("\n🔄 Simulating app relaunch...")
        // Clear in-memory state
        activeRoute = nil
        isRouteActive = false
        completedLandmarks.removeAll()
        randomizedLandmarks.removeAll()
        
        debugPrintState("Before Restore")
        // Attempt to restore
        restoreAppStateIfNeeded()
        debugPrintState("After Restore")
    }
}

