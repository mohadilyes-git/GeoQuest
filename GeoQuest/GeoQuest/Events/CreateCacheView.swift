import SwiftUI
import CoreLocation

struct CreateCacheView: View {
    
    let event: Event
    let onSuccess: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()
    
    @State private var cacheName = ""
    @State private var cacheDescription = ""
    @State private var cacheClue = ""
    @State private var cachePoints = "10"
    @State private var cacheImageURL = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var cacheCreated = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gqLightStone.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        if cacheCreated {
                            VStack(spacing: 16) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color.gqLeafGreen)
                                Text("Cache Created!")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color.gqLeafGreen)
                                Text("The cache has been added to the map")
                                    .foregroundColor(.secondary)
                                Button("Done") {
                                    onSuccess()
                                    dismiss()
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.gqLeafGreen)
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 40)
                            
                        } else {
                            
                            // Location info
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(Color.gqLeafGreen)
                                if locationManager.userLocation != nil {
                                    Text("Cache will be placed at your current location")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Getting your location...")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            
                            // Form fields
                            VStack(spacing: 14) {
                                
                                GQTextField(
                                    icon: "mappin",
                                    placeholder: "Cache name",
                                    text: $cacheName
                                )
                                
                                GQTextField(
                                    icon: "text.alignleft",
                                    placeholder: "Description",
                                    text: $cacheDescription
                                )
                                
                                GQTextField(
                                    icon: "questionmark.circle",
                                    placeholder: "Clue",
                                    text: $cacheClue
                                )
                                
                                GQTextField(
                                    icon: "star",
                                    placeholder: "Points (e.g. 10)",
                                    text: $cachePoints
                                )
                                .keyboardType(.numberPad)
                                
                                GQTextField(
                                    icon: "photo",
                                    placeholder: "Image URL",
                                    text: $cacheImageURL
                                )
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                            }
                            .padding(.horizontal, 16)
                            
                            // Error message
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(Color.gqCacheRed)
                                    .font(.system(size: 13))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                            }
                            
                            // Add cache button
                            Button {
                                Task { await createCache() }
                            } label: {
                                ZStack {
                                    Text("Add Cache to Map")
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
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Add Cache")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.gqLeafGreen)
                }
            }
        }
    }
    
    func createCache() async {
        errorMessage = ""
        
        // Check each field individually and tell the user exactly what is missing
        if cacheName.isEmpty {
            errorMessage = "Please enter a cache name"
            return
        }
        
        if cacheDescription.isEmpty {
            errorMessage = "Please enter a description"
            return
        }
        
        if cacheClue.isEmpty {
            errorMessage = "Please enter a clue"
            return
        }
        
        if cachePoints.isEmpty {
            errorMessage = "Please enter a points value"
            return
        }
        
        if cacheImageURL.isEmpty {
            errorMessage = "Please enter an image URL"
            return
        }
        
        guard let points = Int(cachePoints), points > 0 else {
            errorMessage = "Points must be a valid number greater than 0"
            return
        }
        
        guard let location = locationManager.userLocation else {
            errorMessage = "Could not get your location. Make sure location is enabled."
            return
        }
        
        isLoading = true
        
        let payload = CachePayload(
            cacheName: cacheName,
            cacheDescription: cacheDescription,
            cacheEventID: event.eventID,
            cacheImageURL: cacheImageURL,
            cacheClue: cacheClue,
            cachePoints: points,
            cacheLatitude: location.coordinate.latitude,
            cacheLongitude: location.coordinate.longitude
        )
        
        do {
            let _ = try await GeoQuestAPIManager.shared.createCache(payload: payload)
            cacheCreated = true
        } catch {
            errorMessage = "Failed to create cache. Please try again."
        }
        
        isLoading = false
    }
}

#Preview {
    CreateCacheView(event: Event(
        eventID: 1,
        eventName: "Test",
        eventDescription: "Test",
        eventOwnerID: 1,
        eventIspublic: false,
        eventStart: "2026-04-09T12:00:00.000Z",
        eventFinish: "2026-04-09T13:00:00.000Z",
        eventStatusID: 1,
        eventOwner: nil,
        eventStatus: nil
    ), onSuccess: {})
}
