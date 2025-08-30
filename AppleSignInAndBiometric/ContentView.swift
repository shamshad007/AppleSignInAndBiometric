//
//  ContentView.swift
//  AppleSignInAndBiometric
//
//  Created by Md Shamshad Akhtar on 30/08/25.
//

import SwiftUI
import AuthenticationServices // for apple login service
import LocalAuthentication // for biometric authentication

struct ContentView: View {
    // State variable to track whether the user is authenticated
    @State private var isAuthenticated = false
    // State variables to handle error messages for authentication failures
    @State private var showError = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 30) {
            if isAuthenticated {
                // Display a welcome message if the user is authenticated
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .padding()
            } else {
                // Apple Sign-In Button
                SignInWithAppleButton(.signIn) { request in
                    // Configure the request for Apple Sign-In, requesting the user's full name and email
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    // Handle the result of the Apple Sign-In process
                    handleAppleSignIn(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .padding()
                
                // Biometric Authentication Button
                Button(action: authenticateWithBiometrics) {
                    Text("Sign in with Face ID / Touch ID")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .alert(isPresented: $showError) {
            // Show an alert if authentication fails
            Alert(title: Text("Authentication Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
        .padding()
    }
    
    // Handle the result of Apple Sign-In
    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let _ = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Mark the user as authenticated if the Apple Sign-In credential is valid
                isAuthenticated = true
            }
        case .failure(let error):
            // Capture and display any errors from Apple Sign-In
            errorMessage = error.localizedDescription
            showError = true
            print("apple sign in failed: \(error.localizedDescription)")
        }
    }
    
    // Perform biometric authentication
    func authenticateWithBiometrics() {
        let context = LAContext() // Context object for evaluating biometric policies
        var error: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Face ID or Touch ID"
            // Attempt biometric authentication
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        // If successful, mark the user as authenticated
                        isAuthenticated = true
                    } else {
                        // Show an error if biometric authentication fails
                        errorMessage = error?.localizedDescription ?? "Biometric authentication failed"
                        showError = true
                    }
                }
            }
        } else {
            // Show an error if biometric authentication is not available
            errorMessage = error?.localizedDescription ?? "Biometrics not available"
            showError = true
        }
    }
}

#Preview {
    ContentView()
}
