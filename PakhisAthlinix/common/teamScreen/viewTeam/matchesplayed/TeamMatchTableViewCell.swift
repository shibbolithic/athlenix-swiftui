//
//  MatchTableViewCell.swift
//  MatchHistory
//
//  Created by admin65 on 14/11/24.
//

import UIKit

class TeamMatchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var WinningStatusOutlet: UILabel!
    @IBOutlet weak var ContentBox: UIStackView!
    
//    @IBOutlet weak var GameDetailsContainer: UIStackView!
    @IBOutlet weak var homeTeamLogo: UIImageView!
    @IBOutlet weak var awayTeamLogo: UIImageView!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var homeFieldGoalsLabel: UILabel!
    @IBOutlet weak var homeThreePointersLabel: UILabel!
    @IBOutlet weak var homeFreeThrowsLabel: UILabel!
    @IBOutlet weak var awayFieldGoalsLabel: UILabel!
    @IBOutlet weak var awayThreePointersLabel: UILabel!
    @IBOutlet weak var awayFreeThrowsLabel: UILabel!
    
    
    func configure(with gameStats: (team1Name: String, team1Logo: String, team2Name: String, team2Logo: String, team1Stats: [String: Int], team2Stats: [String: Int])) {
            homeTeamNameLabel.text = gameStats.team1Name
            awayTeamNameLabel.text = gameStats.team2Name

            // Assuming you have a method to load images from URLs or asset names
        if let localImage = UIImage(named: gameStats.team1Logo) {
            homeTeamLogo.image = localImage
        } else if let imageUrl = URL(string: gameStats.team1Logo) {
            homeTeamLogo.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }

        // Attempt to load team2 logo as a local image first, otherwise treat it as a URL
        if let localImage = UIImage(named: gameStats.team2Logo) {
            awayTeamLogo.image = localImage
        } else if let imageUrl = URL(string: gameStats.team2Logo) {
            awayTeamLogo.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }

            homeTeamLogo.layer.cornerRadius = homeTeamLogo.frame.height / 2
            awayTeamLogo.layer.cornerRadius = awayTeamLogo.frame.height / 2

            homeTeamLogo.clipsToBounds = true
            awayTeamLogo.clipsToBounds = true
        
        ContentBox.layer.cornerRadius = 10
        ContentBox.clipsToBounds = true
        ContentBox.layer.borderWidth = 1
        ContentBox.layer.borderColor = UIColor.lightGray.cgColor

//            GameDetailsContainer.layer.cornerRadius = 10
//            GameDetailsContainer.clipsToBounds = true
//            GameDetailsContainer.layer.borderWidth = 1
//            GameDetailsContainer.layer.borderColor = UIColor.lightGray.cgColor


            // Set stats from gameStats
            let homeFieldGoals = gameStats.team1Stats["2pt Field Goals"] ?? 0
            let homeThreePointers = gameStats.team1Stats["3pt Field Goals"] ?? 0
            let homeFreeThrows = gameStats.team1Stats["Free Throws"] ?? 0
            let awayFieldGoals = gameStats.team2Stats["2pt Field Goals"] ?? 0
            let awayThreePointers = gameStats.team2Stats["3pt Field Goals"] ?? 0
            let awayFreeThrows = gameStats.team2Stats["Free Throws"] ?? 0

            homeFieldGoalsLabel.text = "\(homeFieldGoals)"
            homeThreePointersLabel.text = "\(homeThreePointers)"
            homeFreeThrowsLabel.text = "\(homeFreeThrows)"

            awayFieldGoalsLabel.text = "\(awayFieldGoals)"
            awayThreePointersLabel.text = "\(awayThreePointers)"
            awayFreeThrowsLabel.text = "\(awayFreeThrows)"

            // Calculate total scores (assuming total score is sum of all categories for simplicity for this example)
            let homeTeamScore = homeFieldGoals + homeThreePointers + homeFreeThrows
            let awayTeamScore = awayFieldGoals + awayThreePointers + awayFreeThrows

            // Define colors
            let winnerColor = UIColor.green // You can use a specific shade of green
            let loserColor = UIColor.orange // You can use a specific shade of orange
            let defaultColor = UIColor.label // Default label color for tie or no winner/loser indication


            if homeTeamScore > awayTeamScore {
                WinningStatusOutlet.text = "Winner"
                WinningStatusOutlet.textColor = winnerColor

                // Set Home team score labels to green
                setScoreLabelColor(labels: [homeFieldGoalsLabel, homeThreePointersLabel, homeFreeThrowsLabel], color: winnerColor)
                // Set Away team score labels to orange
                setScoreLabelColor(labels: [awayFieldGoalsLabel, awayThreePointersLabel, awayFreeThrowsLabel], color: loserColor)

            } else if awayTeamScore > homeTeamScore {
                WinningStatusOutlet.text = "Lost"
                WinningStatusOutlet.textColor = loserColor // Away team won, still winner color

                // Set Away team score labels to green
                setScoreLabelColor(labels: [awayFieldGoalsLabel, awayThreePointersLabel, awayFreeThrowsLabel], color: winnerColor)
                // Set Home team score labels to orange
                setScoreLabelColor(labels: [homeFieldGoalsLabel, homeThreePointersLabel, homeFreeThrowsLabel], color: loserColor)
            } else {
                WinningStatusOutlet.text = "Tie" // Or "Draw" or any other indication for a tie
                WinningStatusOutlet.textColor = defaultColor // Revert to default color for tie

                // Set both team score labels to default color or another neutral color if you prefer
                setScoreLabelColor(labels: [homeFieldGoalsLabel, homeThreePointersLabel, homeFreeThrowsLabel, awayFieldGoalsLabel, awayThreePointersLabel, awayFreeThrowsLabel], color: defaultColor)
            }
        }

        // Helper function to set color for an array of score labels
        private func setScoreLabelColor(labels: [UILabel], color: UIColor) {
            for label in labels {
                label.textColor = color
            }
        }
    
}
