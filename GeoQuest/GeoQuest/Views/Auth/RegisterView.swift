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
                    
                    // Register button
                    Button {
                        // Need to add register login
                    } label: {
                        Text("Create Account")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.gqLeafGreen)
                            .cornerRadius(12)
                    }
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
