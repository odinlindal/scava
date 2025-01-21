import SwiftUI

struct QuestionView: View {
    let landmark: Landmark
    @Binding var userAnswer: String
    @Binding var isPresented: Bool
    @Binding var keyboardFocus: Bool
    let onSubmit: (String) -> Void
    @FocusState private var isTextFieldFocused: Bool
    @State private var showFeedback = false
    @State private var isCorrect = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle to indicate draggable sheet
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 16) {
                // Title and close button
                HStack {
                    Text(landmark.name)
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .imageScale(.large)
                    }
                }
                
                // Question
                Text(landmark.question)
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Answer field
                TextField("Your answer", text: $userAnswer)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isTextFieldFocused)
                    .disabled(showFeedback)
                    .onChange(of: isTextFieldFocused) { _, newValue in
                        keyboardFocus = newValue
                    }
                
                if showFeedback {
                    HStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        Text(isCorrect ? "Correct!" : "Try again")
                    }
                    .foregroundColor(isCorrect ? .green : .yellow)
                    .font(.headline)
                }
                
                // Submit button
                Button(action: {
                    isTextFieldFocused = false
                    // Check answer locally first
                    isCorrect = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
                        landmark.correctAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    showFeedback = true
                    
                    // If correct, submit after a short delay
                    if isCorrect {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            onSubmit(userAnswer)
                        }
                    } else {
                        // Clear answer after a delay for retry
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            userAnswer = ""
                            showFeedback = false
                            isTextFieldFocused = true
                        }
                    }
                }) {
                    Text(showFeedback ? (isCorrect ? "Continuing..." : "Try Again") : "Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.red)
                        .cornerRadius(10)
                }
                .disabled(showFeedback && isCorrect) // Disable during "Continuing..." state
            }
            .padding()
            .background(Color.red)
        }
        .background(Color.red)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .frame(maxHeight: 300)
        .transition(.move(edge: .top))
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

// Helper to apply corner radius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    QuestionView(
        landmark: Landmark(
            name: "Test Location",
            latitude: 47.3113,
            longitude: -122.1780,
            question: "What is the test question?",
            correctAnswer: "test"
        ),
        userAnswer: .constant(""),
        isPresented: .constant(true),
        keyboardFocus: .constant(false),
        onSubmit: { _ in }
    )
} 
