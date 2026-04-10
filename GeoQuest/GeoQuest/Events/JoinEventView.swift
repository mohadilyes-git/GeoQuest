import SwiftUI

struct JoinEventView: View {
    
    @State private var inviteCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    let api = GeoQuestAPIManager.shared
    let loggedInUserID = UserDefaults.standard.integer(forKey: "loggedInUserID")
    
    var body: some View {
        ZStack {
            Color.gqLightStone
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                // Icon and title
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color.gqLeafGreen)
                    
                    Text("Join an Event")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Enter the invite code from the event organiser")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 40)
                
                // Invite code input
                VStack(spacing: 8) {
                    TextField("Enter invite code", text: $inviteCode)
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                        .autocapitalization(.allCharacters)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gqSand.opacity(0.4), lineWidth: 1)
                        )
                        .onChange(of: inviteCode) {
                            if inviteCode.count > 6 {
                                inviteCode = String(inviteCode.prefix(6))
                            }
                            inviteCode = inviteCode.uppercased()
                        }
                    
                    Text("\(inviteCode.count)/6 characters")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
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
                if !successMessage.isEmpty {
                    Text(successMessage)
                        .foregroundColor(Color.gqLeafGreen)
                        .font(.system(size: 13))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                // Join button
                Button {
                    Task { await handleJoin() }
                } label: {
                    ZStack {
                        Text("Join Event")
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
                .disabled(isLoading || inviteCode.count != 6)
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .navigationTitle("Join Event")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Join event logic
    func handleJoin() async {
        isLoading = true
        errorMessage = ""
        successMessage = ""
        
        do {
            // Fetch all events
            let allEvents = try await api.getEvents()
            
            // Look through each event for a matching invite code
            var matchedEventID: Int? = nil
            var matchedEventName = ""
            
            for event in allEvents {
                // Check if the description contains an invite code
                if event.eventDescription.contains(inviteCode) {
                    matchedEventID = event.eventID
                    matchedEventName = event.eventName
                    break
                }
            }
            
            // No event found with that code
            if matchedEventID == nil {
                errorMessage = "No event found with that invite code. Please check and try again."
                isLoading = false
                return
            }
            
            // Join the event as a player
            let payload = PlayerPayload(
                playerUserID: loggedInUserID,
                playerEventID: matchedEventID!
            )
            
            let _ = try await api.joinEvent(payload: payload)
            
            successMessage = "You joined \(matchedEventName)! Head to the map to find caches."
            inviteCode = ""
            
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
        
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        JoinEventView()
    }
}
