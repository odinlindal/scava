import SwiftUI

struct RouteCreationSuccessView: View {
    let route: Route
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int
    var onViewRoutes: () -> Void  // Add callback for when View Routes is pressed
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Custom header
                ZStack {
                    Text("Route Created!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textOnPrimary)
                }
                .padding(.top, 16)
                .frame(maxWidth: .infinity, alignment: .center)
                
                // Success details
                VStack(spacing: 24) {
                    // Checkmark icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.success)
                        .padding(.bottom, 8)
                    
                    // Route name
                    Text(route.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textOnPrimary)
                    
                    // Route details
                    VStack(spacing: 8) {
                        Text("\(route.landmarks.count) landmarks")
                            .font(.subheadline)
                            .foregroundColor(Theme.textOnPrimary.opacity(0.8))
                        Text("Difficulty: \(route.difficulty)")
                            .font(.subheadline)
                            .foregroundColor(Theme.textOnPrimary.opacity(0.8))
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // View Routes button
                Button {
                    selectedTab = 0  // Switch to Routes tab
                    onViewRoutes()   // Notify parent to dismiss
                } label: {
                    Text("View Routes")
                        .font(.headline)
                        .foregroundColor(Theme.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.success)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Theme.primary)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    let route = Route(
        id: UUID(),
        name: "Test Route",
        description: "A beautiful route through the city",
        difficulty: "Easy",
        distance: 2.5,
        estimatedTime: 30,
        landmarks: [
            Landmark(
                id: UUID(),
                name: "First Stop",
                latitude: 37.7749,
                longitude: -122.4194,
                triggerRadius: 50,
                question: "What is the name of this landmark?",
                correctAnswer: "First Stop"
            ),
            Landmark(
                id: UUID(),
                name: "Second Stop",
                latitude: 37.7750,
                longitude: -122.4195,
                triggerRadius: 50,
                question: "What is the name of this landmark?",
                correctAnswer: "Second Stop"
            )
        ],
        imageURL: nil,
        makerID: "user123"
    )
    
    return RouteCreationSuccessView(
        route: route,
        isPresented: .constant(true),
        selectedTab: .constant(0),
        onViewRoutes: {}
    )
} 