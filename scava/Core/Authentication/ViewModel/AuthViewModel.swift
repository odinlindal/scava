//
//  AuthViewModel.swift
//  scava
//
//  Created by Odin Lindal on 4/26/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormProtocol {
    var formIsVaild: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var errorMessage: String?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Failed to sign out with error: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
                    print("⚠️ No user to delete")
                    return
                }

                let uid = user.uid
                let db = Firestore.firestore()

                do {
                    // Remove their Firestore profile
                    try await db.collection("users").document(uid).delete()

                    // Delete the Auth account itself
                    try await user.delete()

                    // Clear local state
                    self.userSession = nil
                    self.currentUser = nil

                    print("Account deleted for \(uid)")
                }
                catch {
                    // This will most likely fail if the user needs to reauthenticate
                    print("Failed to delete account:", error.localizedDescription)
                }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else {return}
        self.currentUser = try? snapshot.data(as: User.self)
        
        print("Current user is: \(String(describing: currentUser))")
    }
}
