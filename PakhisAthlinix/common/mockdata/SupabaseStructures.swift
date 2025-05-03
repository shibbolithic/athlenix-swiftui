//
//  SupabaseStructures.swift
//  PakhisAthlinix
//
//  Created by admin65 on 27/12/24.
//
import Foundation

enum Role: String, Codable, CaseIterable {
    case athlete
    case coach
}

struct Usertable: Codable, Equatable {
    let userID: UUID
    let createdAt: String
    let username: String
    let name: String
    let email: String
    let password: String
    let profilePicture: String?
    let coverPicture: String?
    let bio: String?
    let dateJoined: String
    let lastLogin: String
    let role: Role
}

enum positions: String, Codable, CaseIterable {
       case pointGuard = "Point Guard"
       case shootingGuard = "Shooting Guard"
       case smallForward = "Small Forward"
       case powerForward = "Power Forward"
       case center = "Centre"
}

struct AthleteProfileUpdate: Encodable {
    var position: String?
    var height: Int?
    var weight: Int?
}

struct AthleteProfileTable : Codable, Equatable{
    let athleteID : UUID
    let height : Float
    let weight: Float
    let experience: Int
    let position: positions
    let averagePointsPerGame: Float
    let averageReboundsPerGame: Float
    let averageAssistsPerGame: Float
    
}

struct CoachProfileTable : Codable, Equatable{
    let coachID : UUID
    let yearsOfExperience: Int
    let specialization: String
    let certification: String
}

struct TeamTable: Codable, Equatable {
    let teamID: UUID
    let dateCreated: String
    let teamName: String
    let teamMotto: String?
    let teamLogo: String?
    let createdBy: UUID
}

struct TeamMembershipTable: Codable, Equatable {
    let membershipID: UUID
    let teamID: UUID
    let userID: UUID
    let roleInTeam: Role
    let dateJoined: String
}

struct GameLogtable: Codable, Equatable {
    let logID: UUID
    let gameID: UUID
    let teamID: UUID
    let playerID: UUID
    var points2: Int
    var points3: Int
    var freeThrows: Int
    var rebounds: Int
    var assists: Int
    var steals: Int
    var fouls: Int
    var missed2Points: Int
    var missed3Points: Int
    var totalPoints: Int {
        return points2 * 2 + points3 * 3
    }
}


struct GameTable: Codable, Equatable{
    let gameID: UUID
    var team1ID: UUID
    var team2ID: UUID
    var dateOfGame: String
    var venue: String
    var team1finalScore: Int
    var team2finalScore: Int
}

struct PostsTable:Codable, Equatable{
    let postID: UUID
    let createdBy: UUID // User ID
    var content: String?
    var image1: String
    var image2: String
    var image3: String
    var linkedGameID: UUID? // Nullable
    var likes: Int
}

struct PostsTableExplore:Codable, Equatable{
    let postID: UUID
    let createdBy: UUID // User ID
    var content: String?
    var image1: String
    var image2: String
    var image3: String
    var createdAt: String
    var linkedGameID: UUID? // Nullable
    var likes: Int
}

struct PendingGameTable: Codable {
    let gameID: UUID
    let team1ID: UUID
    let team2ID: UUID
    let dateOfGame: String
    let venue: String
    let team1finalScore: Int
    let team2finalScore: Int
    let status: String // "pending", "approved", "rejected"
    let team1coachID: UUID // The coach who needs to approve
    let team2coachID: UUID?
    let team1CoachApproval: Bool? // nil = pending, true = approved, false = rejected
    let team2CoachApproval: Bool?
}

struct PendingGameLogTable: Codable {
    let logID: UUID
    let gameID: UUID
    let teamID: UUID
    let playerID: UUID
    let points2: Int
    let points3: Int
    let freeThrows: Int
    let rebounds: Int
    let assists: Int
    let steals: Int
    let fouls: Int
    let missed2Points: Int
    let missed3Points: Int
}

struct TeamTableCoach: Codable, Equatable {
    let teamID: UUID
    let dateCreated: String
    let teamName: String
    let teamWins: Int
    let teamLosses: Int
    let teamMotto: String?
    let teamLogo: String?
    let createdBy: UUID
}

// MARK:   DON'T USE
struct tempCoach: Codable, Equatable{
    var teamCoachID:UUID
    var createrID: UUID
    var coach1ID: UUID
    var coach2ID: UUID
}

struct Player {
    var name: String
    var reb: Int // Rebounds
    var ast: Int // Assists
    var stl: Int // Steals
    var foul: Int // Fouls
    var pts: Int // Points
    var points3: Int
    var freeThrows: Int
    var missed2Points: Int
    var missed3Points: Int
    var totalPoints: Int {
        return pts * 2 + points3 * 3
    }
}


struct Team {
    var name: String
    var players: [Player]
}

//struct AthleteProfileUpdate: Encodable {
//    var position: Int?  // Change this to Int if Supabase expects an Int
//    var height: Int?
//    var weight: Int?
//}

//
//
//let heightRange = Array(140...220) // Height in cm
//let weightRange = Array(40...150) // Weight in kg
//
//import Foundation
//
//struct Game11: Codable {
//    let gameID: String
//    let team1ID: String
//    let team2ID: String
//    let dateOfGame: String
//    let venue: String
//    let team1FinalScore: Int
//    let team2FinalScore: Int
//}
//
//struct GameLog11: Codable {
//    let logID: String
//    let gameID: String
//    let teamID: String
//    let playerID: String
//    let points2: Int
//    let points3: Int
//    let freeThrows: Int
//    let rebounds: Int
//    let assists: Int
//    let steals: Int
//    let fouls: Int
//    let missed2Points: Int
//    let missed3Points: Int
//    let totalPoints: Int
//}
//
//struct Team11: Codable {
//    let teamID: String
//    let dateCreated: Date
//    let teamName: String
//    let teamMotto: String
//    let teamLogo: String
//    let createdBy: String
//}
//
//struct User11: Codable {
//    let userID: String
//    let username: String
//    let name: String
//    let email: String
//    let password: String
//    let profilePicture: String
//    let coverPicture: String?
//    let bio: String?
//    let dateJoined: Date
//    let lastLogin: Date
//    let role: String
//    let createdAt: Date
//}

//}
//
//func fetchBestMatch(forPlayerID playerID: String) async throws -> Game11? {
//    // Fetch GameLogs for the player
//    let gameLogsResponse = try await supabase
//        .from("GameLog")
//        .select("gameID, totalPoints")
//        .eq("playerID", value: playerID)
//        .execute()
//    
//    guard let playerGameLogs = gameLogsResponse.data as? [[String: Any]] else {
//        return nil
//    }
//    
//    // Extract game IDs
//    let playerGameIDs = playerGameLogs.compactMap { $0["gameID"] as? String }
//    
//    // Fetch Games for the extracted game IDs
//    let gamesResponse = try await supabase
//        .from("Game")
//        .select("*")
//        .in("gameID", values: playerGameIDs)
//        .execute()
//    
//    guard let playerGames = gamesResponse.data as? [[String: Any]] else {
//        return nil
//    }
//    
//    // Find the best game based on the highest total points scored
//    var bestGame: [String: Any]?
//    var maxPoints = 0
//    
//    for game in playerGames {
//        guard let gameID = game["gameID"] as? String else { continue }
//        
//        // Filter logs for the current game
//        let teamLogs = playerGameLogs.filter { $0["gameID"] as? String == gameID }
//        let teamPoints = teamLogs.reduce(0) { $0 + ($1["totalPoints"] as? Int ?? 0) }
//        
//        if teamPoints > maxPoints {
//            maxPoints = teamPoints
//            bestGame = game
//        }
//    }
//    
//    // Convert the best game to a Game object
//    guard let bestGameData = bestGame else { return nil }
//    return Game(
//        gameID: bestGameData["gameID"] as? String ?? "",
//        team1ID: bestGameData["team1ID"] as? String ?? "",
//        team2ID: bestGameData["team2ID"] as? String ?? "",
//        dateOfGame: bestGameData["dateOfGame"] as? String ?? "",
//        venue: bestGameData["venue"] as? String ?? "",
//        team1FinalScore: bestGameData["team1FinalScore"] as? Int ?? 0,
//        team2FinalScore: bestGameData["team2FinalScore"] as? Int ?? 0
//    )
//}
