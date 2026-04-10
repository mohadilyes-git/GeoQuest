import SwiftUI

struct MainTabView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
        
    }
    var body: some View {
        
        TabView {
            
            // Map tab
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
            
            // Events tab
            EventsView()
                .tabItem {
                    Image(systemName: "calendar.circle.fill")
                    Text("Events")
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

