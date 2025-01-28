import Foundation
import CoreHaptics
import CoreLocation

class HapticManager: ObservableObject {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
    private var pulsePlayer: CHHapticPatternPlayer?
    private var currentInterval: TimeInterval = 2.0
    @Published var currentDistance: Double = 0
    private var currentTimer: Timer?
    private var updateTimer: Timer?
    
    init() {
        setupHapticEngine()
    }
    
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine creation error: \(error)")
        }
    }
    
    func startMonitoring(for distance: CLLocationDistance, triggerRadius: Double, isQuestionShowing: Bool) {
        // Stop monitoring if question is showing
        if isQuestionShowing {
            stopPulse()
            return
        }
        
        // Stop any existing timer
        updateTimer?.invalidate()
        
        // Update immediately
        updateDistance(distance, triggerRadius: triggerRadius)
        
        // Create new timer for updates
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateDistance(distance, triggerRadius: triggerRadius)
        }
    }
    
    private func updateDistance(_ distance: CLLocationDistance, triggerRadius: Double) {
        DispatchQueue.main.async {
            self.currentDistance = distance
        }
        
        print("📏 Distance to landmark: \(String(format: "%.1f", distance))m (Trigger: \(triggerRadius)m)")
        
        // Only pulse if we're outside the trigger radius
        if distance > triggerRadius {
            // Calculate interval based on distance to trigger radius instead of total distance
            let distanceToTrigger = distance - triggerRadius
            let newInterval = max(0.3, min(2.0, distanceToTrigger / 25.0))
            
            if abs(newInterval - currentInterval) > 0.1 {
                currentInterval = newInterval
                print("🔄 Updating pulse interval to: \(String(format: "%.1f", currentInterval))s")
                createPulse(distanceToTrigger: distanceToTrigger, triggerRadius: triggerRadius)
            }
        } else {
            stopPulse()
        }
    }
    
    private func createPulse(distanceToTrigger: Double, triggerRadius: Double) {
        // Stop existing timer
        currentTimer?.invalidate()
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        // Adjust intensity based on distance (stronger when closer)
        let intensityValue = max(0.3, min(1.0, 1.0 - (distanceToTrigger / 50.0)))
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensityValue))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(intensityValue))
        
        do {
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)  // Create local player first
            self.pulsePlayer = player  // Then assign to property
            
            // Schedule repeated playback with new timer
            currentTimer = Timer.scheduledTimer(withTimeInterval: currentInterval, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                guard let player = self.pulsePlayer else { return }
                
                do {
                    try player.start(atTime: 0)
                } catch {
                    print("Failed to play haptic: \(error)")
                }
            }
        } catch {
            print("Failed to create pattern: \(error)")
        }
    }
    
    func stopPulse() {
        updateTimer?.invalidate()
        updateTimer = nil
        currentTimer?.invalidate()
        currentTimer = nil
        
        if let player = pulsePlayer {
            do {
                try player.stop(atTime: 0)
            } catch {
                print("Failed to stop haptic: \(error)")
            }
        }
        pulsePlayer = nil
    }
} 
