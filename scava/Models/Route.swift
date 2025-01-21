import Foundation

struct Route: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let difficulty: String
    let distance: Double // in miles
    let estimatedTime: TimeInterval // in minutes
    let landmarks: [Landmark]
    let imageURL: String? // For the route preview image
    
    init(id: UUID = UUID(), 
         name: String, 
         description: String,
         difficulty: String = "Moderate",
         distance: Double,
         estimatedTime: TimeInterval,
         landmarks: [Landmark],
         imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.distance = distance
        self.estimatedTime = estimatedTime
        self.landmarks = landmarks
        self.imageURL = imageURL
    }
} 