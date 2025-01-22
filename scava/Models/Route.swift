import Foundation

struct Route: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let difficulty: String
    let distance: Double // in miles
    let estimatedTime: TimeInterval // in minutes
    let landmarks: [Landmark]
    let imageURL: String?
    let latitude: Double  // Add these instead
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, difficulty, distance, estimatedTime, landmarks, imageURL, latitude, longitude
    }
    
    init(id: UUID = UUID(), 
         name: String, 
         description: String,
         difficulty: String = "Moderate",
         distance: Double,
         estimatedTime: TimeInterval,
         landmarks: [Landmark],
         imageURL: String? = nil,
         latitude: Double,  // Add these parameters
         longitude: Double) {
        self.id = id
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.distance = distance
        self.estimatedTime = estimatedTime
        self.landmarks = landmarks
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Add encode/decode methods for CLLocationCoordinate2D
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        difficulty = try container.decode(String.self, forKey: .difficulty)
        distance = try container.decode(Double.self, forKey: .distance)
        estimatedTime = try container.decode(TimeInterval.self, forKey: .estimatedTime)
        landmarks = try container.decode([Landmark].self, forKey: .landmarks)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(distance, forKey: .distance)
        try container.encode(estimatedTime, forKey: .estimatedTime)
        try container.encode(landmarks, forKey: .landmarks)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
} 
