import FirebaseFirestore

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    
    func fetchRoutes() async throws -> [Route] {
        do {
            let snapshot = try await db.collection("routes").getDocuments()
            return snapshot.documents.compactMap { document in
                let data = document.data()
                return Route(
                    id: UUID(uuidString: document.documentID) ?? UUID(),
                    name: data["name"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    difficulty: data["difficulty"] as? String ?? "Easy",
                    distance: data["distance"] as? Double ?? 0.0,
                    estimatedTime: data["estimatedTime"] as? TimeInterval ?? 0,
                    landmarks: (data["landmarks"] as? [[String: Any]])?.compactMap { landmarkData in
                        Landmark(
                            id: UUID(),
                            name: landmarkData["name"] as? String ?? "",
                            latitude: landmarkData["latitude"] as? Double ?? 0,
                            longitude: landmarkData["longitude"] as? Double ?? 0,
                            triggerRadius: landmarkData["triggerRadius"] as? Double ?? 50,
                            question: landmarkData["question"] as? String ?? "",
                            correctAnswer: landmarkData["correctAnswer"] as? String ?? ""
                        )
                    } ?? [],
                    imageURL: data["imageURL"] as? String,
                    makerID: data["makerID"] as? String ?? ""
                )
            }
        } catch {
            print("❌ Error fetching routes: \(error.localizedDescription)")
            throw error
        }
    }
    
    func createRoute(_ route: Route) async throws {
        let data = try Firestore.Encoder().encode(route)
        try await db
          .collection("routes")
          .document(route.id.uuidString)
          .setData(data)
      }
    
    func updateRoute(_ route: Route) async throws {
        let data = try Firestore.Encoder().encode(route)
        try await db
          .collection("routes")
          .document(route.id.uuidString)
          .setData(data, merge: true)
      }
}
