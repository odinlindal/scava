//
//  SingleQuestionEditor.swift
//  scava
//
//  Created by Odin Lindal on 4/27/25.
//

import SwiftUI
import CoreLocation

struct SingleQuestionEditor: View {
    @Binding var spot: RouteSpotDraft
    var onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Completion check
    private var isComplete: Bool {
        !spot.landmarkName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !spot.question.trimmingCharacters(in: .whitespaces).isEmpty &&
        !spot.correctAnswer.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // — Custom header —
                ZStack {
                    HStack {
                        Button {
                            onCancel()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Theme.primary)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        Spacer()
                    }
                    
                    Text("New Landmark")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textOnPrimary)
                }
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                
                // — Input fields —
                InputView(
                    text: $spot.landmarkName,
                    title: "Name",
                    placeholder: "Enter landmark name"
                )
                
                InputView(
                    text: $spot.question,
                    title: "Question",
                    placeholder: "Type your question"
                )
                
                InputView(
                    text: $spot.correctAnswer,
                    title: "Answer",
                    placeholder: "Correct answer"
                )
                
                // — Radius picker —
                HStack {
                    Text("Trigger Radius")
                        .foregroundColor(Theme.textOnPrimary)
                    
                    Spacer()
                    
                    Picker("Trigger Radius", selection: $spot.triggerRadius) {
                        ForEach(0..<201, id: \.self) { value in
                            Text("\(value)m").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .clipped()
                }
                .padding(.horizontal, 16)
                
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Next")
                        .font(.subheadline)
                        .foregroundColor(Theme.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isComplete ? Theme.success : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!isComplete)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16)
            .padding(.bottom, 50)
            .background(Color(Theme.primaryLight).ignoresSafeArea())
            
            // — Confirmation button in toolbar —
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Next")
                            .font(.subheadline)
                            .foregroundColor(Theme.textOnPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isComplete ? Theme.success : Color.gray)
                            .cornerRadius(8)
                    }
                    .disabled(!isComplete)
                }
            }
            // hide the default nav bar
            .toolbar(.hidden, for: .navigationBar)
        }
        // Prevent dismiss-swipe when incomplete
        .interactiveDismissDisabled(!isComplete)
    }
}

struct SingleQuestionEditor_Previews: PreviewProvider {
    static var previews: some View {
        let draft = RouteSpotDraft(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            landmarkName: "Golden Gate",
            question: "What color is it?",
            correctAnswer: "Orange",
            triggerRadius: 50
        )
        return SingleQuestionEditor(
            spot: .constant(draft),
            onCancel: { /* simulate cancel */ }
        )
        .environment(\.colorScheme, .dark)
    }
}
