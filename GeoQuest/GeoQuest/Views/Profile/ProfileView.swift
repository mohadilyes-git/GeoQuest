import SwiftUI

struct ProfileView: View {
    
    @State private var user: User? = nil
    @State private var finds: [Find] = []
    @State private var isLoading = false
    @State private var totalPoints = 0
    
    let api = GeoQuestAPIManager.shared
    let loggedInUserID = UserDefaults.standard.integer(forKey: "loggedInUserID")
    let loggedInUsername = UserDefaults.standard.string(forKey: "loggedInUsername") ?? ""
    
    var body: some View {
        ZStack {
            Color.gqLightStone
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .tint(Color.gqLeafGreen)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Profile header
                        VStack(spacing: 12) {
                            
                            // Avatar circle
                            if let imageURL = user?.userImageURL, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                } placeholder: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gqLeafGreen)
                                            .frame(width: 80, height: 80)
                                        Text(loggedInUsername.prefix(1).uppercased())
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.gqLeafGreen)
                                        .frame(width: 80, height: 80)
                                    Text(loggedInUsername.prefix(1).uppercased())
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            // Username
                            Text("@\(loggedInUsername)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            // Full name
                            if let user = user {
                                Text(user.fullName)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Stats row
                        HStack(spacing: 0) {
                            
                            // Total points
                            VStack(spacing: 4) {
                                Text("\(totalPoints)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color.gqGoldReward)
                                Text("Points")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                                .frame(height: 40)
                            
                            // Caches found
                            VStack(spacing: 4) {
                                Text("\(finds.count)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color.gqLeafGreen)
                                Text("Caches found")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        
                        // Recent finds
                        if !finds.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Recent finds")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 8)
                                
                                VStack(spacing: 0) {
                                    ForEach(finds.prefix(10)) { find in
                                        HStack {
                                            Image(systemName: "mappin.circle.fill")
                                                .foregroundColor(Color.gqCacheRed)
                                                .font(.system(size: 20))
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(find.findCache?.cacheName ?? "Cache")
                                                    .font(.system(size: 15, weight: .semibold))
                                                Text("\(find.findCache?.cachePoints ?? 0) points")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color.gqLeafGreen)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        
                                        if find.id != finds.prefix(10).last?.id {
                                            Divider()
                                                .padding(.leading, 52)
                                        }
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(16)
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // Logout button
                        Button {
                            logout()
                        } label: {
                            Text("Log out")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.gqCacheRed)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .task {
            await loadProfile()
        }
    }
    
    // Load profile data from API
    func loadProfile() async {
        isLoading = true
        
        do {
            // Fetch user details
            user = try await api.getUser(id: loggedInUserID)
            
            // Fetch all players and find ones that belong to this user
            let allPlayers = try await api.getPlayers()
            var myPlayerIDs: [Int] = []
            for player in allPlayers {
                if player.playerUserID == loggedInUserID {
                    myPlayerIDs.append(player.playerID)
                }
            }
            
            // Fetch all finds and keep only this user's ones
            let allFinds = try await api.getFinds()
            finds = []
            for find in allFinds {
                if myPlayerIDs.contains(find.findPlayerID) {
                    finds.append(find)
                }
            }
            
            // Add up total points using a simple loop
            totalPoints = 0
            for find in finds {
                totalPoints += find.findCache?.cachePoints ?? 0
            }
            
        } catch {
            print("Error loading profile: \(error)")
        }
        
        isLoading = false
    }
    
    // Logout — clear saved user data and go back to login
    func logout() {
        UserDefaults.standard.removeObject(forKey: "loggedInUserID")
        UserDefaults.standard.removeObject(forKey: "loggedInUsername")
    }
}

#Preview {
    ProfileView()
}
