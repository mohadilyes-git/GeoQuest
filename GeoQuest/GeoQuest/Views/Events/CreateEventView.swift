//
//  CreateEventView.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 09/04/2026.
//

import SwiftUI

import SwiftUI

struct CreateEventView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var eventName = ""
    @State private var eventDescription = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var inviteCode = ""
    @State private var eventCreated = false
    
    let onSuccess: () -> Void
    let api = GeoQuestAPIManager.shared
    let loggedInUserID = UserDefaults.standard.integer(forKey: "loggedInUserID")
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gqLightStone.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        if eventCreated {
                            // Success screen
                            VStack(spacing: 20) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color.gqLeafGreen)
                                
                                Text("Event Created!")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color.gqLeafGreen)
                                
                                Text("Share this invite code with participants:")
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                // Invite code display
                                Text(inviteCode)
                                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.gqLeafGreen)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                
                                // Share button
                                ShareLink(item: "Join my GeoQuest event with code: \(inviteCode)") {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share Invite Code")
                                    }
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.gqLeafGreen)
                                    .cornerRadius(12)
                                }
                                
                                Button("Done") {
                                    onSuccess()
                                    dismiss()
                                }
                                .foregroundColor(Color.gqLeafGreen)
                            }
                            .padding(24)
                            
                        } else {
                            // Create event form
                            VStack(spacing: 14) {
                                
                                GQTextField(
                                    icon: "pencil",
                                    placeholder: "Event name",
                                    text: $eventName
                                )
                                
                                GQTextField(
                                    icon: "text.alignleft",
                                    placeholder: "Description",
                                    text: $eventDescription
                                )
                                
                                // Start date
                                VStack(alignment: .leading, spacing: 6) {
                                    
                                    DatePicker("Start date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                                        .tint(Color.gqLeafGreen)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                
                                
                                // End date
                                VStack(alignment: .leading, spacing: 6) {
                                    
                                    DatePicker("End date", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                                        .tint(Color.gqLeafGreen)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(Color.gqCacheRed)
                                    .font(.system(size: 13))
                                    .padding(.horizontal, 16)
                            }
                            
                            // Create button
                            Button {
                                Task { await createEvent() }
                            } label: {
                                ZStack {
                                    Text("Create Event")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                        .opacity(isLoading ? 0 : 1)
                                    if isLoading {
                                        ProgressView().tint(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.gqLeafGreen)
                                .cornerRadius(12)
                            }
                            .disabled(isLoading)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.gqLeafGreen)
                }
            }
        }
    }
    
    // Generate random 6 character invite code
    func generateInviteCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
    
    func formatDateForAPI(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }
    // Create event
    func createEvent() async {
        guard !eventName.isEmpty else {
            errorMessage = "Please enter an event name"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        let code = generateInviteCode()
        inviteCode = code
        
        
        
        
        // Store invite code in description as JSON
        let descriptionJSON = """
        {"text":"\(eventDescription)","inviteCode":"\(code)","createdVia":"GeoQuest App"}
        """
        
        let payload = EventPayload(
            eventName: eventName,
            eventDescription: descriptionJSON,
            eventOwnerID: loggedInUserID,
            eventIspublic: false,
            eventStart: formatDateForAPI(startDate),
            eventFinish: formatDateForAPI(endDate),
            eventStatusID: 1
        )
        
        do {
            let event = try await api.createEvent(payload: payload)
            
            // Auto join as player
            let playerPayload = PlayerPayload(
                playerUserID: loggedInUserID,
                playerEventID: event.eventID
            )
            let _ = try await api.joinEvent(payload: playerPayload)
            
            eventCreated = true
            
        } catch {
            errorMessage = "Failed: \(error)"
                print("Full error: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    CreateEventView(onSuccess: {})
}
