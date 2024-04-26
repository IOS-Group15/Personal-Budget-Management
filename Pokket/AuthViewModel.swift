//
//  AuthViewModel.swift
//  Pokket
//
//  Created by Fredy Camas on 4/23/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@Observable // <-- Make class observable
class AuthViewModel {

    // A property to store the logged in user. User is an object provided by FirebaseAuth framework
    var user: User?

    // Determines if AuthManager should use mocked data
    let isMocked: Bool

    var userEmail: String? {

        // If mocked, return a mocked email string, otherwise return the users email if available
        isMocked ? "pakket@gmail.com" : user?.email
    }

    init(isMocked: Bool = false) {

       self.isMocked = isMocked

       // TODO: Check for cached user for persisted login
    }
    

    // https://firebase.google.com/docs/auth/ios/start#sign_up_new_users
    func signUp(name: String, email: String, password: String) async throws {
        let userReference = Firestore.firestore().collection("Users")
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        try await userReference.document(result.user.uid).setData(["name": name, "email": email])
    }

    // https://firebase.google.com/docs/auth/ios/start#sign_in_existing_users
    func signIn(email: String, password: String) {
        Task {
            do {
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                user = authResult.user // <-- Set the user
            } catch {
                print(error)
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil // <-- Set user to nil after sign out
        } catch {
            print(error)
        }
    }
}

