import SwiftUI

struct LeaderboardView: View {
    
    @State private var leaderboardEntries: [(username: String, points: Int, finds: Int)] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    let api = GeoQuestAPIManager.shared
    let loggedInUsername = UserDefaults.standard.string(forKey: "loggedInUsername") ?? ""
    
    var body: some View {
        ZStack {
            Color.gqLightStone
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .tint(Color.gqLeafGreen)
                
            } else if !errorMessage.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 40))
                        .foregroundColor(Color.gqSand)
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Button("Try Again") {
                        Task { await loadLeaderboard() }
                    }
                    .foregroundColor(Color.gqLeafGreen)
                }
                
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        
                        // Title row
                        HStack {
                            Spacer()
                            Text("Leaderboard")
                                .font(.system(size: 28, weight: .bold))
                            Spacer()
                            Button {
                                Task { await loadLeaderboard() }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(Color.gqLeafGreen)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 4)
                        
                        if leaderboardEntries.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "trophy")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.gqSand)
                                Text("No scores yet")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(0..<leaderboardEntries.count, id: \.self) { index in
                                let entry = leaderboardEntries[index]
                                let isMe = entry.username == loggedInUsername
                                
                                HStack(spacing: 14) {
                                    
                                    // Rank number
                                    Text("\(index + 1)")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .frame(width: 30)
                                    
                                    // Username and finds
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("@\(entry.username)")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(isMe ? Color.gqLeafGreen : .primary)
                                        Text("\(entry.finds) caches found")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Points
                                    Text("\(entry.points) pts")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(Color.gqGoldReward)
                                }
                                .padding()
                                .background(isMe ? Color.gqLeafGreen.opacity(0.08) : Color.white)
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .task {
            await loadLeaderboard()
        }
    }
    
    // Load leaderboard data from API
    func loadLeaderboard() async {
        isLoading = true
        errorMessage = ""
        
        do {
            let finds = try await api.getFinds()
            let players = try await api.getPlayers()
            let users = try await api.getUsers()
            
            // Map playerID to username
            var playerToUsername: [Int: String] = [:]
            for player in players {
                if let user = users.first(where: { $0.userID == player.playerUserID }) {
                    playerToUsername[player.playerID] = user.userUsername
                }
            }
            
            // Group finds by playerID and sum points
            var scoreMap: [Int: (username: String, points: Int, finds: Int)] = [:]
            
            for find in finds {
                let playerID = find.findPlayerID
                let points = find.findCache?.cachePoints ?? 0
                let username = playerToUsername[playerID] ?? "Player \(playerID)"
                
                if let existing = scoreMap[playerID] {
                    scoreMap[playerID] = (
                        username: username,
                        points: existing.points + points,
                        finds: existing.finds + 1
                    )
                } else {
                    scoreMap[playerID] = (username: username, points: points, finds: 1)
                }
            }
            // Sorts by points, descending first and then by username
            leaderboardEntries = scoreMap.values.sorted {
                if $0.points != $1.points {
                    return $0.points > $1.points
                }
                return $0.username < $1.username
            }
            
        } catch {
            errorMessage = "Could not load leaderboard. Please try again."
        }
        
        isLoading = false
    }
}

#Preview {
    LeaderboardView()
}
