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
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstname, lastname, phone, username, password, confirmPassword
    }
    
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
                            .foregroundColor(Color(.label).opacity(0.5))
                    }
                    .padding(.top, 5)
                    
                    // Form
                    VStack(spacing: 14) {
                        
                        GQTextField(
                            icon: "person",
                            placeholder: "First name",
                            text: $firstname,
                            onSubmit: { focusedField = .lastname }
                        )
                        .focused($focusedField, equals: .firstname)
                        
                        GQTextField(
                            icon: "person",
                            placeholder: "Last name",
                            text: $lastname,
                            onSubmit: { focusedField = .phone }
                        )
                        .focused($focusedField, equals: .lastname)
                        
                        GQTextField(
                            icon: "phone",
                            placeholder: "Phone number",
                            text: $phone,
                            onSubmit: { focusedField = .username }
                        )
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .phone)
                        .onChange(of: phone) {
                            phone = phone.filter { $0.isNumber }
                        }
                        
                        GQTextField(
                            icon: "at",
                            placeholder: "Username",
                            text: $username,
                            onSubmit: { focusedField = .password }
                        )
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .username)
                        
                        GQSecureField(
                            icon: "lock",
                            placeholder: "Password",
                            text: $password,
                            onSubmit: { focusedField = .confirmPassword }
                        )
                        .focused($focusedField, equals: .password)
                        
                        GQSecureField(
                            icon: "lock.fill",
                            placeholder: "Confirm password",
                            text: $confirmPassword,
                            submit: .go,
                            onSubmit: {
                                focusedField = nil
                                Task { await handleRegister() }
                            }
                        )
                        .focused($focusedField, equals: .confirmPassword)
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
                    
                    // Register button with spinner
                    Button {
                        focusedField = nil
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
                                .foregroundColor(Color(.label).opacity(0.5))
                            Text("Login")
                                .foregroundColor(Color.gqLeafGreen)
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 15))
                    }
                    .padding(.bottom, 40)
                }
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
        
        guard !firstname.isEmpty, !lastname.isEmpty,
              !phone.isEmpty, !username.isEmpty,
              !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard username.count >= 8 else {
            errorMessage = "Username must be at least 8 characters"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        
        isLoading = true
        
        do {
            let existingUser = try await api.getUserByUsername(username)
            if existingUser != nil {
                errorMessage = "That username is already taken"
                isLoading = false
                return
            }
            
            let payload = UserPayload(
                userFirstname: firstname,
                userLastname: lastname,
                userPhone: phone,
                userUsername: username,
                userPassword: password,
                userLatitude: 0.0,
                userLongitude: 0.0,
                userTimestamp: Date().timeIntervalSince1970,
                userImageURL: "https://static.generated.photos/vue-static/face-generator/landing/wall/\(Int.random(in: 1...24)).jpg"
            )
            
            let newUser = try await api.createUser(payload: payload)
            
            UserDefaults.standard.set(newUser.userID, forKey: "loggedInUserID")
            UserDefaults.standard.set(newUser.userUsername, forKey: "loggedInUsername")
            
            registrationSuccess = true
            
            try await Task.sleep(for: .seconds(1.5))
            dismiss()
            
        } catch {
            errorMessage = "Error: \(error)"
        }
        
        isLoading = false
    }
}

// Text field that can be reusable
struct GQTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var submit: SubmitLabel = .next
    var onSubmit: () -> Void = {}
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.gqSand)
                .frame(width: 20)
            TextField(placeholder, text: $text)
                .foregroundColor(Color.primary)
                .submitLabel(submit)
                .onSubmit(onSubmit)
        }
        .padding()
        .background(Color(.systemBackground))
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
    var submit: SubmitLabel = .next
    var onSubmit: () -> Void = {}
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.gqSand)
                .frame(width: 20)
            SecureField(placeholder, text: $text)
                .foregroundColor(Color.primary)
                .submitLabel(submit)
                .onSubmit(onSubmit)
        }
        .padding()
        .background(Color(.systemBackground))
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
