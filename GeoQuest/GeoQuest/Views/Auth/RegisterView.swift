//
//  RegisterView.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 02/04/2026.
//

import SwiftUI

struct RegisterView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var phone = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var registrationSuccess = false
    
    let api = GeoQuestAPIManager.shared
    
    var body: some View {
        ZStack {
            
            Color.gqLightStone
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Title
                    VStack(spacing: 6) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.gqLeafGreen)
                        
                        Text("Join the hunt")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 14) {
                        
                        GQTextField(
                            icon: "person",
                            placeholder: "First name",
                            text: $firstname
                        )
                        
                        GQTextField(
                            icon: "person",
                            placeholder: "Last name",
                            text: $lastname
                        )
                        
                        GQTextField(
                            icon: "phone",
                            placeholder: "Phone number",
                            text: $phone
                        )
                        .keyboardType(.phonePad)
                        
                        GQTextField(
                            icon: "at",
                            placeholder: "Username",
                            text: $username
                        )
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        
                        GQSecureField(
                            icon: "lock",
                            placeholder: "Password",
                            text: $password
                        )
                        
                        GQSecureField(
                            icon: "lock.fill",
                            placeholder: "Confirm password",
                            text: $confirmPassword
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Error message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 13))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    // Success message
                    if registrationSuccess {
                        Text("Account created! You can now log in.")
                            .foregroundColor(Color.gqLeafGreen)
                            .font(.system(size: 13))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    // Register button
                    Button {
                        Task { await handleRegister() }
                    } label: {
                        ZStack {
                            Text("Create Account")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .opacity(isLoading ? 0 : 1)
                            
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.gqLeafGreen)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)
                    
                    // Back button to login page
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.secondary)
                            Text("Login")
                                .foregroundColor(Color.gqLeafGreen)
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 15))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color.gqLeafGreen)
                }
            }
        }
    }
    
    // Register logic
    func handleRegister() async {
        errorMessage = ""
        registrationSuccess = false
        
        // Check all fields filled
        guard !firstname.isEmpty, !lastname.isEmpty,
              !phone.isEmpty, !username.isEmpty,
              !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        // Check passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        // Check password length
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        isLoading = true
        
        do {
            // Check username not already taken
            let existingUser = try await api.getUserByUsername(username)
            if existingUser != nil {
                errorMessage = "That username is already taken"
                isLoading = false
                return
            }
            
            // Build the payload
            let payload = UserPayload(
                userFirstname: firstname,
                userLastname: lastname,
                userPhone: phone,
                userUsername: username,
                userPassword: password,
                userLatitude: 0.0,
                userLongitude: 0.0,
                userTimestamp: Date().timeIntervalSince1970,
                userImageURL: "https://placehold.co/300x300/png"
            )
            
            // POST to API
            let newUser = try await api.createUser(payload: payload)
            
            // Save to UserDefaults so they're logged in straight away
            UserDefaults.standard.set(newUser.userID, forKey: "loggedInUserID")
            UserDefaults.standard.set(newUser.userUsername, forKey: "loggedInUsername")
            
            registrationSuccess = true
            
            // Go back to login after a short delay
            try await Task.sleep(nanoseconds: 1_500_000_000)
            dismiss()
            
        } catch {
            errorMessage = "Registration failed. Please try again."
        }
        
        isLoading = false
    }
}

// Text field that can be reusable
struct GQTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.gqSand)
                .frame(width: 20)
            TextField(placeholder, text: $text)
                .foregroundColor(Color.gqLeafGreen)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gqSand.opacity(0.4), lineWidth: 1)
        )
    }
}

// Secure text (passwords) field that can be reusable
struct GQSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.gqSand)
                .frame(width: 20)
            SecureField(placeholder, text: $text)
                .foregroundColor(Color.gqLeafGreen)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gqSand.opacity(0.4), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
