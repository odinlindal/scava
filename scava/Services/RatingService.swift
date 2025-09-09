import FirebaseFirestore

class RatingService {
    private let db = Firestore.firestore()
    
    func rateRoute(routeID: String, rating: Int) async throws -> Double {
        guard (1...5).contains(rating) else {
            throw RatingError.invalidRating
        }
        
        let result = try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let routeRef = self.db.collection("routes").document(routeID)
            
            let routeSnap: DocumentSnapshot
            do {
                routeSnap = try transaction.getDocument(routeRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let data = routeSnap.data() else {
                let notFound = NSError(
                  domain: "",
                  code: 0,
                  userInfo: [NSLocalizedDescriptionKey: "Route not found"]
                )
                errorPointer?.pointee = notFound
                return nil
            }
            
            let total = data["totalRatings"] as? Int    ?? 0
            let avg   = data["averageRating"] as? Double ?? 0.0
            let newTotal = total + 1
            let newAvg   = ((avg * Double(total)) + Double(rating)) / Double(newTotal)
            
            transaction.updateData([
                "totalRatings":   newTotal,
                "averageRating":  newAvg
            ], forDocument: routeRef)
            
            return newAvg
        }
        
        if let newAvg = result as? Double {
            return newAvg
        } else {
            throw RatingError.transactionFailed
        }
    }
}

enum RatingError: Error {
    case invalidRating
    case transactionFailed
    var localizedDescription: String {
        switch self {
        case .invalidRating:        return "Rating must be between 1 and 5"
        case .transactionFailed:    return "Failed to update rating"
        }
    }
}
