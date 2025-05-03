//
//  game.swift
//  AkshitasAthlinix
//
//  Created by admin65 on 13/12/24.
//
import Foundation
import UIKit

// Sample Data for Games and GameLogs

// Function to create games with definite dates
func createGames() -> [Game] {
    // Define a custom date formatter for creating definite dates
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    // Create specific dates for each game
    let game1Date = dateFormatter.date(from: "2024-08-01")!
    let game2Date = dateFormatter.date(from: "2024-09-02")!
    let game3Date = dateFormatter.date(from: "2024-10-03")!
    let game4Date = dateFormatter.date(from: "2024-11-04")!
    let game5Date = dateFormatter.date(from: "2024-12-05")!
    
    // Initialize game instances with definite dates
    return [
        Game(gameID: "game1", team1ID: "1", team2ID: "2", dateOfGame: game1Date, venue: "Arena 1", finalScore: "20"),
        Game(gameID: "game2", team1ID: "3", team2ID: "4", dateOfGame: game2Date, venue: "Stadium 1", finalScore: "40"),
        Game(gameID: "game3", team1ID: "5", team2ID: "1", dateOfGame: game3Date, venue: "Arena 2", finalScore: "162"),
        Game(gameID: "game4", team1ID: "2", team2ID: "3", dateOfGame: game4Date, venue: "Stadium 2", finalScore: ""),
        Game(gameID: "game5", team1ID: "4", team2ID: "5", dateOfGame: game5Date, venue: "Arena 3", finalScore: "")
    ]
}

let games = createGames()

func updateScoresForAllGames() {
    for game in games {
        // Update final score for both teams in each game
        game.updateFinalScore(teamID: game.team1ID, gameLogs: gameLogs)
        game.updateFinalScore(teamID: game.team2ID, gameLogs: gameLogs)
    }
}
// Sample Data for GameLogs (using player IDs, team IDs, and game IDs from earlier)
var gameLogs: [GameLog] = [
    // Game 1: Red Warriors vs Blue Sharks
    GameLog(logID: "log1", gameID: "game1", teamID: "1", playerID: "1", points2: 10, points3: 2, freeThrows: 3, rebounds: 4, assists: 2, steals: 1, fouls: 1, missed2Points: 2, missed3Points: 1),
    GameLog(logID: "log2", gameID: "game1", teamID: "1", playerID: "2", points2: 12, points3: 3, freeThrows: 4, rebounds: 5, assists: 3, steals: 2, fouls: 0, missed2Points: 1, missed3Points: 0),
    GameLog(logID: "log3", gameID: "game1", teamID: "2", playerID: "3", points2: 8, points3: 1, freeThrows: 2, rebounds: 3, assists: 2, steals: 0, fouls: 1, missed2Points: 1, missed3Points: 1),
    GameLog(logID: "log4", gameID: "game1", teamID: "2", playerID: "4", points2: 7, points3: 2, freeThrows: 1, rebounds: 4, assists: 1, steals: 1, fouls: 2, missed2Points: 3, missed3Points: 0),

    // Game 2: Golden Eagles vs Silver Lions
    GameLog(logID: "log5", gameID: "game2", teamID: "3", playerID: "1", points2: 9, points3: 0, freeThrows: 2, rebounds: 6, assists: 2, steals: 3, fouls: 0, missed2Points: 1, missed3Points: 1),
    GameLog(logID: "log6", gameID: "game2", teamID: "3", playerID: "2", points2: 10, points3: 1, freeThrows: 3, rebounds: 3, assists: 1, steals: 0, fouls: 1, missed2Points: 0, missed3Points: 0),
    GameLog(logID: "log7", gameID: "game2", teamID: "4", playerID: "3", points2: 5, points3: 3, freeThrows: 4, rebounds: 2, assists: 2, steals: 1, fouls: 2, missed2Points: 2, missed3Points: 0),
    GameLog(logID: "log8", gameID: "game2", teamID: "4", playerID: "4", points2: 11, points3: 0, freeThrows: 1, rebounds: 5, assists: 4, steals: 1, fouls: 1, missed2Points: 0, missed3Points: 1),

    // Game 3: Green Panthers vs Red Warriors
    GameLog(logID: "log9", gameID: "game3", teamID: "5", playerID: "1", points2: 6, points3: 2, freeThrows: 5, rebounds: 3, assists: 1, steals: 2, fouls: 1, missed2Points: 0, missed3Points: 0),
    GameLog(logID: "log10", gameID: "game3", teamID: "5", playerID: "2", points2: 8, points3: 1, freeThrows: 3, rebounds: 4, assists: 3, steals: 0, fouls: 2, missed2Points: 1, missed3Points: 1),
    GameLog(logID: "log11", gameID: "game3", teamID: "1", playerID: "3", points2: 4, points3: 0, freeThrows: 1, rebounds: 2, assists: 1, steals: 1, fouls: 0, missed2Points: 1, missed3Points: 0),
    GameLog(logID: "log12", gameID: "game3", teamID: "1", playerID: "4", points2: 9, points3: 1, freeThrows: 4, rebounds: 3, assists: 2, steals: 1, fouls: 1, missed2Points: 0, missed3Points: 0),

    // Game 4: Blue Sharks vs Golden Eagles
    GameLog(logID: "log13", gameID: "game4", teamID: "2", playerID: "1", points2: 7, points3: 3, freeThrows: 2, rebounds: 3, assists: 2, steals: 1, fouls: 0, missed2Points: 1, missed3Points: 1),
    GameLog(logID: "log14", gameID: "game4", teamID: "2", playerID: "2", points2: 6, points3: 2, freeThrows: 4, rebounds: 3, assists: 1, steals: 0, fouls: 1, missed2Points: 1, missed3Points: 1),
    GameLog(logID: "log15", gameID: "game4", teamID: "3", playerID: "3", points2: 5, points3: 0, freeThrows: 2, rebounds: 4, assists: 1, steals: 2, fouls: 1, missed2Points: 1, missed3Points: 0),
    GameLog(logID: "log16", gameID: "game4", teamID: "3", playerID: "4", points2: 8, points3: 1, freeThrows: 3, rebounds: 3, assists: 2, steals: 0, fouls: 0, missed2Points: 0, missed3Points: 0),

    // Game 5: Silver Lions vs Green Panthers
    GameLog(logID: "log17", gameID: "game5", teamID: "4", playerID: "1", points2: 9, points3: 2, freeThrows: 3, rebounds: 4, assists: 2, steals: 1, fouls: 1, missed2Points: 0, missed3Points: 1),
    GameLog(logID: "log18", gameID: "game5", teamID: "4", playerID: "2", points2: 40, points3: 1, freeThrows: 2, rebounds: 5, assists: 3, steals: 0, fouls: 0, missed2Points: 0, missed3Points: 1),
    GameLog(logID: "log19", gameID: "game5", teamID: "5", playerID: "3", points2: 7, points3: 0, freeThrows: 3, rebounds: 2, assists: 1, steals: 2, fouls: 2, missed2Points: 1, missed3Points: 1),
    GameLog(logID: "log20", gameID: "game5", teamID: "5", playerID: "4", points2: 6, points3: 1, freeThrows: 4, rebounds: 3, assists: 2, steals: 1, fouls: 0, missed2Points: 0, missed3Points: 0)
]
