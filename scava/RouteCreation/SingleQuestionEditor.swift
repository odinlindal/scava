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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Landmark") {
                    TextField("Name", text: $spot.landmarkName)
                }
                Section("Quiz") {
                    TextField("Question", text: $spot.question)
                    TextField("Answer", text: $spot.correctAnswer)
                }
            }
            .navigationTitle("Configure Landmark")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    // Disable until all fields are non-empty
                    .disabled(
                        spot.landmarkName.trimmingCharacters(in: .whitespaces).isEmpty ||
                        spot.question.trimmingCharacters(in: .whitespaces).isEmpty ||
                        spot.correctAnswer.trimmingCharacters(in: .whitespaces).isEmpty
                    )
                }
            }
        }
        // Prevent swipe-to-dismiss when form is incomplete
        .interactiveDismissDisabled(
            spot.landmarkName.trimmingCharacters(in: .whitespaces).isEmpty ||
            spot.question.trimmingCharacters(in: .whitespaces).isEmpty ||
            spot.correctAnswer.trimmingCharacters(in: .whitespaces).isEmpty
        )
    }
}

#Preview {
    let draft = RouteSpotDraft(
        coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
    )
    SingleQuestionEditor(spot: .constant(draft))
}
