//
//  MatchTableViewCell.swift
//  MatchHistory
//
//  Created by admin65 on 14/11/24.
//

import UIKit

class MatchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var WinningStatusOutlet: UILabel!
    @IBOutlet weak var GameDetailsContainer: UIStackView!
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initial setup
        prepareScoreLabels()
    }
    
    // Prepare score labels with initial styling
    private func prepareScoreLabels() {
        let allScoreLabels = [
            homeFieldGoalsLabel, homeThreePointersLabel, homeFreeThrowsLabel,
            awayFieldGoalsLabel, awayThreePointersLabel, awayFreeThrowsLabel
        ]
        
        for label in allScoreLabels {
            configureScoreLabel(label!)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create an array of all score labels
        let scoreLabels = [
            homeFieldGoalsLabel, homeThreePointersLabel, homeFreeThrowsLabel,
            awayFieldGoalsLabel, awayThreePointersLabel, awayFreeThrowsLabel
        ]
        
        // Make each label square
        for label in scoreLabels {
            guard let label = label else { continue }
            
            // Get the width (will use this for height too)
            let size = min(max(label.bounds.width, 20), 30) // Min 40pts, max 60pts
            
            // Keep the center position the same
            let centerX = label.center.x
            let centerY = label.center.y
            
            // Set square frame
            label.frame = CGRect(
                x: centerX - size/2,
                y: centerY - size/2,
                width: size,
                height: size
            )
            
            // Update corner radius for rounded square
            label.layer.cornerRadius = size * 0.2
        }
    }
    
    func configure(with gameStats: (team1Name: String, team1Logo: String, team2Name: String, team2Logo: String, team1Stats: [String: Int], team2Stats: [String: Int])) {
        // Set team names
        homeTeamNameLabel.text = gameStats.team1Name
        awayTeamNameLabel.text = gameStats.team2Name
        
        // Load team logos
        if let localImage = UIImage(named: gameStats.team1Logo) {
            homeTeamLogo.image = localImage
        } else if let imageUrl = URL(string: gameStats.team1Logo) {
            homeTeamLogo.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }
        
        if let localImage = UIImage(named: gameStats.team2Logo) {
            awayTeamLogo.image = localImage
        } else if let imageUrl = URL(string: gameStats.team2Logo) {
            awayTeamLogo.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }
        
        // Configure team logos
        homeTeamLogo.layer.cornerRadius = homeTeamLogo.frame.height / 2
        awayTeamLogo.layer.cornerRadius = awayTeamLogo.frame.height / 2
        homeTeamLogo.clipsToBounds = true
        awayTeamLogo.clipsToBounds = true
        
        // Configure game details container
        GameDetailsContainer.layer.cornerRadius = 25
        GameDetailsContainer.clipsToBounds = true
        GameDetailsContainer.layer.borderWidth = 1
        GameDetailsContainer.layer.borderColor = UIColor.systemGray6.cgColor
        
        // Set stats from gameStats
        let homeFieldGoals = gameStats.team1Stats["2pt Field Goals"] ?? 0
        let homeThreePointers = gameStats.team1Stats["3pt Field Goals"] ?? 0
        let homeFreeThrows = gameStats.team1Stats["Free Throws"] ?? 0
        let awayFieldGoals = gameStats.team2Stats["2pt Field Goals"] ?? 0
        let awayThreePointers = gameStats.team2Stats["3pt Field Goals"] ?? 0
        let awayFreeThrows = gameStats.team2Stats["Free Throws"] ?? 0
        
        // Set score text
        homeFieldGoalsLabel.text = "\(homeFieldGoals)"
        homeThreePointersLabel.text = "\(homeThreePointers)"
        homeFreeThrowsLabel.text = "\(homeFreeThrows)"
        awayFieldGoalsLabel.text = "\(awayFieldGoals)"
        awayThreePointersLabel.text = "\(awayThreePointers)"
        awayFreeThrowsLabel.text = "\(awayFreeThrows)"
        
        // Calculate total scores
        let homeTeamScore = homeFieldGoals * 2 + homeThreePointers * 3 + homeFreeThrows
        let awayTeamScore = awayFieldGoals * 2 + awayThreePointers * 3 + awayFreeThrows
        
        // Define colors
        let winnerColor = UIColor.systemGreen
        let loserColor = UIColor.systemOrange
        let defaultColor = UIColor.label
        
        // Determine winner/loser and set colors
        if homeTeamScore > awayTeamScore {
            WinningStatusOutlet.text = "Winner"
            WinningStatusOutlet.textColor = winnerColor
            
            setScoreLabelColor(labels: [homeFieldGoalsLabel, homeThreePointersLabel, homeFreeThrowsLabel], textColor: winnerColor)
            setScoreLabelColor(labels: [awayFieldGoalsLabel, awayThreePointersLabel, awayFreeThrowsLabel], textColor: loserColor)
        } else if awayTeamScore > homeTeamScore {
            WinningStatusOutlet.text = "Lost"
            WinningStatusOutlet.textColor = loserColor
            
            setScoreLabelColor(labels: [awayFieldGoalsLabel, awayThreePointersLabel, awayFreeThrowsLabel], textColor: winnerColor)
            setScoreLabelColor(labels: [homeFieldGoalsLabel, homeThreePointersLabel, homeFreeThrowsLabel], textColor: loserColor)
        } else {
            WinningStatusOutlet.text = "Tie"
            WinningStatusOutlet.textColor = defaultColor
            
            setScoreLabelColor(labels: [homeFieldGoalsLabel, homeThreePointersLabel, homeFreeThrowsLabel,
                                       awayFieldGoalsLabel, awayThreePointersLabel, awayFreeThrowsLabel],
                              textColor: defaultColor)
        }
        
        // Force layout update to ensure square labels
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // Helper function to configure score label with squared background
    private func configureScoreLabel(_ label: UILabel) {
        // Center text
        label.textAlignment = .center
        
        // Set bold font for better readability
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        // Set background color
        label.backgroundColor = UIColor.systemGray6
        
        // Enable rounded corners
        label.clipsToBounds = true
        
        // Allow frame changes
        label.translatesAutoresizingMaskIntoConstraints = true
    }
    
    // Helper function to set color for an array of score labels
    private func setScoreLabelColor(labels: [UILabel], textColor: UIColor) {
        for label in labels {
            label.textColor = textColor
        }
    }
}
