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
    @Binding var allSpots: [RouteSpotDraft]
    let isExisting: Bool
    var onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var deleteAlert: Bool
    @State private var draftName: String
    @State private var draftQuestion: String
    @State private var draftAnswer: String
    @State private var draftRadius: Int
    @State private var showRepositionMap = false
    
    init(spot: Binding<RouteSpotDraft>,
         allSpots: Binding<[RouteSpotDraft]>,
         isExisting: Bool,
         onCancel: @escaping () -> Void)
    {
        self._spot = spot
        self._allSpots   = allSpots
        self.isExisting = isExisting
        self.onCancel = onCancel
        self.deleteAlert = false
        // now self.spot is available, so we can pull out its values
        let current = spot.wrappedValue
        _draftName     = State(initialValue: current.landmarkName)
        _draftQuestion = State(initialValue: current.question)
        _draftAnswer   = State(initialValue: current.correctAnswer)
        _draftRadius   = State(initialValue: current.triggerRadius)
    }
    
    // MARK: - Completion check
    private var isComplete: Bool {
        !draftName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draftQuestion.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draftAnswer.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // — Custom header —
                ZStack {
                    HStack {
                        Button {
                            if(!isExisting) { onCancel() }
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
                    
                    Text(isExisting ? "Edit Landmark" : "New Landmark")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textOnPrimary)
                }
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                
                // — Input fields —
                InputView(
                    text: $draftName,
                    title: "Name",
                    placeholder: "Enter landmark name"
                )
                
                InputView(
                    text: $draftQuestion,
                    title: "Question",
                    placeholder: "Type your question"
                )
                
                InputView(
                    text: $draftAnswer,
                    title: "Answer",
                    placeholder: "Correct answer"
                )
                
                // — Radius picker —
                HStack {
                    Text("Trigger Radius")
                        .foregroundColor(Theme.textOnPrimary)
                    
                    Spacer()
                    
                    Picker("Trigger Radius", selection: $draftRadius) {
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
                    spot.landmarkName = draftName
                    spot.question = draftQuestion
                    spot.correctAnswer = draftAnswer
                    spot.triggerRadius = draftRadius
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.subheadline)
                        .foregroundColor(Theme.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(isComplete ? Theme.success : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!isComplete)
                if(isExisting){
                    Button {
                        showRepositionMap = true
                    } label: {
                        Text("Reposition landmark")
                            .font(.subheadline)
                            .foregroundColor(Theme.textOnPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Theme.secondary)
                            .cornerRadius(8)
                    }
                }
                Button {
                    deleteAlert = true
                } label: {
                    Text("Delete landmark")
                        .font(.subheadline)
                        .foregroundColor(Theme.error)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.textOnPrimary)
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16)
            .padding(.bottom, 50)
            .background(Color(Theme.primaryLight).ignoresSafeArea())
            }
            .alert("Delete Landmark", isPresented: $deleteAlert) {
                Button("Yes") {
                    onCancel()
                    dismiss()
                }
                Button("No", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this landmark?")
            }
            // hide the default nav bar
            .toolbar(.hidden, for: .navigationBar)
            // Prevent dismiss-swipe when incomplete
            .interactiveDismissDisabled(!isComplete)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .fullScreenCover(isPresented: $showRepositionMap) {
                  RepositionMapView(
                    spot: $spot,
                    otherSpots: allSpots.filter { $0.id != spot.id }
                  )
            }
    }
}
