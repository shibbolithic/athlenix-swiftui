import SwiftUI
import Charts

struct PointsScoredChart: View {
    let gameLogs: [GameLogtable]
    let games: [GameTable]

    var chartData: [(Int, Int)] {
        let sortedLogs = gameLogs
            .compactMap { log -> (String, Int)? in
                guard let game = games.first(where: { $0.gameID == log.gameID }) else { return nil }
                return (game.dateOfGame, log.totalPoints + log.freeThrows)
            }
            .sorted { $0.0 < $1.0 } // Sort by game date

        let last10Games = sortedLogs.suffix(10) // Get last 10 games

        return Array(last10Games.enumerated().map { index, game in
            (index + 1, game.1) // X-axis: Game Index (1 to 10)
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
