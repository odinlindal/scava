import SwiftUI

struct QuestionView: View {
    let landmark: Landmark
    @Binding var userAnswer: String
    @Binding var isPresented: Bool
    @Binding var keyboardFocus: Bool
    let onSubmit: (String) -> Void
    let onGiveUp: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    @State private var showFeedbackAlert = false
    @State private var showGiveUpAlert = false
    @State private var isCorrect = false
    @State private var hasAttempted = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Custom header matching RouteMetaDataScreen style
                ZStack {
                    Text(landmark.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textOnPrimary)
                }
                .padding(.top, 16)
                .frame(maxWidth: .infinity, alignment: .center)
                
                // Question section
                VStack(alignment: .leading, spacing: 24) {
                    Text("Question:")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textOnPrimary)
                    Text(landmark.question)
                        .font(.title2)
                        .foregroundColor(Theme.textOnPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Spacer()
                
                // Answer section
                VStack(spacing: 24) {
                    TextField("Your answer", text: $userAnswer)
                        .font(.title3)
                        .focused($isTextFieldFocused)
                        .foregroundColor(Theme.primary)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(10)
                        .onChange(of: isTextFieldFocused) { _, newValue in
                            keyboardFocus = newValue
                        }
                    
                    let canSubmit = !userAnswer
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
                    
                    Button(action: {
                        // Check answer locally first
                        isCorrect = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
                            landmark.correctAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        showFeedbackAlert = true
                        
                        // Only handle correct answer submission here
                        if isCorrect {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                onSubmit(userAnswer)
                            }
                        } else {
                            hasAttempted = true
                        }
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.textOnPrimary)
                            .foregroundColor(Theme.primary)
                            .cornerRadius(10)
                    }
                    .disabled(!canSubmit)
                    .opacity(canSubmit ? 1.0 : 0.5)
                    
                    if hasAttempted {
                        Button(action: {
                            showGiveUpAlert = true
                        }) {
                            Text("Give Up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.error.opacity(0.8))
                                .foregroundColor(Theme.textOnPrimary)
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Theme.primary)
            .toolbar(.hidden, for: .navigationBar)
            .alert(isCorrect ? "Correct!" : "Try Again", isPresented: $showFeedbackAlert) {
                if isCorrect {
                    Button("Continue") {
                        // The onSubmit closure will handle dismissing the view
                    }
                } else {
                    Button("OK", role: .cancel) {
                        // Just refocus the keyboard, don't clear the text
                        isTextFieldFocused = true
                    }
                }
            } message: {
                Text(isCorrect ? "Great job! Now find the next landmark..." : "That's not quite right. Try again!")
            }
            .alert("Give Up?", isPresented: $showGiveUpAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Give Up", role: .destructive) {
                    onGiveUp()
                    isPresented = false
                }
            } message: {
                Text("Are you sure you want to skip this landmark?")
            }
            .onChange(of: showFeedbackAlert) { _, isShowing in
                // When alert is dismissed, ensure keyboard is focused
                if !isShowing && !isCorrect {
                    isTextFieldFocused = true
                }
            }
        }
        .onAppear {
            // Focus the text field when the view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
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
// 1. A wrapper that holds mutable state
private struct QuestionView_PreviewWrapper: View {
    @State private var userAnswer = ""
    @State private var isPresented = true
    @State private var keyboardFocus = false

    var body: some View {
        NavigationStack {
            QuestionView(
                landmark: Landmark(
                    name: "Test Landmark",
                    latitude: 47.3119,
                    longitude: -122.1785,
                    triggerRadius: 5,
                    question: "What is the capital of France?",
                    correctAnswer: "Paris"
                ),
                userAnswer: $userAnswer,          // <- real binding
                isPresented: $isPresented,
                keyboardFocus: $keyboardFocus,
                onSubmit: { answer in
                    print("Submitted answer:", answer)
                    isPresented = false
                },
                onGiveUp: {
                    print("Gave up on landmark")
                }
            )
        }
    }
}

// 2. The actual SwiftUI preview entrypoint
#Preview {
    QuestionView_PreviewWrapper()
}
