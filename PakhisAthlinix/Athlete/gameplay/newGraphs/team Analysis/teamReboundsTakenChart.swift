//
//  ReboundsTakenChart.swift
//  PakhisAthlinix
//
//  Created by admin65 on 11/03/25.
//


import SwiftUI
import Charts

struct teamReboundsTakenChart: View {
    let gameLogs: [GameLogtable]
    let games: [GameTable]
    let teamID: UUID

    var chartData: [(Int, Int)] {
        // Filter logs for the given team
        let filteredLogs = gameLogs.filter { $0.teamID == teamID }

        // Group by gameID and sum rebounds for all players in that game
        let gameRebounds = Dictionary(grouping: filteredLogs) { $0.gameID }
            .compactMapValues { logs in
                logs.reduce(0) { $0 + $1.rebounds }
            }

        // Map gameID to game date
        let sortedLogs = gameRebounds.compactMap { gameID, totalRebounds -> (String, Int)? in
            guard let game = games.first(where: { $0.gameID == gameID }) else { return nil }
            return (game.dateOfGame, totalRebounds)
        }
        .sorted { $0.0 < $1.0 } // Sort by game date

        let last5Games = sortedLogs.suffix(5) // Get last 5 games

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
                        y: .value("Rebounds", game.1)
                    )
                    .foregroundStyle(Color(red: 1.0, green: 0.32, blue: 0.09)) // Change color for rebounds
                    .symbol(.circle)
                }
            }
            .chartYScale(domain: 0...(chartData.map { $0.1 }.max() ?? 10))
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisTick()
                }
            }
            .chartYAxis {
                AxisMarks() { value in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 70)
            .padding()
        }
    }
}
