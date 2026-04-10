//
//  EventMapView.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 10/04/2026.
//

import SwiftUI
import MapKit

struct EventMapView: View {
    
    let event: Event
    
    @StateObject private var locationManager = LocationManager()
    @State private var caches: [Cache] = []
    @State private var selectedCache: Cache? = nil
    @State private var showCacheDetail = false
    @State private var isLoading = false
    @State private var showCreateCache = false
    @State private var foundCacheIDs: Set<Int> = []
    @State private var hasSetInitialLocation = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    let loggedInUserID = UserDefaults.standard.integer(forKey: "loggedInUserID")
    
    var body: some View {
        ZStack(alignment: .top) {
            
            //  - Map
            Map(coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: caches) { cache in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: cache.cacheLatitude,
                    longitude: cache.cacheLongitude)) {
                    CachePinView(
                        cache: cache,
                        isSelected: selectedCache?.id == cache.id,
                        isFound: foundCacheIDs.contains(cache.cacheID)
                    )
                    .onTapGesture {
                        selectedCache = cache
                        showCacheDetail = true
                    }
                }
            }
            .ignoresSafeArea()
            
            //  Top bar
            VStack {
                HStack {
                    Text(event.eventName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.black)
                    
                    Spacer()
                    
                    // Add cache button / only for event owner
                    if event.eventOwnerID == loggedInUserID {
                        Button {
                            showCreateCache = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color.gqLeafGreen)
                        }
                    }
                    
                    if isLoading {
                        ProgressView()
                            .tint(Color.gqLeafGreen)
                            .padding(.leading, 8)
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
                CacheDetailView(
                    cache: cache,
                    isAlreadyFound: foundCacheIDs.contains(cache.cacheID)
                )
            }
        }
        .sheet(isPresented: $showCreateCache) {
            CreateCacheView(event: event) {
                loadCaches()
            }
        }
        .onAppear {
            loadCaches()
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("cacheFound"),
                object: nil,
                queue: .main) { notification in
                if let cacheID = notification.object as? Int {
                    foundCacheIDs.insert(cacheID)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    //  Load event caches only
    private func loadCaches() {
        isLoading = true
        
        if let location = locationManager.userLocation, !hasSetInitialLocation {
            region.center = location.coordinate
            hasSetInitialLocation = true
        }
        
        Task {
            do {
                // Only load caches for this specific event
                caches = try await GeoQuestAPIManager.shared.getCachesForEvent(eventID: event.eventID)
                
                // Load found caches
                let players = try await GeoQuestAPIManager.shared.getPlayers()
                if let player = players.first(where: { $0.playerUserID == loggedInUserID }) {
                    let finds = try await GeoQuestAPIManager.shared.getFindsForPlayer(playerID: player.playerID)
                    foundCacheIDs = Set(finds.map { $0.findCacheID })
                }
            } catch {
                print("Error loading event caches: \(error)")
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

