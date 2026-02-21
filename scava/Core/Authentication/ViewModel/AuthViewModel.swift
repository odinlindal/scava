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
        // Set up Firebase Auth state listener
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                print("🔄 Auth state changed - User: \(user?.uid ?? "nil")")
                self?.userSession = user
                if user != nil {
                    print("👤 User session detected, fetching user data...")
                    Task {
                        await self?.fetchUser()
                    }
                } else {
                    print("🚪 No user session, clearing current user")
                    self?.currentUser = nil
                }
            }
        }
    }
    
    func signIn(withEmail email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            // userSession will be updated automatically by the auth state listener
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            // userSession will be updated automatically by the auth state listener
            let user = User(id: result.user.uid, fullname: fullname, email: email, devUser: true)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            // userSession and currentUser will be cleared automatically by the auth state listener
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

            // userSession and currentUser will be cleared automatically by the auth state listener
            print("Account deleted for \(uid)")
        } catch {
            // This will most likely fail if the user needs to reauthenticate
            print("Failed to delete account:", error.localizedDescription)
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { 
            print("❌ No current user UID found")
            return 
        }
        
        print("🔍 Fetching user data for UID: \(uid)")
        
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            
            if snapshot.exists {
                self.currentUser = try snapshot.data(as: User.self)
                print("✅ Successfully loaded user: \(self.currentUser?.fullname ?? "Unknown")")
            } else {
                print("❌ User document does not exist in Firestore")
                self.currentUser = nil
            }
        } catch {
            print("❌ Error fetching user: \(error.localizedDescription)")
            self.currentUser = nil
        }
    }
}
