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
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 24) {
                Section() {
                    InputView(
                        text: $spot.landmarkName,
                        title: "Name",
                        placeholder: "Enter landmark name"
                    )
                }
                Section() {
                    InputView(
                        text: $spot.question,
                        title: "Question",
                        placeholder: "Type your question"
                    )
                }
                Section() {
                    InputView(
                        text: $spot.correctAnswer,
                        title: "Answer",
                        placeholder: "Correct answer"
                    )
                }
                HStack {
                    Text("Trigger Radius")
                        Picker("Trigger Radius", selection: $spot.triggerRadius) {
                            ForEach(0..<201) { value in  // 0–200 m
                                Text("\(value)m").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        .clipped()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .navigationTitle("Configure Landmark")
            .foregroundColor(Theme.textOnPrimary)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button{
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
                    .padding(.horizontal, 5)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background((spot.landmarkName.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    spot.question.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    spot.correctAnswer.trimmingCharacters(in: .whitespaces).isEmpty) ? Color.gray : Color.green)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                    }
                    .padding(.horizontal, 5)
                    // Disable until all fields are non-empty
                    .disabled(
                        spot.landmarkName.trimmingCharacters(in: .whitespaces).isEmpty ||
                        spot.question.trimmingCharacters(in: .whitespaces).isEmpty ||
                        spot.correctAnswer.trimmingCharacters(in: .whitespaces).isEmpty
                    )
                }
            }
            .background(Color(Theme.primary))
        }
        // Prevent swipe-to-dismiss when form is incomplete
        .interactiveDismissDisabled(
            spot.landmarkName.trimmingCharacters(in: .whitespaces).isEmpty ||
            spot.question.trimmingCharacters(in: .whitespaces).isEmpty ||
            spot.correctAnswer.trimmingCharacters(in: .whitespaces).isEmpty
        )
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
            onCancel: { print("Cancelled") }
        )
        .environment(
            \.colorScheme, .dark
        )
    }
}
