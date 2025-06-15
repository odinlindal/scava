import SwiftUI

struct RatingView: View {
    let route: Route
    @EnvironmentObject var gameViewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRating: Int = 0
    @State private var isSubmitting = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Rate Your Experience")
                .font(.title2)
                .foregroundColor(Theme.textPrimary)
            
            Text(route.name)
                .font(.headline)
                .foregroundColor(Theme.textSecondary)
            
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        selectedRating = rating
                    } label: {
                        Image(systemName: rating <= selectedRating ? "star.fill" : "star")
                            .font(.title)
                            .foregroundColor(rating <= selectedRating ? .yellow : .gray)
                    }
                }
            }
            .padding(.vertical)
            
            if selectedRating > 0 {
                Button {
                    submitRating()
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.textOnPrimary))
                    } else {
                        Text("Submit Rating")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.primary)
                .foregroundColor(Theme.textOnPrimary)
                .cornerRadius(10)
                .disabled(isSubmitting)
            }
        }
        .padding()
        .background(Theme.background)
        .alert("Rating Error", isPresented: $gameViewModel.showRatingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(gameViewModel.ratingError ?? "An unknown error occurred")
        }
    }
    
    private func submitRating() {
        guard selectedRating > 0 else { return }
        
        isSubmitting = true
        Task {
            await gameViewModel.rateRoute(route, rating: selectedRating)
            isSubmitting = false
            dismiss()
        }
    }
}

#Preview {
    RatingView(route: Route(
        id: UUID(),
        name: "Sample Route",
        description: "A test route",
        distance: 2.5,
        estimatedTime: 30,
        landmarks: [],
        makerID: "user123"
    ))
    .environmentObject(GameViewModel())
} 