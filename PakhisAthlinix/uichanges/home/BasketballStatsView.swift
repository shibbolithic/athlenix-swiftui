//
//  BasketballStatsView.swift
//  PakhisAthlinix
//
//  Created by admin65 on 26/04/25.
//

import SwiftUI

struct BasketballStatsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var viewModel = BasketballStatsViewModel()
        @State private var showOptions = false
    @State private var isSheetPresented = false
    @State private var isEditProfilePresented = false
    @State private var showAnalytics = false
    
    @State private var gameLogs: [GameLogtable] = []
    @State private var games: [GameTable] = []
    @State private var totalGames = 0
    @State private var totalPoints = 0
    @State private var efficiency2 = 100
    @State private var efficiency3 = 70
    @State private var freeThrowEff = 32
    
    @State private var teamNames: [UUID: String] = [:]
    @State private var userName: String = ""
    @State private var userImageURL: URL?
    @State private var sessionUserID: String = ""
    
    // Add these computed properties to your BasketballStatsView struct
    private var twoPointEfficiency: Int {
        guard !gameLogs.isEmpty else { return 0 }
        
        let total2PointAttempts = gameLogs.reduce(0) { $0 + $1.points2 + $1.missed2Points }
        guard total2PointAttempts > 0 else { return 0 }
        
        let total2PointMade = gameLogs.reduce(0) { $0 + $1.points2 }
        return Int(Double(total2PointMade) / Double(total2PointAttempts) * 100)
    }

    private var threePointEfficiency: Int {
        guard !gameLogs.isEmpty else { return 0 }
        
        let total3PointAttempts = gameLogs.reduce(0) { $0 + $1.points3 + $1.missed3Points }
        guard total3PointAttempts > 0 else { return 0 }
        
        let total3PointMade = gameLogs.reduce(0) { $0 + $1.points3 }
        return Int(Double(total3PointMade) / Double(total3PointAttempts) * 100)
    }

    private var freeThrowEfficiency: Int {
        guard !gameLogs.isEmpty else { return 0 }
        
        let totalFTAttempts = gameLogs.reduce(0) { $0 + $1.freeThrows }
        guard totalFTAttempts > 0 else { return 0 }
        
        // Assuming freeThrows represents both made and missed (need to clarify this)
        // If freeThrows is only made, we need missed free throws data
        // For now, I'll assume freeThrows is made and we have another property for missed
        // Since we don't have missedFT in the struct, I'll just return the total
        // You should add missedFT to your GameLogtable struct for accurate calculation
        return totalFTAttempts // This needs to be updated with proper calculation
    }

    // Update your performanceSnapshotSection to use these computed properties



    let currentPlayerID: UUID
//    let currentTeamID: UUID

    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        topSection
                        
                        HStack {
                            Text("Summary")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            Spacer()
                            Button(action: {}) {
                                Text("Show More")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                        performanceAndAggregateCard
                        
                        recentMatchesSection
                        
                        
                    }
                    .padding()
                }
                .background(
                    Color(.systemBackground)
                        .edgesIgnoringSafeArea(.all)
                )
                .navigationBarHidden(true)
                .task {
                    do {
                        guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
                            print("No session user is set")
                            return
                        }

                        async let statsFetch: () = viewModel.fetchStats(for: sessionUserID)
                        async let matchesFetch: () = viewModel.fetchRecentMatches(for: sessionUserID)
                        async let teamsFetch: () = fetchTeamNames()
                        async let gameLogsFetch: () = fetchGameLogs(for: sessionUserID)
                        
                        let _ = await (statsFetch, matchesFetch, teamsFetch, gameLogsFetch)
                        
                        games = viewModel.recentMatches
                        
                    } catch {
                        print("Error fetching data: \(error)")
                    }
                }
                
                // Floating Action Button
//                Button(action: {
//                    isSheetPresented.toggle()
//                }) {
//                    Image(systemName: "plus")
//                        .font(.title.weight(.bold))
//                        .foregroundColor(.white)
//                        .padding(20)
//                        .background(Color.orange)
//                        .clipShape(Circle())
//                        .shadow(radius: 4, x: 0, y: 4)
//                }
//                .padding()
//                .sheet(isPresented: $isSheetPresented) {
//                    CreateSheetView()
//                        .presentationDetents([.fraction(0.3)]) // Important! It controls the height.
//                        .presentationDragIndicator(.visible)
//                }
            }
        }
    }


    // 🏠 Top Section
    private var topSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Monday, Apr 26")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Welcome back, Alex!")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
            }
            Spacer()
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)
                .overlay(Circle().stroke(Color.primary, lineWidth: 1))
        }
    }
    
    private func fetchGameLogs(for playerID: UUID) async {
        do {
            let response = try await supabase
                .from("GameLog")
                .select("*")
                .eq("playerID", value: playerID)
                .execute()
            
            let decoder = JSONDecoder()
            let logs = try decoder.decode([GameLogtable].self, from: response.data)
            
            gameLogs = logs
            print("Fetched \(gameLogs.count) game logs")
        } catch {
            print("Error fetching game logs: \(error)")
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


    
    // 📦 Combined Card for Performance and Aggregate Stats
    private var performanceAndAggregateCard: some View {
        VStack(spacing: 0) {
            performanceSnapshotSection
                .padding()
            
            Divider()
            
            aggregateStatsSection
                .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // 📊 Performance Snapshot Section
    private var performanceSnapshotSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 0) {
                Spacer()
                ringGraph(title: "2 Point Efficiency", value: twoPointEfficiency, color: .green)
                    .frame(width: 100)
                Spacer()
                ringGraph(title: "3 Point Efficiency", value: threePointEfficiency, color: .red)
                    .frame(width: 100)
                Spacer()
                ringGraph(title: "Free Throw Efficiency", value: freeThrowEff, color: .mint)
                    .frame(width: 100)
                Spacer()
            }
        }
    }

    private func ringGraph(title: String, value: Int, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: CGFloat(value) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(value)%")
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
            }
            .frame(width: 70, height: 70)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                .frame(width: 80) // Fixed width for text
        }
    }

    
    // 📊 Aggregate Stats Section
    private var aggregateStatsSection: some View {
        HStack(spacing: 16) {
            statBlock(label: "Total Games Played", value: "\(viewModel.totalGamesPlayed)")
            statBlock(label: "Total Points Scored", value: "\(viewModel.totalPointsScored)")
        }
    }

    
    private func statBlock(label: String, value: String) -> some View {
        VStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // 📅 Recent Matches Section
    private var recentMatchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Matches")
                    .font(.title2.bold())
                Spacer()
                Button(action: {}) {
                    Text("Show More")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }

            ForEach(games.prefix(3), id: \.gameID) { game in
                matchCard(
                    homeTeam: teamNames[game.team1ID] ?? "Team A",
                    awayTeam: teamNames[game.team2ID] ?? "Team B",
                    homeScore: game.team1finalScore,
                    awayScore: game.team2finalScore
                )
            }
        }
    }

    private func matchCard(homeTeam: String, awayTeam: String, homeScore: Int, awayScore: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(homeTeam)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(awayTeam)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(homeScore) - \(awayScore)")
                .font(.headline.bold())
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
            
        )
    }
    
}

private var aggregateStatsSection: some View {
    HStack(spacing: 16) {
        statBlock(label: "Total Games Played", value: "12")
        statBlock(label: "Total Points Scored", value: "324")
    }
    .padding(.vertical, 8)
}

private func statBlock(label: String, value: String) -> some View {
    VStack {
        Text(label)
            .font(.subheadline)
            .foregroundColor(.gray)
        Text(value)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    .frame(maxWidth: .infinity)
}
