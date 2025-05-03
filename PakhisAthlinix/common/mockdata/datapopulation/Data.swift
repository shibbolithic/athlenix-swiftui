//
//  Untitled.swift
//  AkshitasAthlinix
//
//  Created by admin65 on 13/12/24.
//

import Foundation

// Athlinix Data Model Implementation in Swift
enum UserRole : Decodable {
    case athlete
    case coach
}

// MARK: - User
class Users{
    let userID: String
    var username: String
    var name: String
    var email: String
    var password: String
    var role: UserRole // "Athlete" or "Coach"
    var profilePicture: String
    var coverPicture: String?
    var bio: String
    var dateJoined: Date
    var lastLogin: Date?

    init(userID: String, username: String, name: String, email: String, password: String, role: UserRole, profilePicture: String, coverPicture: String? = nil, bio: String, dateJoined: Date, lastLogin: Date? = nil) {
        self.userID = userID
        self.username = username
        self.name = name
        self.email = email
        self.password = password
        self.role = role
        self.profilePicture = profilePicture
        self.coverPicture = coverPicture
        self.bio = bio
        self.dateJoined = dateJoined
        self.lastLogin = lastLogin
    }
}

// MARK: - Athlete Profile
class AthleteProfile: Decodable {
    let athleteID: String // User ID
    var height: Double
    var weight: Double
    var experience: Int
    var position: String
    var averagePointsPerGame: Double
    var averageReboundsPerGame: Double
    var averageAssistsPerGame: Double

    init(athleteID: String, height: Double, weight: Double, experience: Int, position: String, averagePointsPerGame: Double, averageReboundsPerGame: Double, averageAssistsPerGame: Double) {
        self.athleteID = athleteID
        self.height = height
        self.weight = weight
        self.experience = experience
        self.position = position
        self.averagePointsPerGame = averagePointsPerGame
        self.averageReboundsPerGame = averageReboundsPerGame
        self.averageAssistsPerGame = averageAssistsPerGame
    }
}

// MARK: - Coach Profile
//class CoachProfile {
//    let coachID: String // User ID
//    var yearsOfExperience: Int
//    var specialization: String
//    var certification: String // Image URL or File Path
//
//    init(coachID: String, yearsOfExperience: Int, specialization: String, certification: String) {
//        self.coachID = coachID
//        self.yearsOfExperience = yearsOfExperience
//        self.specialization = specialization
//        self.certification = certification
//    }
//}

// MARK: - Team
class Teams: Decodable {
    let teamID: String
    var teamName: String
    var teamMotto: String
    var teamLogo: String
    var createdBy: String // Coach User ID
    var dateCreated: Date

    init(teamID: String, teamName: String, teamMotto: String, teamLogo: String, createdBy: String, dateCreated: Date) {
        self.teamID = teamID
        self.teamName = teamName
        self.teamMotto = teamMotto
        self.teamLogo = teamLogo
        self.createdBy = createdBy
        self.dateCreated = dateCreated
    }
}


// MARK: - Team Membership
struct TeamMembership {
    let membershipID: String
    let teamID: String
    let userID: String
    var roleInTeam: String // "Player" or "Coach"
    var dateJoined: Date
}

// MARK: - Game
class Game {
    let gameID: String
    var team1ID: String
    var team2ID: String
    var dateOfGame: Date
    var venue: String
    var finalScore: String

    init(gameID: String, team1ID: String, team2ID: String, dateOfGame: Date, venue: String, finalScore: String) {
        self.gameID = gameID
        self.team1ID = team1ID
        self.team2ID = team2ID
        self.dateOfGame = dateOfGame
        self.venue = venue
        self.finalScore = finalScore
    }
    // Function to update final score based on team and game logs
        func updateFinalScore(teamID: String, gameLogs: [GameLog]) {
            let teamLogs = gameLogs.filter { $0.gameID == gameID && $0.teamID == teamID }
            
            let totalPointsForTeam = teamLogs.reduce(0) { $0 + $1.totalPoints }
            
            // Here, the final score is saved as a string representing the team's total points.
            self.finalScore = "\(totalPointsForTeam)"
        }
}

// MARK: - Game Log
struct GameLog {
    let logID: String
    let gameID: String
    let teamID: String
    let playerID: String
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

// MARK: - Post
struct Post {
    let postID: String
    let createdBy: String // User ID
    var content: String?
    var image1: String
    var image2: String
    var image3: String
    var linkedGameID: String? // Nullable
    var dateCreated: Date
    var likes: Int
}

enum ApprovalStatus{
  case Pending
  case Approved
  case Rejected
}
// MARK: - Score Approval
struct ScoreApproval {
    let approvalID: String
    let gameID: String
    let requestedBy: String // Athlete ID
    let approvedBy: String // Coach ID
    var approvalStatus: ApprovalStatus
    var dateRequested: Date
    var dateApproved: Date?
}

