import SwiftUI

struct Match: Identifiable {
    let id = UUID()
    let teamAName: String
    let teamALogo: String
    let teamAScore: Int
    
    let teamBName: String
    let teamBLogo: String
    let teamBScore: Int
    
    let player3Pointers: Int
    let playerFreeThrows: Int
}

struct MatchHistoryView: View {
    let matches: [Match]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(matches) { match in
                    MatchCard(match: match)
                }
            }
            .padding()
        }
        .navigationTitle("Match History")
        .background(Color(.systemGroupedBackground))
    }
}

struct MatchCard: View {
    let match: Match
    
    var body: some View {
        VStack(spacing: 12) {
            // Teams and Scores
            HStack {
                VStack {
                    Image(match.teamALogo)
                        .resizable()
                        .frame(width: 40, height: 40)
                    Text(match.teamAName)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(match.teamAScore) - \(match.teamBScore)")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    Text("Final Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Image(match.teamBLogo)
                        .resizable()
                        .frame(width: 40, height: 40)
                    Text(match.teamBName)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }

            Divider()

            // Player Stats
            HStack(spacing: 24) {
                StatBox(label: "3 Pointers", value: "\(match.player3Pointers)")
                StatBox(label: "Free Throws", value: "\(match.playerFreeThrows)")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .gray.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

struct StatBox: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(.blue)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}
