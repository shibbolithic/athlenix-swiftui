import SwiftUI
import Charts

struct FoulsBarChartView: View {
    @State private var gameFouls: [(gameLabel: String, fouls: Int)] = []
    @State private var isLoading = true

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
                .chartYAxisLabel(" ")
                .chartXAxisLabel(" ")
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            Text(value.as(String.self) ?? "")
                                .multilineTextAlignment(.center) // Allow multiline
                                .fixedSize(horizontal: false, vertical: true) // Prevent truncation
                                .frame(width: 80) // Adjust width for better spacing
                        }
                    }
                }
                .frame(height: 250)
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
        guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
            print("Error: No session user is set")
            isLoading = false
            return
        }

        do {
            // Fetch latest 8 game logs for the player
            let gameLogsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("playerID", value: sessionUserID.uuidString)
                .order("gameID", ascending: false) // Latest games first
                .limit(8)
                .execute()
            
            let gameLogs = try JSONDecoder().decode([GameLogtable].self, from: gameLogsResponse.data)

            // Fetch game details
            let gamesResponse = try await supabase
                .from("Game")
                .select("*")
                .execute()
            
            let games = try JSONDecoder().decode([GameTable].self, from: gamesResponse.data)

            // Fetch teams
            let teamsResponse = try await supabase
                .from("teams")
                .select("*")
                .execute()
            
            let teams = try JSONDecoder().decode([TeamTable].self, from: teamsResponse.data)

            // Create a mapping of teamID to teamName
            let teamDict = Dictionary(uniqueKeysWithValues: teams.map { ($0.teamID, $0.teamName) })

            // Create a mapping of gameID to "Team1 vs Team2" format
            let gameDict = Dictionary(uniqueKeysWithValues: games.map { game in
                let team1Name = teamDict[game.team1ID] ?? "Unknown"
                let team2Name = teamDict[game.team2ID] ?? "Unknown"
                return (game.gameID, "\(team1Name) \nvs\n \(team2Name)") // Force two-line format
            })

            // Map data for the bar chart
            gameFouls = gameLogs.map { log in
                let gameLabel = gameDict[log.gameID] ?? "Unknown"
                return (gameLabel: gameLabel, fouls: log.fouls)
            }
            .sorted { $0.gameLabel > $1.gameLabel } // Sort by latest

            isLoading = false
        } catch {
            print("Error fetching data: \(error)")
            isLoading = false
        }
    }
}
