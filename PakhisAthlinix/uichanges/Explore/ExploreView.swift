import SwiftUI
import Supabase


struct ExploreView: View {

    
    @State private var recentMatches: [GameTable] = []
    @State private var recentPosts1: [PostsTableExplore] = []
    @State private var users: [Usertable] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
       
    var filteredUsers: [Usertable] {
         if searchText.isEmpty {
             return []
         } else {
             return users.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
         }
     }
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Explore Title
                Text("Explore")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            // Recent Matches
                            if !recentMatches.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recent Matches")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(recentMatches) { match in
                                                MatchCard(match: match)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // Recent Posts
                            if !recentPosts1.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recent Posts")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    LazyVStack(spacing: 16) {
                                        ForEach(recentPosts1) { post in
                                            PostCard(post: post)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                fetchData()
            }
        }
    }
    
    private func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Fetch recent matches (games)
                let matches: [GameTable] = try await supabase.database
                    .from("Game")
                    .select()
                    .order("dateOfGame", ascending: false)
                    .limit(5)
                    .execute()
                    .value
                
                // Fetch recent posts
                let posts: [PostsTableExplore] = try await supabase.database
                    .from("posts")
                    .select()
                    .order("createdAt", ascending: false)
                    .limit(5)
                    .execute()
                    .value
                
                // Fetch users (for search)
                let users: [Usertable] = try await supabase.database
                    .from("User")
                    .select()
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    self.recentMatches = matches
                    self.recentPosts1 = posts
                    self.users = users
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load data: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
// MARK: - Match Card
struct MatchCard: View {
    var match: GameTable
    @State private var team1: TeamTable?
    @State private var team2: TeamTable?
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(match.venue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if isLoading {
                ProgressView()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    if let team1 = team1 {
                        HStack {
                            // Team 1 logo
                            teamLogoView(logo: team1.teamLogo)
                            
                            Text(team1.teamName)
                                .font(.body)
                            
                            Spacer()
                            
                            Text("\(match.team1finalScore)")
                                .font(.body)
                        }
                    }
                    
                    if let team2 = team2 {
                        HStack {
                            // Team 2 logo
                            teamLogoView(logo: team2.teamLogo)
                            
                            Text(team2.teamName)
                                .font(.body)
                            
                            Spacer()
                            
                            Text("\(match.team2finalScore)")
                                .fontWeight(.bold)
                                .font(.body)
                        }
                    }
                }
            }
            
            Text(formatDate(match.dateOfGame))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.primary.opacity(0.05), radius: 3, y: 2)
        .frame(width: 180)
        .onAppear {
            fetchTeams()
        }
    }
    @ViewBuilder
    private func teamLogoView(logo: String?) -> some View {
        if let logo = logo {
            // Check if the logo is a URL (uploaded logo) or an asset name
            if logo.hasPrefix("http") || logo.hasPrefix("https") {
                // Handle URL-based logos (uploaded from gallery)
                AsyncImage(url: URL(string: logo)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                    case .failure:
                        Image(systemName: "photo") // Fallback image
                            .resizable()
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            } else {
                // Handle asset-based logos (from your app's assets)
                Image(logo) // Assumes logo is the asset name
                    .resizable()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
            }
        } else {
            // No logo available
            Image(systemName: "photo") // Fallback image
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
        }
    }
    
    private func fetchTeams() {
        isLoading = true
        Task {
            do {
                // Fetch team1 details
                let team1: TeamTable = try await supabase.database
                    .from("teams")
                    .select()
                    .eq("teamID", value: match.team1ID)
                    .single()
                    .execute()
                    .value
                
                // Fetch team2 details
                let team2: TeamTable = try await supabase.database
                    .from("teams")
                    .select()
                    .eq("teamID", value: match.team2ID)
                    .single()
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    self.team1 = team1
                    self.team2 = team2
                    self.isLoading = false
                }
            } catch {
                print("Error fetching teams: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Adjust based on your date format
        if let date = formatter.date(from: dateString) {
            if Calendar.current.isDateInToday(date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                formatter.dateStyle = .medium
                return formatter.string(from: date)
            }
        }
        return dateString
    }
}

// MARK: - Post Card
struct PostCard: View {
    var post: PostsTableExplore
    @State private var user: Usertable?
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isLoading {
                ProgressView()
            } else {
                HStack(spacing: 12) {
                    if let user = user {
                        // Profile picture view with both URL and asset support
                        profilePictureView(profilePic: user.profilePicture)
                        
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.body)
                                .fontWeight(.semibold)
                            Text(formatTimeAgo(post.createdAt))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                
                if let content = post.content {
                    Text(content)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                // Show images if available
                let images = [post.image1, post.image2, post.image3].compactMap { $0 }
                if !images.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(images, id: \.self) { imageUrl in
                                AsyncImage(url: URL(string: imageUrl)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable()
                                            .scaledToFill()
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                    case .empty:
                                        ProgressView()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 300, height: 200)
                                .clipped()
                                .cornerRadius(12)
                            }
                        }
                        .frame(height: 200)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.primary.opacity(0.05), radius: 3, y: 2)
        .onAppear {
            fetchUser()
        }
    }
    
    @ViewBuilder
    private func profilePictureView(profilePic: String?) -> some View {
        if let profilePic = profilePic {
            // Check if the profile picture is a URL (uploaded) or an asset name
            if profilePic.hasPrefix("http") || profilePic.hasPrefix("https") {
                // Handle URL-based profile pictures
                AsyncImage(url: URL(string: profilePic)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                    case .failure:
                        fallbackProfilePicture()
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                // Handle asset-based profile pictures
                Image(profilePic) // Assumes profilePic is the asset name
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
        } else {
            // No profile picture available
            fallbackProfilePicture()
        }
    }
    
    private func fallbackProfilePicture() -> some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .foregroundColor(.gray)
            .background(Color(.systemGray5))
            .clipShape(Circle())
    }
    
    private func fetchUser() {
        isLoading = true
        Task {
            do {
                let user: Usertable = try await supabase.database
                    .from("User")
                    .select()
                    .eq("userID", value: post.createdBy)
                    .single()
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    self.user = user
                    self.isLoading = false
                }
            } catch {
                print("Error fetching user: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func formatTimeAgo(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year)y ago"
        } else if let month = components.month, month > 0 {
            return "\(month)mo ago"
        } else if let day = components.day, day > 0 {
            return day == 1 ? "1d ago" : "\(day)d ago"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1h ago" : "\(hour)h ago"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1m ago" : "\(minute)m ago"
        } else if let second = components.second, second > 5 {
            return "\(second)s ago"
        } else {
            return "Just now"
        }
    }
}

// MARK: - Models
struct Match: Identifiable {
    let id = UUID()
    var place: String
    var team1: String
    var team1Logo: String // <-- New
    var score1: Int
    var team2: String
    var team2Logo: String // <-- New
    var score2: Int
    var date: String
}

// MARK: - Preview
//struct ExploreView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExploreView()
//    }
//}

extension GameTable: Identifiable {
    var id: UUID { gameID }
}
extension PostsTableExplore: Identifiable {
    var id: UUID { postID }
}
