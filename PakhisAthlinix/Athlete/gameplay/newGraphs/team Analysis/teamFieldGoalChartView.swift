//
//  FieldGoalChartView.swift
//  PakhisAthlinix
//
//  Created by admin65 on 11/03/25.
//


import SwiftUI
import Charts

struct teamFieldGoalChartView: View {
    let teamID: UUID  // Team ID to filter games
    @State private var gameLogs: [GameLogtable1] = []
    @State private var games: [GameTable1] = []
    @State private var isLoading = true
    
    var latestFiveGames: [(date: String, fieldGoalPercentage: Double)] {
        let gameLogMap = Dictionary(grouping: gameLogs, by: { $0.gameID })
        
        return games
            .filter { $0.team1ID == teamID || $0.team2ID == teamID } // Filter games for the team
            .sorted { $0.dateOfGame > $1.dateOfGame } // Sort by latest date
            .prefix(5) // Take latest 5 games
            .compactMap { game in
                if let logs = gameLogMap[game.gameID] {
                    let totalFGPercentage = logs.map { $0.fieldGoalPercentage }.reduce(0, +) / Double(logs.count)
                    return (game.dateOfGame, totalFGPercentage)
                }
                return nil
            }
            .reversed() // Maintain chronological order
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else {
                Chart(latestFiveGames, id: \.date) { game in
                    LineMark(
                        x: .value("Game", game.date),
                        y: .value("FG%", game.fieldGoalPercentage)
                    )
                    .foregroundStyle(.blue)
                    .symbol(.circle)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)
            }
        }
        .task {
            await fetchGameData()
        }
    }
    
    func fetchGameData() async {
        isLoading = true
        do {
            let gameLogsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("teamID", value: teamID.uuidString) // Fetch logs for the team
                .execute()
            gameLogs = try JSONDecoder().decode([GameLogtable1].self, from: gameLogsResponse.data)
            
            let gamesResponse = try await supabase
                .from("Game")
                .select("*")
                .or("team1ID.eq.\(teamID.uuidString),team2ID.eq.\(teamID.uuidString)") // Fetch games for the team
                .execute()
            games = try JSONDecoder().decode([GameTable1].self, from: gamesResponse.data)
            
            isLoading = false
        } catch {
            print("Error fetching data: \(error)")
            isLoading = false
        }
    }
}
