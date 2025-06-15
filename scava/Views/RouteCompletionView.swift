import SwiftUI

struct RouteCompletionView: View {
    let route: Route
    let elapsedTime: TimeInterval
    @Binding var isPresented: Bool
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var rating: Int = 0
    @State private var isSubmitting = false
    
    private var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Custom header
                ZStack {
                    Text("Route Completed!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textOnPrimary)
                }
                .padding(.top, 16)
                .frame(maxWidth: .infinity, alignment: .center)
                
                // Completion details
                VStack(spacing: 24) {
                    // Trophy icon
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.textOnPrimary)
                        .padding(.bottom, 8)
                    
                    // Route name
                    Text(route.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textOnPrimary)
                    
                    // Time taken
                    VStack(spacing: 8) {
                        Text("Time Taken")
                            .font(.subheadline)
                            .foregroundColor(Theme.textOnPrimary.opacity(0.8))
                        Text(formattedTime)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textOnPrimary)
                    }
                    .padding(.vertical)
                    
                    // Rating section
                    VStack(spacing: 16) {
                        Text("How was your experience?")
                            .font(.headline)
                            .foregroundColor(Theme.textOnPrimary)
                        
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { index in
                                Button {
                                    rating = index
                                } label: {
                                    Image(systemName: index <= rating ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundColor(index <= rating ? .yellow : Theme.textOnPrimary.opacity(0.5))
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Submit button
                Button {
                    submitRating()
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.textOnPrimary))
                    } else {
                        Text("Finish")
                            .font(.headline)
                            .foregroundColor(Theme.textOnPrimary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(rating > 0 ? Theme.success : Theme.success.opacity(0.5))
                .cornerRadius(10)
                .disabled(rating == 0 || isSubmitting)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Theme.primary)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private func submitRating() {
        guard rating > 0 else { return }
        
        isSubmitting = true
        Task {
            await gameViewModel.rateRoute(route, rating: rating)
            isSubmitting = false
            gameViewModel.stopRoute()  // Stop the route after rating is submitted
            isPresented = false
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
        landmarks: [],
        imageURL: "grcroute",
        makerID: "1234"
    )
    
    return RouteCompletionView(
        route: route,
        elapsedTime: 1234, // 20:34
        isPresented: .constant(true)
    )
    .environmentObject(GameViewModel())
} 
