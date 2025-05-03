//
//  ReboundsTakenChart.swift
//  PakhisAthlinix
//
//  Created by admin65 on 11/03/25.
//


import SwiftUI
import Charts

struct ReboundsTakenChart: View {
    let gameLogs: [GameLogtable]
    let games: [GameTable]

    var chartData: [(Int, Int)] {
        let sortedLogs = gameLogs
            .compactMap { log -> (String, Int)? in
                guard let game = games.first(where: { $0.gameID == log.gameID }) else { return nil }
                return (game.dateOfGame, log.rebounds) // Using rebounds instead of points
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
