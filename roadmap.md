# Roadmap
---

## 1. Project Setup

1. **Create an Xcode Project**
   - Open Xcode and start a new iOS project using Swift.
   - Configure project settings (deployment target, device orientation, etc.).

2. **Configure Location Services**
   - Add the `NSLocationWhenInUseUsageDescription` key in `Info.plist`.
   - Set up a `CLLocationManager` to handle location permissions and updates.

---

## 2. Data Modeling (Local Test Track)

1. **Define Landmark/Checkpoint Model**
   - Create a struct/class (e.g., `Landmark`) containing:
     - Name of the location
     - Coordinates (latitude & longitude)
     - Trigger radius (how close user must be)
     - Question text
     - Answer(s) or correct answer

2. **Local Data Storage**
   - Store an array of `Landmark` in a local file (e.g., JSON) or hardcode it temporarily in code for quick iteration.
   - For initial testing, hardcoding is simplest (e.g., `let landmarks = [Landmark(...), ...]`).

3. **Progress Tracking**
   - Maintain a simple state (e.g., a dictionary or array) to track which landmarks are answered.
   - Optionally, store user progress in `UserDefaults` so it’s retained between app launches.

---

## 3. Core Functionality

1. **Location Monitoring**
   - Set the `CLLocationManager` to receive updates (`startUpdatingLocation`) with desired accuracy.
   - In the `didUpdateLocations` delegate method, compare the user’s `CLLocation` with each `Landmark` coordinate.
   - Determine if the user is within the trigger radius for a given `Landmark`.

2. **Question Presentation**
   - Once the user enters the radius:
     - Check if the question is already answered. If not, present the question UI.
     - The question UI can be a simple modal or a separate view controller.

3. **Answer Validation**
   - Compare the user’s input to the correct answer.
   - If correct, mark the `Landmark` as completed.
   - Provide feedback (e.g., a label “Correct!” or an animation).

4. **Next Checkpoint Guidance**
   - Instead of showing the next location on a map, offer an arrow or hint.
   - Calculate the bearing from the user’s current location to the next unvisited landmark.
   - Update the arrow’s rotation in real-time as the user moves.

---

## 4. UI & UX

1. **Main Screen**
   - Can include a `MKMapView` (optional) or a stylized “compass” style arrow.
   - Show user’s distance to the active landmark if desired.

2. **Question Screen**
   - Simple UI for the question prompt and answer input/selection.
   - Multiple-choice vs. text entry, depending on your use case.

3. **Feedback & Progress**
   - Indicate which landmarks are unlocked or completed.
   - Offer a simple progress bar or fraction (“2 of 5 landmarks found”).

---
