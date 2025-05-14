import Foundation
import Supabase

@MainActor
class MatchHistoryViewModel: ObservableObject {
    @Published var matches: [Match1] = []

    private let supabase = SupabaseClient.shared
    private var teamID: UUID

    init(teamID: UUID) {
        self.teamID = teamID
        Task {
            await fetchGames(for: teamID)
        }
    }

    func fetchGames(for teamID: UUID) async {
        do {
            let response = try await supabase
                .from("GameTable")
                .select("*")
                .or("team1ID.eq.\(teamID.uuidString),team2ID.eq.\(teamID.uuidString)")
                .execute()

            let decoder = JSONDecoder()
            let gameTables = try decoder.decode([GameTable].self, from: response.data)

            var matches: [Match1] = []
            for game in gameTables {
                let team1 = try await fetchTeamDetails(teamID: game.team1ID)
                let team2 = try await fetchTeamDetails(teamID: game.team2ID)

                let match = Match1(
                    teamAName: team1.name,
                    teamALogo: team1.logoName,
                    teamAScore: game.team1finalScore,
                    teamBName: team2.name,
                    teamBLogo: team2.logoName,
                    teamBScore: game.team2finalScore
                )
                matches.append(match)
            }

            self.matches = matches

        } catch {
            print("Error fetching games: \(error)")
        }
    }

    private func fetchTeamDetails(teamID: UUID) async throws -> (name: String, logoName: String) {
        let response = try await supabase
            .from("TeamTable")
            .select("name, logoName")
            .eq("id", value: teamID.uuidString)
            .single()
            .execute()

        struct TeamResponse: Codable {
            let name: String
            let logoName: String
        }

        let decoder = JSONDecoder()
        let team = try decoder.decode(TeamResponse.self, from: response.data)
        return (team.name, team.logoName)
    }
}
