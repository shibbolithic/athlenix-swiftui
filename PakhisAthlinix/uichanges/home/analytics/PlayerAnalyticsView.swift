//
//  AnalyticsView.swift
//  swiftCharts
//
//  Created by admin65 on 29/04/25.

import Charts
import SwiftUI

struct PlayerAnalyticsView: View {
    
    @State private var gameLogs: [GameLogtable] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var selectedStartDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var selectedEndDate: Date = Date()
    @State private var showDatePicker: Bool = false

    // Filtered gameLogs based on selected date range
    private var filteredGameLogs: [GameLogtable] {
        gameLogs.filter { log in
            guard let gameDate = log.gameDate else { return true }
            return gameDate >= selectedStartDate && gameDate <= selectedEndDate
        }
    }
    
    // --- Update all computed properties to use filteredGameLogs instead of gameLogs ---
    private var totalPoints: Int {
        filteredGameLogs.reduce(0) { $0 + $1.totalPoints }
    }
    
    private var totalRebounds: Int {
        filteredGameLogs.reduce(0) { $0 + $1.rebounds }
    }
    
    private var totalAssists: Int {
        filteredGameLogs.reduce(0) { $0 + $1.assists }
    }
    
    private var totalSteals: Int {
        filteredGameLogs.reduce(0) { $0 + $1.steals }
    }
    
    private var totalFouls: Int {
        filteredGameLogs.reduce(0) { $0 + $1.fouls }
    }
    
    private var averagePoints: Double {
        guard !filteredGameLogs.isEmpty else { return 0 }
        return Double(totalPoints) / Double(filteredGameLogs.count)
    }
    
    private var shootingPercentage: Double {
        let madeShots = filteredGameLogs.reduce(0) { $0 + $1.points2 + $1.points3 }
        let missedShots = filteredGameLogs.reduce(0) { $0 + $1.missed2Points + $1.missed3Points }
        let totalShots = madeShots + missedShots
        guard totalShots > 0 else { return 0 }
        return (Double(madeShots) / Double(totalShots)) * 100
    }
    
    private var freeThrowsMade: Int {
        filteredGameLogs.reduce(0) { $0 + $1.freeThrows }
    }

    var body: some View {
            VStack(spacing: 0) {
                headerSection
                    .background(Color(.systemBackground))
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        summarySection
                        Divider()
                        topHighlightsSection
                        Divider()
                        pointsLineChart
                        Divider()
                        reboundsAssistsBarChart
                        Divider()
                        shotDistributionPieChart
                        Divider()
                        efficiencyScoreChart
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showDatePicker) {
                datePickerSheet
            }
            .task {
                await loadData()
            }
    }
    
    private func loadData() async {
           do {
               let sessionUserID = try await SessionManager.shared.getSessionUser()
               //let playerID = UUID(uuidString: sessionUserID) ?? UUID()
               gameLogs = try await AnalyticsService.shared.fetchPlayerGameLogs(playerID: sessionUserID!)
           } catch {
               print("Error loading data: \(error)")
           }
       }
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Summary")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                statCard(title: "Total Points", value: "\(totalPoints)")
                statCard(title: "Avg Points", value: String(format: "%.1f", averagePoints))
            }
            
            HStack {
                statCard(title: "Rebounds", value: "\(totalRebounds)")
                statCard(title: "Assists", value: "\(totalAssists)")
                statCard(title: "Steals", value: "\(totalSteals)")
            }
        }
    }

    private var detailedStatsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Detailed Stats")
                .font(.title2)
                .fontWeight(.semibold)
            
            statRow(title: "Total Fouls", value: "\(totalFouls)")
            statRow(title: "Free Throws Made", value: "\(freeThrowsMade)")
        }
    }

    private var shootingPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Shooting Performance")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading) {
                Text("Field Goal %")
                    .font(.subheadline)
                ProgressView(value: shootingPercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                Text(String(format: "%.1f%%", shootingPercentage))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Helper Views
    private func statCard(title: String, value: String) -> some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 5)
    }
    @State private var showMoreHighlights = false

    private var topHighlightsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Top Highlights")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Always visible highlights
                statHighlightRow(title: "Highest Points", value: "\(bestPointsGame) pts")
                statHighlightRow(title: "Most Rebounds", value: "\(bestReboundGame) rebounds")
                statHighlightRow(title: "Most Assists", value: "\(bestAssistGame) assists")

                // Extra highlights (only if showMore is true)
                if showMoreHighlights {
                    statHighlightRow(title: "Most Steals", value: "\(bestStealGame) steals")
                    statHighlightRow(title: "Most Fouls", value: "\(mostFoulsGame) fouls")
                    statHighlightRow(title: "Best Free Throws", value: "\(bestFreeThrowsGame) free throws made")
                    statHighlightRow(title: "Most Missed 2-Points", value: "\(mostMissed2PointsGame) missed 2s")
                    statHighlightRow(title: "Most Missed 3-Points", value: "\(mostMissed3PointsGame) missed 3s")
                }
            }
            .animation(.easeInOut, value: showMoreHighlights)

            Button(action: {
                showMoreHighlights.toggle()
            }) {
                Text(showMoreHighlights ? "Show Less" : "Show More")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.top, 5)
            }
        }
    }

    // MARK: - Highlight Computed Properties
    private var bestPointsGame: Int {
        gameLogs.map { $0.totalPoints }.max() ?? 0
    }

    private var bestReboundGame: Int {
        gameLogs.map { $0.rebounds }.max() ?? 0
    }

    private var bestAssistGame: Int {
        gameLogs.map { $0.assists }.max() ?? 0
    }

    private var bestStealGame: Int {
        gameLogs.map { $0.steals }.max() ?? 0
    }

    private var mostFoulsGame: Int {
        gameLogs.map { $0.fouls }.max() ?? 0
    }

    private var bestFreeThrowsGame: Int {
        gameLogs.map { $0.freeThrows }.max() ?? 0
    }

    private var mostMissed2PointsGame: Int {
        gameLogs.map { $0.missed2Points }.max() ?? 0
    }

    private var mostMissed3PointsGame: Int {
        gameLogs.map { $0.missed3Points }.max() ?? 0
    }

    // MARK: - Helper for Highlight Row
    private func statHighlightRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .font(.headline)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }


//    // Computed properties for highlights
//    private var bestPointsGame: Int {
//        gameLogs.map { $0.totalPoints }.max() ?? 0
//    }
//
//    private var bestReboundGame: Int {
//        gameLogs.map { $0.rebounds }.max() ?? 0
//    }
//
//    private var bestAssistGame: Int {
//        gameLogs.map { $0.assists }.max() ?? 0
//    }
    
    // MARK: - Graph Sections

    private var pointsLineChart: some View {
        VStack(alignment: .leading) {
            Text("Points Over Games")
                .font(.title2)
                .fontWeight(.semibold)

            Chart {
                ForEach(Array(gameLogs.enumerated()), id: \.1.logID) { index, log in
                    LineMark(
                        x: .value("Game", index + 1),
                        y: .value("Points", log.totalPoints)
                    )
                    .foregroundStyle(.blue)
                    .symbol(Circle())
                }
            }
            .frame(height: 200)
        }
    }

    private var reboundsAssistsBarChart: some View {
        VStack(alignment: .leading) {
            Text("Rebounds vs Assists")
                .font(.title2)
                .fontWeight(.semibold)

            Chart {
                ForEach(Array(gameLogs.enumerated()), id: \.1.logID) { index, log in
                    BarMark(
                        x: .value("Game", index + 1),
                        y: .value("Rebounds", log.rebounds)
                    )
                    .foregroundStyle(.green)

                    BarMark(
                        x: .value("Game", index + 1),
                        y: .value("Assists", log.assists)
                    )
                    .foregroundStyle(.orange)
                }
            }
            .frame(height: 200)
        }
    }

    private var shotDistributionPieChart: some View {
        VStack(alignment: .leading) {
            Text("Shot Distribution")
                .font(.title2)
                .fontWeight(.semibold)

            Chart {
                SectorMark(
                    angle: .value("2-Pointers", total2PointsMade),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(.blue)

                SectorMark(
                    angle: .value("3-Pointers", total3PointsMade),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(.purple)

                SectorMark(
                    angle: .value("Free Throws", freeThrowsMade),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(.pink)
            }
            .frame(height: 250)
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Text("Player Analytics")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                showDatePicker.toggle()
            }) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
        }
    }
    private var datePickerSheet: some View {
        NavigationView {
            Form {
                DatePicker("Start Date", selection: $selectedStartDate, displayedComponents: .date)
                DatePicker("End Date", selection: $selectedEndDate, in: selectedStartDate..., displayedComponents: .date)
            }
            .navigationTitle("Select Date Range")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showDatePicker = false
                    }
                }
            }
        }
    }

    // MARK: - Helper Computed properties for Pie Chart

    private var total2PointsMade: Int {
        gameLogs.reduce(0) { $0 + $1.points2 }
    }

    private var total3PointsMade: Int {
        gameLogs.reduce(0) { $0 + $1.points3 }
    }
    
    private var efficiencyScoreChart: some View {
        VStack(alignment: .leading) {
            Text("Efficiency Score")
                .font(.title2)
                .fontWeight(.semibold)

            Chart {
                ForEach(Array(gameLogs.enumerated()), id: \.1.logID) { index, log in
                    LineMark(
                        x: .value("Game", index + 1),
                        y: .value("Efficiency", calculateEfficiency(for: log))
                    )
                    .foregroundStyle(.green)
                    .symbol(.square) // <-- Correct usage here
                }
            }
            .frame(height: 200)
        }
    }

    // Helper function
    private func calculateEfficiency(for log: GameLogtable) -> Int {
        return (log.totalPoints + log.rebounds + log.assists + log.steals - log.fouls)
    }



}

// Example preview
//struct PlayerAnalyticsView_Previews: PreviewProvider {
//    static var previews: some View {
//        let mockData = [
//            GameLogtable(logID: UUID(), gameID: UUID(), teamID: UUID(), playerID: UUID(),
//                         points2: 5, points3: 3, freeThrows: 4, rebounds: 7, assists: 2,
//                         steals: 1, fouls: 2, missed2Points: 4, missed3Points: 2,gameDate: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 20))!),
//            GameLogtable(logID: UUID(), gameID: UUID(), teamID: UUID(), playerID: UUID(),
//                         points2: 8, points3: 1, freeThrows: 6, rebounds: 5, assists: 3,
//                         steals: 2, fouls: 1, missed2Points: 3, missed3Points: 4, gameDate: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 23))!)
//        ]
//        PlayerAnalyticsView(gameLogs: mockData)
//    }
//
//}

