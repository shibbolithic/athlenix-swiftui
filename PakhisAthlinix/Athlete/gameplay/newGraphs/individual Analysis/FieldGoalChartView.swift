import SwiftUI
import Charts

struct GameLogtable1: Codable, Equatable {
    let logID: UUID
    let gameID: UUID
    let teamID: UUID
    let playerID: UUID
    var points2: Int
    var points3: Int
    var freeThrows: Int
    var rebounds: Int
    var assists: Int
    var steals: Int
    var fouls: Int
    var missed2Points: Int
    var missed3Points: Int
    
    var fieldGoalPercentage: Double {
        let totalAttempts = points2 + points3 + missed2Points + missed3Points
        return totalAttempts > 0 ? (Double(points2 + points3) / Double(totalAttempts)) * 100 : 0.0
    }
}

struct GameTable1: Codable, Equatable {
    let gameID: UUID
    var team1ID: UUID
    var team2ID: UUID
    var dateOfGame: String
    var venue: String
    var team1finalScore: Int
    var team2finalScore: Int
}

struct FieldGoalChartView: View {
    @State private var gameLogs: [GameLogtable1] = []
    @State private var games: [GameTable1] = []
    @State private var isLoading = true
    
    var latestFiveGames: [(date: Date, formattedDate: String, fieldGoalPercentage: Double)] {
        let gameLogMap = Dictionary(grouping: gameLogs, by: { $0.gameID })
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Ensure this matches your backend format
        
        return games
            .sorted { $0.dateOfGame > $1.dateOfGame }
            .prefix(25) // Latest 5 games
            .compactMap { game in
                guard let gameDate = dateFormatter.date(from: game.dateOfGame) else { return nil }
                let formattedDate = gameDate.formatted(.dateTime.month(.abbreviated).day(.twoDigits)) // MMM dd format
                
                if let logs = gameLogMap[game.gameID] {
                    let totalFGPercentage = logs.map { $0.fieldGoalPercentage }.reduce(0, +) / Double(logs.count)
                    return (gameDate, formattedDate, totalFGPercentage)
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
                Text("Field Goal % Over Last 5 Games")
                    .font(.title2)
                    .padding()

                Chart(latestFiveGames, id: \.date) { game in
                    LineMark(
                        x: .value("Game", game.formattedDate),
                        y: .value("FG%", game.fieldGoalPercentage)
                    )
                    .foregroundStyle(Color(red: 1.0, green: 0.32, blue: 0.09))
                    .symbol(.circle)
                }
                .chartXAxis {
                    AxisMarks(values: latestFiveGames.map { $0.formattedDate }) { value in
                        AxisValueLabel()
                    }
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
        .ignoresSafeArea()
    }



    func fetchGameData() async {
        isLoading = true
        do {
            guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
                print("Error: No session user is set")
                isLoading = false
                return
            }
            
            let gameLogsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("playerID", value: sessionUserID.uuidString)
                .execute()
            gameLogs = try JSONDecoder().decode([GameLogtable1].self, from: gameLogsResponse.data)
            
            let gamesResponse = try await supabase
                .from("Game")
                .select("*")
                .execute()
            games = try JSONDecoder().decode([GameTable1].self, from: gamesResponse.data)
            
            isLoading = false
        } catch {
            print("Error fetching data: \(error)")
            isLoading = false
        }
    }
}
