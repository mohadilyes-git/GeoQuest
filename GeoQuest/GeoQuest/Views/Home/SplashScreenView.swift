import SwiftUI

struct SplashScreenView: View {
    
    @State private var isActive = false
    @AppStorage("loggedInUserID") private var loggedInUserID = 0
    
    var body: some View {
        ZStack {
            if isActive {
                if loggedInUserID == 0 {
                    LoginView()
                        .transition(.opacity)
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            } else {
                ZStack {
                    Color.gqLightStone
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Image("App_Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .cornerRadius(28)
                        
                        Text("GeoQuest")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.gqLeafGreen)
                        
                        Text("Find. Explore. Discover.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: isActive)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isActive = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
