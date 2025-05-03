//
//  FoulsBarChartView.swift
//  PakhisAthlinix
//
//  Created by admin65 on 11/03/25.
//


import SwiftUI
import Charts

struct teamFoulsBarChartView: View {
    @State private var gameFouls: [(gameLabel: String, fouls: Int)] = []
    @State private var isLoading = true

    let teamID: UUID // Team ID for filtering

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else {
                Chart {
                    ForEach(gameFouls, id: \.gameLabel) { data in
                        BarMark(
                            x: .value("Game", data.gameLabel),
                            y: .value("Fouls", data.fouls)
                        )
                        .foregroundStyle(.red)
                    }
                }
                .chartYAxisLabel("Fouls")
                .chartXAxisLabel("Games")
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            Text(value.as(String.self) ?? "")
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(width: 80)
                        }
                    }
                }
                .frame(height: 300)
                .padding()
            }
        }
        .onAppear {
            Task {
                await fetchData()
            }
        }
    }

    func fetchData() async {
        do {
            // Fetch latest 5 game logs for the team
            let gameLogsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("teamID", value: teamID.uuidString)
                .order("gameID", ascending: false)
                .limit(5)
                .execute()

            let gameLogs = try JSONDecoder().decode([GameLogtable].self, from: gameLogsResponse.data)

            // Fetch game details
            let gamesResponse = try await supabase
                .from("Game")
                .select("*")
                .execute()

            let games = try JSONDecoder().decode([GameTable].self, from: gamesResponse.data)
            print("asdawdwewerewf'''''''..'.'.'.'.'.'")
            print("Fetched Game Logs: \(gameLogs)")
            
            // Fetch teams
            let teamsResponse = try await supabase
                .from("teams")
                .select("*")
                .execute()

            let teams = try JSONDecoder().decode([TeamTable].self, from: teamsResponse.data)

            // Create mappings for team names and games
            let teamDict = Dictionary(uniqueKeysWithValues: teams.map { ($0.teamID, $0.teamName) })
            let gameDict = Dictionary(uniqueKeysWithValues: games.map { game in
                let team1Name = teamDict[game.team1ID] ?? "Unknown"
                let team2Name = teamDict[game.team2ID] ?? "Unknown"
                return (game.gameID, "\(team1Name) \nvs\n \(team2Name)")
            })

            // Aggregate fouls per game
            var foulCounts: [UUID: Int] = [:]
            //print(foulCounts)

            for log in gameLogs {
                foulCounts[log.gameID, default: 0] += log.fouls
            }
            print(foulCounts)

            // Map data for the bar chart
            gameFouls = foulCounts.map { gameID, totalFouls in
                let gameLabel = gameDict[gameID] ?? "Unknown"
                return (gameLabel: gameLabel, fouls: totalFouls)
            }
            .sorted { $0.gameLabel > $1.gameLabel } // Sort by latest
            
            isLoading = false
            print("Final gameFouls array: \(gameFouls)")

        } catch {
            print("Error fetching data: \(error)")
            isLoading = false
        }
    }
}

