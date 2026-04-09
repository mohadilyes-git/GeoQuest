import SwiftUI
import Combine

struct LoginView: View {
    
    @State private var username = ""
    @State private var password = ""
    @State private var currentImageIndex = 0
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, password
    }
    
    let api = GeoQuestAPIManager.shared
    let images = ["HomeScreenImage1", "HomeScreenImage2", "HomeScreenImage3", "HomeScreenImage4"]
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // Background slideshow
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
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        Spacer()
                            .frame(height: 80)
                        
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
                            .frame(height: 40)
                        
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
                                    .focused($focusedField, equals: .username)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .password }
                            }
                            .padding()
                            .background(Color.black.opacity(0.45))
                            .cornerRadius(12)
                            
                            // Password field
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(Color.gqSand)
                                    .frame(width: 20)
                                SecureField("Password", text: $password)
                                    .foregroundColor(.white)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.go)
                                    .onSubmit {
                                        focusedField = nil
                                        Task { await handleLogin() }
                                    }
                            }
                            .padding()
                            .background(Color.black.opacity(0.45))
                            .cornerRadius(12)
                            
                            // Error message
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.system(size: 13))
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Login button with spinner
                            Button {
                                focusedField = nil
                                Task { await handleLogin() }
                            } label: {
                                ZStack {
                                    Text("Login")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                        .opacity(isLoading ? 0 : 1)
                                    
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.gqLeafGreen)
                                .cornerRadius(12)
                            }
                            .disabled(isLoading)
                            
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
                    .frame(minHeight: 700)
                }
                .scrollDisabled(true)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .onReceive(timer) { _ in
                currentImageIndex = (currentImageIndex + 1) % images.count
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                MainTabView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    // Login logic
    func handleLogin() async {
        errorMessage = ""
        
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your username and password"
            return
        }
        
        isLoading = true
        
        do {
            // Fetch matching user by username
            let matchedUser = try await api.getUserByUsername(username)
            
            guard let user = matchedUser else {
                errorMessage = "No account found with that username"
                isLoading = false
                return
            }
            
            // Check password
            guard user.userPassword == password else {
                errorMessage = "Incorrect password"
                isLoading = false
                return
            }
            
            // Save logged in user to UserDefaults
            UserDefaults.standard.set(user.userID, forKey: "loggedInUserID")
            UserDefaults.standard.set(user.userUsername, forKey: "loggedInUsername")
            
            isLoggedIn = true
            
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView()
}
