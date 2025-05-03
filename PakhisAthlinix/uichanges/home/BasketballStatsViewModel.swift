import Foundation
import Supabase

@MainActor
class BasketballStatsViewModel: ObservableObject {
    @Published var gameLogs: [GameLogtable] = []
    @Published var games: [GameTable] = []
    @Published var recentMatches: [GameTable] = []
    @Published var teamNames: [TeamTable] = []

    @Published var totalGamesPlayed: Int = 0
    @Published var totalPointsScored: Int = 0
    @Published var avg2PointEfficiency: Int = 0
    @Published var avg3PointEfficiency: Int = 0
    @Published var avgFreeThrowEfficiency: Int = 0

    //private let supabase = SupabaseClient.shared

    func fetchStats(for playerID: UUID) async {
        do {
            let response = try await supabase.from("GameLog").select("*").eq("playerID", value: playerID.uuidString).execute()
            let decoder = JSONDecoder()
            let logs = try decoder.decode([GameLogtable].self, from: response.data)
            self.gameLogs = logs

            totalGamesPlayed = logs.count
            totalPointsScored = logs.reduce(0) { $0 + $1.totalPoints }

            if logs.count > 0 {
                avg2PointEfficiency = Int(logs.reduce(0) { $0 + $1.points2 } * 100 / max(logs.reduce(0) { $0 + $1.points2 + $1.missed2Points }, 1))
                avg3PointEfficiency = Int(logs.reduce(0) { $0 + $1.points3 } * 100 / max(logs.reduce(0) { $0 + $1.points3 + $1.missed3Points }, 1))
                avgFreeThrowEfficiency = Int(logs.reduce(0) { $0 + $1.freeThrows } * 100 / (logs.count * 2)) // assuming 2 FT/game
            }

        } catch {
            print("Error fetching game logs: \(error)")
        }
    }

    func fetchGames(for teamID: UUID) async {
        do {
            let response = try await supabase.from("GameTable").select("*").or("team1ID.eq.\(teamID.uuidString),team2ID.eq.\(teamID.uuidString)").execute()
            let decoder = JSONDecoder()
            self.games = try decoder.decode([GameTable].self, from: response.data)
        } catch {
            print("Error fetching games: \(error)")
        }
    }
    
    //@Published var recentMatches: [GameTable] = []

    func fetchRecentMatches(for playerID: UUID) async {
        do {
          //  let supabase = SupabaseClient.shared
            
            let gameLogsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("playerID", value: playerID.uuidString)
                .execute()
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let gameLogsData = gameLogsResponse.data
            let playerGameLogs = try decoder.decode([GameLogtable].self, from: gameLogsData)
            
            let playerGameIDs = Array(Set(playerGameLogs.map { $0.gameID }))
            
            let gamesResponse = try await supabase
                .from("Game")
                .select("*")
                .in("gameID", values: playerGameIDs)
                .execute()
            
            let gamesData = gamesResponse.data
            var playerGames = try decoder.decode([GameTable].self, from: gamesData)
            
            playerGames.sort {
                guard
                    let date1 = ISO8601DateFormatter().date(from: $0.dateOfGame),
                    let date2 = ISO8601DateFormatter().date(from: $1.dateOfGame)
                else { return false }
                return date1 > date2
            }
            
            self.recentMatches = Array(playerGames.prefix(5))
            
            
        } catch {
            print("Error fetching recent matches: \(error)")
        }
    }
    
//    private func fetchTeamNames() async {
//        do {
//            let response = try await supabase.from("teams").select("*").execute()
//            let teams = try JSONDecoder().decode([TeamTable].self, from: response.data)
//            
//            var names = [UUID: String]()
//            for team in teams {
//                names[team.teamID] = team.teamName
//            }
//            
//            self.teamNames = names
//        } catch {
//            print("Error fetching teams: \(error)")
//        }
//    }


}
