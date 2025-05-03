import SwiftUI
import Charts

struct teamPointsScoredChart: View {
    let gameLogs: [GameLogtable]
    let games: [GameTable]
    let teamID: UUID // Added to filter by team

    var chartData: [(Int, Int)] {
        let filteredLogs = gameLogs
            .filter { $0.teamID == teamID } // Filter by team ID
            .compactMap { log -> (String, Int)? in
                guard let game = games.first(where: { $0.gameID == log.gameID }) else { return nil }
                return (game.dateOfGame, log.totalPoints + log.freeThrows)
            }
            .sorted { $0.0 < $1.0 } // Sort by game date

        let last5Games = filteredLogs.suffix(5) // Get last 5 games

        return Array(last5Games.enumerated().map { index, game in
            (index + 1, game.1) // X-axis: Game Index (1 to 5)
        })
    }

    var body: some View {
        VStack {
            Chart {
                ForEach(chartData, id: \.0) { game in
                    LineMark(
                        x: .value("Game", game.0),
                        y: .value("Points", game.1)
                    )
                    .foregroundStyle(Color(red: 1.0, green: 0.32, blue: 0.09)) // ✅ #FF5116 color
                    .symbol(.circle)
                }
            }
            .chartXAxisLabel("Games")
            .chartYAxisLabel("Points")
            .chartYScale(domain: 0...(chartData.map { $0.1 }.max() ?? 10))
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisTick() // ✅ Keeps the small tick marks
                }
            }
            .chartYAxis {
                AxisMarks() { value in
                    AxisTick() // ✅ Keeps the tick marks
                    AxisGridLine() // ✅ Keeps the grid
                    AxisValueLabel() // ✅ Keeps Y-axis labels on the right side
                }
            }
            .frame(height: 180)
            .padding()
        }
    }
}
