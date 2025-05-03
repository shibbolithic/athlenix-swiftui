//
//  GamePointsChartView.swift
//  PakhisAthlinix
//
//  Created by admin65 on 11/03/25.
//


import SwiftUI
import Charts
import Supabase

struct teamGamePointsChartView: View {
    @State private var gameLogs: [GameLogtable] = []
    @State private var games: [GameTable] = []
    @State private var isLoading = true
    @State private var sessionUserID: UUID?
    
    var teamID: UUID // Team ID to filter game logs

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if gameLogs.isEmpty {
                Text("No game data available")
                    .font(.headline)
                    .foregroundColor(.gray)
            } else {
                VStack(alignment: .leading) {
                    Chart {
                        ForEach(latestGameLogs(), id: \.logID) { log in
                            BarMark(
                                x: .value("Game", formattedDate(for: log.gameID)),
                                y: .value("2-Pointers", log.points2 * 2)
                            )
                            .foregroundStyle(Color.blue)
                            .position(by: .value("Type", "2-Pointers"))

                            BarMark(
                                x: .value("Game", formattedDate(for: log.gameID)),
                                y: .value("3-Pointers", log.points3 * 3)
                            )
                            .foregroundStyle(Color.green)
                            .position(by: .value("Type", "3-Pointers"))

                            BarMark(
                                x: .value("Game", formattedDate(for: log.gameID)),
                                y: .value("Free Throws", log.freeThrows)
                            )
                            .foregroundStyle(Color.orange)
                            .position(by: .value("Type", "Free Throws"))
                        }
                    }
                    .chartXAxisLabel("Game")
                    .chartYAxisLabel("Points")
                    .frame(height: 250)
                    .padding()
                }
                .padding()
            }
        }
        .task {
            await fetchSessionUserAndData()
        }
    }
    
    /// Fetch session user and then load game data
    private func fetchSessionUserAndData() async {
        do {
            guard let userID = await SessionManager.shared.getSessionUser() else {
                print("Error: No session user is set")
                isLoading = false
                return
            }
            sessionUserID = userID
            await fetchGameData()
        }
    }

    // Fetch game logs for the given team
    private func fetchGameData() async {
        do {
            // Fetch game logs for the specified team
            let gameLogsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("teamID", value: teamID.uuidString)
                .execute()
            gameLogs = try JSONDecoder().decode([GameLogtable].self, from: gameLogsResponse.data)

            // Fetch games played by the team
            let gamesResponse = try await supabase
                .from("Game")
                .select("*")
                .or("team1ID.eq.\(teamID.uuidString),team2ID.eq.\(teamID.uuidString)")
                .execute()
            games = try JSONDecoder().decode([GameTable].self, from: gamesResponse.data)

            isLoading = false
        } catch {
            print("Error fetching data: \(error)")
            isLoading = false
        }
    }
    
    // Get the latest 5 game logs based on game date
    private func latestGameLogs() -> [GameLogtable] {
        let sortedGames = games.sorted { game1, game2 in
            (gameDate(for: game1.gameID) ?? Date.distantPast) >
            (gameDate(for: game2.gameID) ?? Date.distantPast)
        }
        
        let latestGameIDs = sortedGames.prefix(5).map { $0.gameID } // Get latest 5 game IDs
        
        return gameLogs.filter { latestGameIDs.contains($0.gameID) }
    }

    // Get game date for a given game ID
    private func gameDate(for gameID: UUID) -> Date? {
        if let game = games.first(where: { $0.gameID == gameID }) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: game.dateOfGame)
        }
        return nil
    }
    
    // Format game date for X-axis
    private func formattedDate(for gameID: UUID) -> String {
        if let date = gameDate(for: gameID) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            return formatter.string(from: date)
        }
        return "Unknown"
    }
}
