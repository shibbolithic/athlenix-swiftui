import SwiftUI
import Charts
import Supabase

struct GamePointsChartView: View {
    @State private var gameLogs: [GameLogtable] = []
    @State private var games: [GameTable] = []
    @State private var isLoading = true
    @State private var sessionUserID: UUID?

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
                    Text(" ")
                        .font(.headline)
                        .padding(.bottom, 5)

                    Chart {
                        ForEach(latestGameLogs(), id: \.logID) { log in
                            // Stacked bars for different point types
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
                    .chartXAxisLabel(" ")
                    .chartYAxisLabel("Points")
                    .frame(height:200)
                    .padding()
//                    .overlay(
//                        HStack {
//                            LegendItem(color: .blue, text: "2-Pointers")
//                            LegendItem(color: .green, text: "3-Pointers")
//                            LegendItem(color: .orange, text: "Free Throws")
//                        }
//                        .padding(.top, -280), // Moves it closer
//                        alignment: .bottom
//                    )
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

    // Fetch game logs and games from Supabase
    private func fetchGameData() async {
        guard let userID = sessionUserID else { return }
        do {
            let gameLogsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("playerID", value: userID.uuidString)
                .execute()
            gameLogs = try JSONDecoder().decode([GameLogtable].self, from: gameLogsResponse.data)

            let gamesResponse = try await supabase
                .from("Game")
                .select("*")
                .execute()
            games = try JSONDecoder().decode([GameTable].self, from: gamesResponse.data)

            isLoading = false
        } catch {
            print("Error fetching data: \(error)")
            isLoading = false
        }
    }
    
    // Sort game logs by date and return the latest 5 (or fewer if less available)
    private func latestGameLogs() -> [GameLogtable] {
        let sortedLogs = gameLogs.sorted { log1, log2 in
            let date1 = gameDate(for: log1.gameID) ?? Date.distantPast
            let date2 = gameDate(for: log2.gameID) ?? Date.distantPast
            return date1 > date2  // Sort in descending order (latest first)
        }
        return Array(sortedLogs.prefix(10)) // Take only the latest 5 games
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

// Legend UI Component for Color Key
struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(text)
                .font(.caption)
        }
    }
}
