//
//  Untitled.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 03/04/2026.
//
import SwiftUI
import MapKit

struct MapView: View {
    
    @StateObject private var locationManager = LocationManager()
    @State private var caches: [Cache] = []
    @State private var selectedCache: Cache? = nil
    @State private var showCacheDetail = false
    @State private var isLoading = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack(alignment: .top) {
            
            //  Map
            
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: caches) { cache in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: cache.cacheLatitude,
                    longitude: cache.cacheLongitude)) {
                    CachePinView(
                        cache: cache,
                        isSelected: selectedCache?.id == cache.id
                    )
                    .onTapGesture {
                        selectedCache = cache
                        showCacheDetail = true
                    }
                }
            }
            .ignoresSafeArea()
            
            //Top bar
            
            VStack {
                HStack {
                    Text("GeoQuest")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.gqLeafGreen)
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .tint(Color.gqLeafGreen)
                    } else {
                        Text("\(caches.count) caches")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.95))
                
                Spacer()
                
                //  Bottom buttons
                HStack {
                    Button {
                        centreOnUser()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.gqLeafGreen)
                            .frame(width: 48, height: 48)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                    
                    Spacer()
                    
                    Button {
                        loadCaches()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18))
                            .foregroundColor(Color.gqLeafGreen)
                            .frame(width: 48, height: 48)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showCacheDetail) {
            if let cache = selectedCache {
                CacheDetailView(cache: cache)
            }
        }
        .onAppear {
            loadCaches()
        }
        .onChange(of: locationManager.userLocation) { location in
            if let location = location {
                withAnimation {
                    region.center = location.coordinate
                }
            }
        }
    }
    
    //  Load caches
    private func loadCaches() {
        isLoading = true
        Task {
            do {
                caches = try await GeoQuestAPIManager.shared.getCaches()
            } catch {
                print("Error loading caches: \(error)")
            }
            isLoading = false
        }
    }
    
    //  Centre on user
    private func centreOnUser() {
        if let location = locationManager.userLocation {
            withAnimation {
                region.center = location.coordinate
            }
        }
    }
}

//  Cache pin
struct CachePinView: View {
    let cache: Cache
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.gqGoldReward : Color.gqCacheRed)
                    .frame(width: isSelected ? 44 : 36,
                           height: isSelected ? 44 : 36)
                
                Image(systemName: "mappin")
                    .font(.system(size: isSelected ? 20 : 16))
                    .foregroundColor(.white)
            }
            
            if isSelected {
                Text(cache.cacheName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.gqLeafGreen)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white)
                    .cornerRadius(6)
                    .shadow(radius: 1)
            }
        }
        .animation(.spring(), value: isSelected)
    }
}

//  Cache detail sheet

    
    struct CacheDetailView: View {
        let cache: Cache
        @Environment(\.dismiss) var dismiss
        @StateObject private var locationManager = LocationManager()
        
        @State private var isUnlocked = false
        @State private var showCamera = false
        @State private var capturedImage: UIImage? = nil
        @State private var isLogging = false
        @State private var logSuccess = false
        @State private var errorMessage = ""
        @State private var distance: Double? = nil
        
        // Unlock threshold in metres
        let unlockRadius: Double = 50
        
        var isNearCache: Bool {
            guard let distance = distance else { return false }
            return distance <= unlockRadius
        }
        
        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Distance indicator
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(isNearCache ? Color.gqLeafGreen : Color.gqCacheRed)
                            
                            if let distance = distance {
                                if distance < 1000 {
                                    Text("\(Int(distance))m away")
                                } else {
                                    Text(String(format: "%.1fkm away", distance / 1000))
                                }
                            } else {
                                Text("Calculating distance...")
                            }
                            
                            Spacer()
                            
                            // Status badge
                            Text(isNearCache ? "In range" : "Too far")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(isNearCache ? Color.gqLeafGreen : Color.gqCacheRed)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(isNearCache ? Color.gqLeafGreen.opacity(0.15) : Color.gqCacheRed.opacity(0.15))
                                .cornerRadius(20)
                        }
                        .padding()
                        .background(Color.gqLightStone)
                        .cornerRadius(12)
                        
                        // Points badge
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.gqGoldReward)
                            Text("\(cache.cachePoints) points")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color.gqGoldReward)
                            Spacer()
                        }
                        .padding()
                        .background(Color.gqLightStone)
                        .cornerRadius(12)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Description")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text(cache.cacheDescription)
                                .font(.system(size: 15))
                        }
                        .padding()
                        .background(Color.gqLightStone)
                        .cornerRadius(12)
                        
                        // Clue
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Clue")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text(cache.cacheClue)
                                .font(.system(size: 15))
                        }
                        .padding()
                        .background(Color.gqLightStone)
                        .cornerRadius(12)
                        
                        // Captured photo
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .cornerRadius(12)
                                .clipped()
                        }
                        
                        // Error message
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(Color.gqCacheRed)
                                .font(.system(size: 13))
                                .multilineTextAlignment(.center)
                        }
                        
                        // Success message
                        if logSuccess {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.gqLeafGreen)
                                Text("Cache found! Points added.")
                                    .foregroundColor(Color.gqLeafGreen)
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .padding()
                            .background(Color.gqLeafGreen.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Unlock / Camera / Log button
                        if logSuccess {
                            // Already logged
                            Button {
                                dismiss()
                            } label: {
                                Text("Close")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.gqLeafGreen)
                                    .cornerRadius(12)
                            }
                        } else if capturedImage != nil {
                            // Photo taken — log the find
                            Button {
                                logFind()
                            } label: {
                                ZStack {
                                    Text("Log Find")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                        .opacity(isLogging ? 0 : 1)
                                    if isLogging {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.gqLeafGreen)
                                .cornerRadius(12)
                            }
                            .disabled(isLogging)
                        } else {
                            // Unlock button — only active when nearby
                            Button {
                                showCamera = true
                            } label: {
                                HStack {
                                    Image(systemName: isNearCache ? "camera.fill" : "lock.fill")
                                    Text(isNearCache ? "Take Photo to Unlock" : "Get closer to unlock")
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(isNearCache ? Color.gqLeafGreen : Color.gray)
                                .cornerRadius(12)
                            }
                            .disabled(!isNearCache)
                        }
                    }
                    .padding()
                }
                .navigationTitle(cache.cacheName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                        .foregroundColor(Color.gqLeafGreen)
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(capturedImage: $capturedImage)
            }
            .onAppear {
                updateDistance()
            }
            .onReceive(locationManager.$userLocation) { _ in
                updateDistance()
            }
        }
        
        //  Calculate distance to cache
        private func updateDistance() {
            distance = locationManager.distanceTo(
                latitude: cache.cacheLatitude,
                longitude: cache.cacheLongitude
            )
        }
        
        //  Log find to API
        private func logFind() {
            isLogging = true
            errorMessage = ""
            
            let userID = UserDefaults.standard.integer(forKey: "loggedInUserID")
            
            Task {
                do {
                    // Get all players
                    let players = try await GeoQuestAPIManager.shared.getPlayers()
                    var player = players.first { $0.playerUserID == userID }
                    
                    // If not a player yet, auto join event 1 (Global Mode)
                    if player == nil {
                        let joinPayload = PlayerPayload(
                            playerUserID: userID,
                            playerEventID: 1
                        )
                        player = try await GeoQuestAPIManager.shared.joinEvent(payload: joinPayload)
                    }
                    
                    guard let playerID = player?.playerID else {
                        errorMessage = "Could not join event"
                        isLogging = false
                        return
                    }
                    
                    // Log the find
                    let payload = FindPayload(
                        findPlayerID: playerID,
                        findCacheID: cache.cacheID,
                        findDatetime: ISO8601DateFormatter().string(from: Date()),
                        findImageURL: "https://placehold.co/300x300/png"
                    )
                    
                    let _ = try await GeoQuestAPIManager.shared.logFind(payload: payload)
                    logSuccess = true
                    
                } catch {
                    errorMessage = "Failed: \(error.localizedDescription)"
                }
                isLogging = false
            }
        }
    }


#Preview {
    MapView()
}
