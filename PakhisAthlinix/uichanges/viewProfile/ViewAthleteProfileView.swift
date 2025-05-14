//
//  AthleteProfileView.swift
//  PakhisAthlinix
//
//  Created by admin65 on 11/05/25.
//


import SwiftUI
import Supabase

struct ViewAthleteProfileView: View {
    let userId: UUID
    
    @State private var recentPosts1: [PostsTableExplore] = []
    @State private var userProfile: Usertable?
    @State private var athleteProfile: AthleteProfileTable?
    @State private var userTeams: [TeamTable] = []
    @State private var recentGames: [GameTable] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var teamNames: [UUID: String] = [:]
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding(.top, 200)
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                profileContent
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .top)
        .task {
            await loadProfileData()
        }
    }
    
    private var profileContent: some View {
        VStack(spacing: 16) {
            // Profile Header
            ZStack(alignment: .bottom) {
                // Cover photo - now starts from top of screen
                if let coverPicture = userProfile?.coverPicture {
                    if coverPicture.hasPrefix("http") {
                        AsyncImage(url: URL(string: coverPicture)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipped()
                        } placeholder: {
                            Color.gray
                                .frame(height: 250)
                        }
                    } else {
                        Image(coverPicture)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()
                    }
                } else {
                    Color.gray
                        .frame(height: 250)
                }
                
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color(.systemBackground)]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 250)
                
                // Profile image - removed circular border
                if let profilePicture = userProfile?.profilePicture {
                    if profilePicture.hasPrefix("http") {
                        AsyncImage(url: URL(string: profilePicture)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.width * 0.35)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            case .failure:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.width * 0.35)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            case .empty:
                                ProgressView()
                                    .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.width * 0.35)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .offset(y: UIScreen.main.bounds.width * 0.35/3.5)
                    } else {
                        Image(profilePicture)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.width * 0.35)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            .offset(y: UIScreen.main.bounds.width * 0.35/3.5)
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.width * 0.35)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .offset(y: UIScreen.main.bounds.width * 0.35/3.5)
                }
            }
            .padding(.bottom, UIScreen.main.bounds.width * 0.35 / 3)
            
            // Name and bio - reduced spacing
            VStack(spacing: 2) {
                Text(userProfile?.name ?? "Unknown User")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Athlete")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(userProfile?.bio ?? "No bio available")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 2)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Stats Section
            if let athleteProfile = athleteProfile {
                HStack(spacing: 8) {
                    StatItem(title: athleteProfile.position.rawValue, subtitle: "Position")
                    StatItem(title: "\(recentGames.count)", subtitle: "Matches")
                    StatItem(title: String(format: "%.1f cm", athleteProfile.height), subtitle: "Height")
                    StatItem(title: String(format: "%.1f kg", athleteProfile.weight), subtitle: "Weight")
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical, 2)
                
                // Game Stats Section
                HStack(spacing: 8) {
                    StatItem(title: String(format: "%.2f", athleteProfile.averagePointsPerGame), subtitle: "PPG")
                    StatItem(title: String(format: "%.2f", athleteProfile.averageReboundsPerGame), subtitle: "RPG")
                    StatItem(title: String(format: "%.2f", athleteProfile.averageAssistsPerGame), subtitle: "AST")
                }
                .padding(.horizontal)
            }
            
            Divider()
                .padding(.vertical, 2)
            
            // My Teams - increased spacing between title and content
            if !userTeams.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Teams")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(userTeams, id: \.teamID) { team in
                                TeamItem(imageName: team.teamLogo!)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                }
                .padding(.bottom, 12)
            }
            
            // Recent Matches Section - increased spacing between title and content
            if !recentGames.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Recent Matches")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: {}) {
                            Text("Show More")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        ForEach(recentGames.prefix(3), id: \.gameID) { game in
                            matchCard(
                                homeTeam: teamNames[game.team1ID] ?? "Team A",
                                awayTeam: teamNames[game.team2ID] ?? "Team B",
                                homeScore: game.team1finalScore,
                                awayScore: game.team2finalScore
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            
            // Recent Posts Section
            if !recentPosts1.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Posts")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(recentPosts1.prefix(5)) { post in
                            PostCard(post: post)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            
            Spacer()
        }
    }
    
    private func fetchTeamNames() async {
        do {
            let response = try await supabase
                .from("teams")
                .select("*")
                .execute()
            
            let decoder = JSONDecoder()
            let teams = try decoder.decode([TeamTable].self, from: response.data)
            
            var names = [UUID: String]()
            for team in teams {
                names[team.teamID] = team.teamName
            }
            
            teamNames = names
            print("Fetched \(teamNames.count) team names")
        } catch {
            print("Error fetching team names: \(error)")
        }
    }
    
    private func fetchPlayerGames(playerID: UUID) async throws -> [GameTable] {
        // Fetch game logs for the player
        let gameLogsResponse = try await supabase
            .from("GameLog")
            .select("*")
            .eq("playerID", value: playerID.uuidString)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let playerGameLogs = try decoder.decode([GameLogtable].self, from: gameLogsResponse.data)
        
        // Get unique game IDs
        let playerGameIDs = Array(Set(playerGameLogs.map { $0.gameID }))
        
        // If no games found, return empty array
        guard !playerGameIDs.isEmpty else { return [] }
        
        // Fetch the actual games
        let gamesResponse = try await supabase
            .from("Game")
            .select("*")
            .in("gameID", values: playerGameIDs)
            .execute()
        
        var playerGames = try decoder.decode([GameTable].self, from: gamesResponse.data)
        
        // Sort by date (newest first)
        playerGames.sort {
            guard
                let date1 = ISO8601DateFormatter().date(from: $0.dateOfGame),
                let date2 = ISO8601DateFormatter().date(from: $1.dateOfGame)
            else { return false }
            return date1 > date2
        }
        
        return playerGames
    }
    
    private func matchCard(homeTeam: String, awayTeam: String, homeScore: Int, awayScore: Int) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(homeTeam)
                    .font(.headline)
                Text(awayTeam)
                    .font(.headline)
            }
            
            Spacer()
            
            VStack {
                Text("\(homeScore)")
                    .font(.headline)
                Text("\(awayScore)")
                    .font(.headline)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private func loadProfileData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let teamNamesFetch: () = fetchTeamNames()

            userProfile = try await supabase.database
                .from("User")
                .select()
                .eq("userID", value: userId)
                .single()
                .execute()
                .value
            
            // Fetch athlete profile
            athleteProfile = try await supabase.database
                .from("AthleteProfile")
                .select()
                .eq("athleteID", value: userId)
                .single()
                .execute()
                .value
            
            // Fetch user's teams
            let teamMemberships: [TeamMembershipTable] = try await supabase.database
                .from("teamMembership")
                .select()
                .eq("userID", value: userId)
                .execute()
                .value
            
            let teamIDs = teamMemberships.map { $0.teamID }
            if !teamIDs.isEmpty {
                userTeams = try await supabase.database
                    .from("teams")
                    .select()
                    .in("teamID", value: teamIDs)
                    .execute()
                    .value
            }
            
            // Fetch recent games
            recentGames = try await fetchPlayerGames(playerID: userId)
            
            // Fetch recent posts
            recentPosts1 = try await supabase.database
                .from("posts")
                .select()
                .eq("createdBy", value: userId)
                .order("createdAt", ascending: false)
                .limit(5)
                .execute()
                .value
            
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading profile data: \(error)")
        }
        
        isLoading = false
    }
}
//
//struct StatItem: View {
//    let title: String
//    let subtitle: String
//    
//    var body: some View {
//        VStack {
//            Text(title)
//                .font(.headline)
//            Text(subtitle)
//                .font(.caption)
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity)
//    }
//}
//
//struct TeamItem: View {
//    let imageName: String
//    
//    var body: some View {
//        VStack {
//            if imageName.hasPrefix("http") {
//                AsyncImage(url: URL(string: imageName)) { image in
//                    image
//                        .resizable()
//                        .scaledToFill()
//                } placeholder: {
//                    Color.gray
//                }
//                .frame(width: 60, height: 60)
//                .clipShape(Circle())
//            } else {
//                Image(imageName)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 60, height: 60)
//                    .clipShape(Circle())
//            }
//        }
//    }
//}
