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
        VStack(spacing: 56) {  // Adjust spacing as needed
            VStack(alignment: .leading, spacing: 16) {
                // Title and close button
                HStack {
                    Text(landmark.name)
                        .font(.title2)
                        .foregroundColor(Theme.textOnPrimary)
                    
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.textOnPrimary)
                            .imageScale(.large)
                    }
                }
                // Question
                Text(landmark.question)
                    .font(.headline)
                    .foregroundColor(Theme.textOnPrimary)
                
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
                    .foregroundColor(isCorrect ? Theme.success : Theme.warning)
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
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.textOnPrimary)
                        .foregroundColor(Theme.primary)
                        .cornerRadius(10)
                }
                .disabled(showFeedback && isCorrect) // Disable during "Continuing..." state
                Spacer()
            }
            .padding()
            .background(Theme.primary)
            .cornerRadius(20)
            
        }
        .padding()
        .frame(maxHeight: 100)
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

// Preview
#Preview {
    let landmark = Landmark(
        name: "Test Landmark",
        latitude: 47.3119,
        longitude: -122.1785,
        triggerRadius: 5,
        question: "What is the capital of France?",
        correctAnswer: "Paris"
    )
    
    return QuestionView(
        landmark: landmark,
        userAnswer: .constant(""),
        isPresented: .constant(true),
        keyboardFocus: .constant(false),
        onSubmit: { _ in }
    )
}
