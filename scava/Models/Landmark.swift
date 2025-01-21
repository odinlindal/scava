import CoreLocation

struct Landmark: Identifiable, Codable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let triggerRadius: Double // in meters
    let question: String
    let correctAnswer: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double, 
         triggerRadius: Double = 50, question: String, correctAnswer: String) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.triggerRadius = triggerRadius
        self.question = question
        self.correctAnswer = correctAnswer
    }
}
