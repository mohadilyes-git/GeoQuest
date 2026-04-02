
import SwiftUI
import Combine

struct LoginView: View {
    
    @State private var username = ""
    @State private var password = ""
    @State private var currentImageIndex = 0
    
    let images = ["HomeScreenImage1", "HomeScreenImage2", "HomeScreenImage3", "HomeScreenImage4"]
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // Making images slides for Background
                ForEach(0..<images.count, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(currentImageIndex == index ? 1 : 0)
                        .animation(.easeInOut(duration: 1.2), value: currentImageIndex)
                }
                
                // Dark overlay
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                
                //  Content
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    // Logo and title
                    VStack(spacing: 8) {
                        
                        Text("GeoQuest")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Find. Explore. Discover.")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    //  The login form
                    VStack(spacing: 16) {
                        
                        // Username field
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(Color.gqSand)
                                .frame(width: 20)
                            TextField("Username", text: $username)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        // Password field
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(Color.gqSand)
                                .frame(width: 20)
                            SecureField("Password", text: $password)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        // Login button
                        Button {
                            // add login logic later
                        } label: {
                            Text("Login")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.gqLeafGreen)
                                .cornerRadius(12)
                        }
                        
                        // Register link
                        NavigationLink {
                            RegisterView()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Register")
                                    .foregroundColor(Color.gqGoldReward)
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 15))
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
                }
            }
            .onReceive(timer) { _ in
                currentImageIndex = (currentImageIndex + 1) % images.count
            }
        }
    }
}

#Preview {
    LoginView()
}
