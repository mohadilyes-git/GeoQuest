import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            
            // Map tab
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
            
            // Leaderboard tab
            LeaderboardView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Leaderboard")
                }
            
            // Profile tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .tint(Color.gqLeafGreen)
    }
}

#Preview {
    MainTabView()
}

