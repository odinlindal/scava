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
    let makerID: String
    let totalRatings: Int
    let averageRating: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, difficulty, distance, estimatedTime, landmarks, imageURL, makerID
        case totalRatings, averageRating
    }
    
    init(id: UUID = UUID(), 
         name: String, 
         description: String,
         difficulty: String = "Moderate",
         distance: Double,
         estimatedTime: TimeInterval,
         landmarks: [Landmark],
         imageURL: String? = nil,
         makerID: String,
         totalRatings: Int = 0,
         averageRating: Double = 0.0) {
        self.id = id
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.distance = distance
        self.estimatedTime = estimatedTime
        self.landmarks = landmarks
        self.imageURL = imageURL
        self.makerID = makerID
        self.totalRatings = totalRatings
        self.averageRating = averageRating
    }
    
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
        makerID = try container.decode(String.self, forKey: .makerID)
        totalRatings = try container.decodeIfPresent(Int.self, forKey: .totalRatings) ?? 0
        averageRating = try container.decodeIfPresent(Double.self, forKey: .averageRating) ?? 0.0
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
        try container.encode(makerID, forKey: .makerID)
        try container.encode(totalRatings, forKey: .totalRatings)
        try container.encode(averageRating, forKey: .averageRating)
    }
} 
