//
//  Untitled.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 09/04/2026.
//

import SwiftUI

struct EventsView: View {
    
    @State private var events: [Event] = []
    @State private var isLoading = false
    @State private var showCreateEvent = false
    @State private var showJoinEvent = false
    @State private var selectedEvent: Event? = nil
    @State private var showEventMap = false
    
    let api = GeoQuestAPIManager.shared
    let loggedInUserID = UserDefaults.standard.integer(forKey: "loggedInUserID")
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gqLightStone.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        
                        // Create Event
                        Button {
                            showCreateEvent = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Event")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.gqLeafGreen)
                            .cornerRadius(12)
                        }
                        
                        // Join Event
                        Button {
                            showJoinEvent = true
                        } label: {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Join Event")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.gqLeafGreen)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gqLeafGreen, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Events list
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .tint(Color.gqLeafGreen)
                        Spacer()
                    } else if events.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 40))
                                .foregroundColor(Color.gqSand)
                            Text("No events yet")
                                .foregroundColor(.secondary)
                            Text("Create or join an event to get started")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(events) { event in
                                    EventCardView(event: event) {
                                        selectedEvent = event
                                        showEventMap = true
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showCreateEvent) {
                CreateEventView {
                    Task { await loadEvents() }
                }
            }
            .sheet(isPresented: $showJoinEvent) {
                JoinEventView {
                    Task { await loadEvents() }
                }
            }
            .navigationDestination(isPresented: $showEventMap) {
                if let event = selectedEvent {
                    EventMapView(event: event)
                }
            }
        }
        .task {
            await loadEvents()
        }
    }
    
    // Load events for this user
    func loadEvents() async {
        isLoading = true
        do {
            let allPlayers = try await api.getPlayers()
            let myPlayerIDs = allPlayers
                .filter { $0.playerUserID == loggedInUserID }
                .map { $0.playerEventID }
            
            let allEvents = try await api.getEvents()
            events = allEvents.filter { myPlayerIDs.contains($0.eventID) }
        } catch {
            print("Error loading events: \(error)")
        }
        isLoading = false
    }
}

// Event card
struct EventCardView: View {
    let event: Event
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(event.eventName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(event.eventIspublic ? "Public" : "Private")
                        .font(.system(size: 12))
                        .foregroundColor(event.eventIspublic ? Color.gqLeafGreen : Color.gqSand)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(event.eventIspublic ? Color.gqLeafGreen.opacity(0.1) : Color.gqSand.opacity(0.1))
                        .cornerRadius(8)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                    Text(formatDate(event.eventStart))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            let display = DateFormatter()
            display.dateStyle = .medium
            display.timeStyle = .short
            return display.string(from: date)
        }
        return dateString
    }
}

#Preview {
    EventsView()
}
