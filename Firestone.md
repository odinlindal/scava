# Firebase Firestore for Scavenger Hunt Routes

This document outlines how to programmatically **create**, **fetch**, **update**, and **delete routes** for a scavenger hunt app using Firebase Firestore.

---

## 1. Adding a Route to Firestore

### Code Example

```swift
import FirebaseFirestore

let db = Firestore.firestore()

func addRoute() {
    let routeData: [String: Any] = [
        "name": "Campus Tour",
        "description": "Explore key landmarks on campus",
        "landmarks": [
            [
                "id": "landmark1",
                "name": "Library",
                "latitude": 37.33182,
                "longitude": -122.03118,
                "radius": 50,
                "question": "When was the library founded?",
                "answer": "1908"
            ],
            [
                "id": "landmark2",
                "name": "Student Union",
                "latitude": 37.33233,
                "longitude": -122.03018,
                "radius": 30,
                "question": "What is the student union's motto?",
                "answer": "Unity in Diversity"
            ]
        ]
    ]

    db.collection("routes").document("routeID1").setData(routeData) { error in
        if let error = error {
            print("Error adding route: \(error.localizedDescription)")
        } else {
            print("Route successfully added!")
        }
    }
}
```

---

## 2. Fetching All Routes

### Code Example

```swift
func fetchRoutes() {
    db.collection("routes").getDocuments { (querySnapshot, error) in
        if let error = error {
            print("Error fetching routes: \(error.localizedDescription)")
            return
        }

        for document in querySnapshot!.documents {
            let data = document.data()
            let routeName = data["name"] as? String ?? "Unnamed Route"
            print("Route: \(routeName)")

            if let landmarks = data["landmarks"] as? [[String: Any]] {
                for landmark in landmarks {
                    let landmarkName = landmark["name"] as? String ?? "Unnamed Landmark"
                    print("Landmark: \(landmarkName)")
                }
            }
        }
    }
}
```

---

## 3. Fetching a Specific Route by ID

### Code Example

```swift
func fetchRoute(byID routeID: String) {
    db.collection("routes").document(routeID).getDocument { (document, error) in
        if let error = error {
            print("Error fetching route: \(error.localizedDescription)")
            return
        }

        if let document = document, document.exists {
            let data = document.data()
            print("Route Data: \(data)")
        } else {
            print("Route does not exist")
        }
    }
}
```

---

## 4. Updating a Route

### Code Example

```swift
func updateRoute(routeID: String) {
    db.collection("routes").document(routeID).updateData([
        "description": "Updated description for the route"
    ]) { error in
        if let error = error {
            print("Error updating route: \(error.localizedDescription)")
        } else {
            print("Route successfully updated!")
        }
    }
}
```

---

## 5. Deleting a Route

### Code Example

```swift
func deleteRoute(routeID: String) {
    db.collection("routes").document(routeID).delete { error in
        if let error = error {
            print("Error deleting route: \(error.localizedDescription)")
        } else {
            print("Route successfully deleted!")
        }
    }
}
```

---

## Summary
- Use `setData` to create new routes.
- Use `getDocuments` to fetch all routes.
- Use `getDocument` to fetch a specific route.
- Use `updateData` to modify a route.
- Use `delete` to remove a route from Firestore.

This structure ensures your app can dynamically interact with Firestore to manage scavenger hunt routes and their associated landmarks.
