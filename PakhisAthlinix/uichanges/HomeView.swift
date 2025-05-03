//
//  HomeView.swift
//  PakhisAthlinix
//
//  Created by admin65 on 26/04/25.
//


import SwiftUI
import Charts

struct HomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // MARK: - Scoring Efficiency Chart
                        VStack(alignment: .leading) {
                            Text("Scoring Efficiency")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart {
                                ForEach(sampleChartData) { point in
                                    LineMark(
                                        x: .value("Date", point.date),
                                        y: .value("Score", point.value)
                                    )
                                    .interpolationMethod(.catmullRom)
                                }
                            }
                            .chartYScale(domain: 0...100)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day, count: 2)) {
                                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                                }
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                        }
                        
                        // MARK: - Summary Cards
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                SummaryCard(title: "Points Per Game", value: "9.8")
                                SummaryCard(title: "Rebound Blocks", value: "0.8")
                            }
                            .padding(.horizontal)
                        }
                        
                        // MARK: - Quick Actions
                        VStack(alignment: .leading) {
                            Text("Quick Actions")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 24) {
                                    QuickActionButton(icon: "square.grid.2x2", label: "Add Post")
                                    QuickActionButton(icon: "medal", label: "Add Game")
                                    QuickActionButton(icon: "person.3", label: "Add Team")
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // MARK: - Best Match
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Best Match")
                                .font(.title3.bold())
                                .padding(.horizontal)
                            
                            BestMatchCard()
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
                .navigationTitle("Hey, Isha 👋")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    }
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }.tag(0)
            
            Text("Explore")
                .tabItem {
                    Label("Explore", systemImage: "globe")
                }.tag(1)
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }.tag(2)
        }
    }
}

// MARK: - Sample Data

struct ChartPoint: Identifiable {
    var id = UUID()
    var date: Date
    var value: Double
}

let sampleChartData: [ChartPoint] = [
    ChartPoint(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, value: 65),
    ChartPoint(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, value: 72),
    ChartPoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, value: 78),
    ChartPoint(date: Date(), value: 88)
]

// MARK: - Components

struct SummaryCard: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2.bold())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.primary.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct QuickActionButton: View {
    var icon: String
    var label: String
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

struct BestMatchCard: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "flame.fill") // placeholder for logo
                    .resizable()
                    .frame(width: 32, height: 32)
                Spacer()
                Text("Force VS Suns")
                    .font(.headline)
                Spacer()
                Image(systemName: "sun.max.fill") // placeholder for logo
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            
            Divider()
            
            VStack(spacing: 8) {
                StatRow(label: "Field Goals", left: "61", right: "6", highlightLeft: true)
                StatRow(label: "3P Field Goals", left: "9", right: "3", highlightLeft: true)
                StatRow(label: "Free Throws", left: "10", right: "5", highlightLeft: true)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.primary.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatRow: View {
    var label: String
    var left: String
    var right: String
    var highlightLeft: Bool
    
    var body: some View {
        HStack {
            Text(left)
                .font(.subheadline)
                .foregroundColor(highlightLeft ? .green : .primary)
                .frame(width: 50, alignment: .leading)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
            Text(right)
                .font(.subheadline)
                .foregroundColor(!highlightLeft ? .green : .primary)
                .frame(width: 50, alignment: .trailing)
        }
    }
}

#Preview {
    HomeView()
}
