//
//  AthleteProfileView.swift
//  swiftCharts
//
//  Created by admin65 on 27/04/25.
//

import SwiftUI
import Supabase

struct AthleteProfileView: View {
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
               //async let teamsFetch: () = fetchTeamNames()
           }
       }
       
       private var profileContent: some View {
           VStack(spacing: 16) {
               // Profile Header
               ZStack(alignment: .bottom) {
                   // Cover photo
                   if let coverPicture = userProfile?.coverPicture {
                                       if coverPicture.hasPrefix("http") {
                                           // Handle URL image
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
                                           // Handle local asset image
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
                   
                   // Profile image
                   if let profilePicture = userProfile?.profilePicture {
                                      if profilePicture.hasPrefix("http") {
                                          // Handle URL image
                                          AsyncImage(url: URL(string: profilePicture)) { phase in
                                              switch phase {
                                              case .success(let image):
                                                  image
                                                      .resizable()
                                                      .aspectRatio(contentMode: .fill)
                                                      .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.width * 0.35)
                                                      .clipShape(Circle())
                                                      .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                                      .shadow(radius: 5)
                                              case .failure:
                                                  Image(systemName: "person.circle.fill")
                                                      .resizable()
                                                      .aspectRatio(contentMode: .fill)
                                                      .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.width * 0.35)
                                                      .clipShape(Circle())
                                                      .overlay(Circle().stroke(Color.white, lineWidth: 4))
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
                                          // Handle local asset image
                                          Image(profilePicture)
                                              .resizable()
                                              .aspectRatio(contentMode: .fill)
                                              .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.width * 0.35)
                                              .clipShape(Circle())
                                              .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                              .shadow(radius: 5)
                                              .offset(y: UIScreen.main.bounds.width * 0.35/3.5)
                                      }
                                  } else {
                                      Image(systemName: "person.circle.fill")
                                          .resizable()
                                          .aspectRatio(contentMode: .fill)
                                          .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.width * 0.35)
                                          .clipShape(Circle())
                                          .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                          .shadow(radius: 5)
                                          .offset(y: UIScreen.main.bounds.width * 0.35/3.5)
                                  }
                              }
                              .padding(.bottom, UIScreen.main.bounds.width * 0.35 / 2.5)
               
               // Name and bio
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
                       StatItem(title: "\(athleteProfile.experience)", subtitle: "Matches")
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
               
               // My Teams
               if !userTeams.isEmpty {
                   VStack(alignment: .leading, spacing: 8) {
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
                   }
               }
               
               // Recent Matches Section
               if !recentGames.isEmpty {
                   recentMatchesSection
               }
               
               // Recent Posts Section
               if !recentPosts1.isEmpty {
                   recentPostsSection
               }
               
               Spacer()
           }
           .padding(.top)
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

    
    private var recentMatchesSection: some View {
            VStack(alignment: .leading, spacing: 12) {
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
                
                VStack(spacing: 8) {
                    ForEach(recentGames.prefix(3), id: \.gameID) { game in
                        // This would need to fetch team names from Supabase
                        matchCard(
                            homeTeam: teamNames[game.team1ID] ?? "Team A",
                            awayTeam: teamNames[game.team2ID] ?? "Team B",
                            homeScore: game.team1finalScore,
                            awayScore: game.team2finalScore
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
        
        private var recentPostsSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Posts")
                    .font(.headline)
                    .padding(.horizontal)
                
                LazyVStack(spacing: 16) {
                    ForEach(recentPosts1.prefix(5)) { post in
                        PostCard(post: post)
                    }
                }
                .padding(.horizontal)
            }
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
                //let currentUserID = UUID(uuidString: "USER_ID_FROM_AUTH")!
                let currentUserID = await SessionManager.shared.getSessionUser()
                async let teamNamesFetch: () = fetchTeamNames()

                userProfile = try await supabase.database
                    .from("User")
                    .select()
                    .eq("userID", value: currentUserID)
                    .single()
                    .execute()
                    .value
                
                // Fetch athlete profile
                athleteProfile = try await supabase.database
                    .from("AthleteProfile")
                    .select()
                    .eq("athleteID", value: currentUserID)
                    .single()
                    .execute()
                    .value
                
                // Fetch user's teams
                let teamMemberships: [TeamMembershipTable] = try await supabase.database
                    .from("teamMembership")
                    .select()
                    .eq("userID", value: currentUserID)
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
                
                // Fetch recent games (simplified - would need more complex query in real app)
                recentGames = try await supabase.database
                    .from("Game")
                    .select()
                    .order("dateOfGame", ascending: false)
                    .limit(5)
                    .execute()
                    .value
                
                
                
                // Fetch recent posts
                recentPosts1 = try await supabase.database
                    .from("posts")
                    .select()
                    .eq("createdBy", value: currentUserID)
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

// Reusable Views
struct StatItem: View {
    var title: String
    var subtitle: String
    
    var body: some View {
        VStack(spacing: 2) { // reduced spacing
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TeamItem: View {
    var imageName: String
    
    var body: some View {
        Group {
            if imageName.hasPrefix("http") {
                AsyncImage(url: URL(string: imageName)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(Circle())
        .shadow(radius: 4)
    }
}



//let recentPosts: [Post] = [
//    Post(userName: "Coach Carter", userImage: "person.fill", contentImage: ["16", "17"], timeAgo: "2h ago", text: "Great practice session today!"),
//    Post(userName: "Alex Morgan", userImage: "person.fill", contentImage: ["17"], timeAgo: "5h ago", text: "Feeling pumped for the next game."),
//    Post(userName: "Sam Knight", userImage: "person.fill", contentImage: ["16"], timeAgo: "1d ago", text: nil)
//]

//#Preview {
//    AthleteProfileView()
//}
