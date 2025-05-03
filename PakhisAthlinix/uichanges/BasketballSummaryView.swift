//
//  BasketballSummaryView.swift
//  PakhisAthlinix
//
//  Created by admin65 on 26/04/25.
//


import SwiftUI

struct BasketballSummaryView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 🏠 Top Section
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Monday, Apr 26")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text("Welcome back, Akshita!")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Image(uiImage: UIImage(named: "avatarPlaceholder") ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // 📊 Key Metrics Overview
                    VStack(alignment: .leading, spacing: 16) {
                        EfficiencyRingView(title: "2-Point Efficiency", value: 58)
                        EfficiencyRingView(title: "3-Point Efficiency", value: 42)
                        EfficiencyRingView(title: "Free-Throw Efficiency", value: 85)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .background(Color.gray)
                        .padding(.horizontal)
                    
                    // 🏀 Aggregate Stats
                    HStack {
                        StatBoxView(title: "Total Games Played", value: "12")
                        Spacer()
                        StatBoxView(title: "Total Points Scored", value: "324")
                    }
                    .padding(.horizontal)
                    
                    // 📅 Recent Matches
                    VStack(spacing: 8) {
                        HStack {
                            Text("Recent Matches")
                                .font(.title2)
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: {}) {
                                Text("Show More")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            MatchCardView(homeTeam: "Lakers", homeScore: 102, awayTeam: "Warriors", awayScore: 98, date: "Today")
                            MatchCardView(homeTeam: "Celtics", homeScore: 110, awayTeam: "Bulls", awayScore: 104, date: "Sunday")
                            MatchCardView(homeTeam: "Heat", homeScore: 97, awayTeam: "Nets", awayScore: 101, date: "Saturday")
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 80) // Extra padding for tab bar space
            }
            .background(Color.black.ignoresSafeArea())
            .tag(0)
            .tabItem {
                Image(systemName: "house.fill")
                Text("Summary")
            }
            
            Text("Explore")
                .background(Color.black.ignoresSafeArea())
                .foregroundColor(.white)
                .tag(1)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }
            
            Text("Profile")
                .background(Color.black.ignoresSafeArea())
                .foregroundColor(.white)
                .tag(2)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.green) // Selected tab color
    }
}

// MARK: - Components

struct EfficiencyRingView: View {
    var title: String
    var value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            Text("\(value)%")
                .font(.title3)
                .bold()
                .foregroundColor(.white)
            ProgressView(value: Double(value) / 100)
                .progressViewStyle(LinearProgressViewStyle(tint: colorForValue(value)))
                .frame(height: 8)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(4)
        }
    }
    
    private func colorForValue(_ value: Int) -> Color {
        if value > 50 {
            return .green
        } else if value >= 30 {
            return .yellow
        } else {
            return .red
        }
    }
}

struct StatBoxView: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(.white)
        }
    }
}

struct MatchCardView: View {
    var homeTeam: String
    var homeScore: Int
    var awayTeam: String
    var awayScore: Int
    var date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading) {
                    Text(homeTeam)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(homeScore)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading) {
                    Text(awayTeam)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(awayScore)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            Text(date)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.darkGray))
        .cornerRadius(16)
    }
}

// MARK: - Preview

struct BasketballSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        BasketballSummaryView()
    }
}
