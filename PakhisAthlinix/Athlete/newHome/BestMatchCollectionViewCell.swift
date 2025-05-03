//
//  BestMatchCollectionViewCell.swift
//  PakhisAthlinix
//
//  Created by Vivek Jaglan on 2/8/25.
//

import UIKit

class BestMatchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var myTeamImageView: UIImageView!
    @IBOutlet weak var cellContainerView: UIView!
    @IBOutlet weak var opponentTeamImageView: UIImageView!
        @IBOutlet weak var myTeamNameLabel: UILabel!
        @IBOutlet weak var opponentTeamNameLabel: UILabel!
        
        // Labels for My Team
        @IBOutlet weak var myTeamFieldGoalsLabel: UILabel!
        @IBOutlet weak var myTeamThreePointFieldGoalsLabel: UILabel!
        @IBOutlet weak var myTeamFreeThrowsLabel: UILabel!
        
        // Labels for Opponent Team
        @IBOutlet weak var opponentTeamFieldGoalsLabel: UILabel!
        @IBOutlet weak var opponentTeamThreePointFieldGoalsLabel: UILabel!
        @IBOutlet weak var opponentTeamFreeThrowsLabel: UILabel!
    
    
    override func awakeFromNib() {
            super.awakeFromNib()

            myTeamImageView.layer.cornerRadius = myTeamImageView.frame.height / 2
            opponentTeamImageView.layer.cornerRadius = opponentTeamImageView.frame.height / 2

            myTeamImageView.layer.borderWidth = 2
            myTeamImageView.layer.borderColor = UIColor.white.cgColor

            opponentTeamImageView.layer.borderWidth = 2
            opponentTeamImageView.layer.borderColor = UIColor.white.cgColor

            myTeamImageView.clipsToBounds = true
            opponentTeamImageView.clipsToBounds = true

            styleCellContainer() // Call function to style the container
        }

        // Function to style the cell's container view
        private func styleCellContainer() {
            cellContainerView.layer.cornerRadius = 10 // Set corner radius for the container
            cellContainerView.clipsToBounds = true     // Clip to bounds to make corners rounded
            cellContainerView.layer.borderWidth = 1     // Add a border
            cellContainerView.layer.borderColor = UIColor.lightGray.cgColor // Light gray border color
            // cellContainerView.backgroundColor = .systemBackground // Optional: set background color if needed
        }


        // Corrected Configure Method with Win/Loss Styling
        func configure(myTeamName: String, opponentTeamName: String, myTeamFieldGoals: String, myTeamThreePointFieldGoals: String, myTeamFreeThrows: String, opponentTeamFieldGoals: String, opponentTeamThreePointFieldGoals: String, opponentTeamFreeThrows: String) {
            myTeamNameLabel.text = myTeamName
            opponentTeamNameLabel.text = opponentTeamName

            myTeamFieldGoalsLabel.text = myTeamFieldGoals
            myTeamThreePointFieldGoalsLabel.text = myTeamThreePointFieldGoals
            myTeamFreeThrowsLabel.text = myTeamFreeThrows

            opponentTeamFieldGoalsLabel.text = opponentTeamFieldGoals
            opponentTeamThreePointFieldGoalsLabel.text = opponentTeamThreePointFieldGoals
            opponentTeamFreeThrowsLabel.text = opponentTeamFreeThrows
            
//            myTeamImageView.image = UIImage(named: <#T##String#>)
            myTeamImageView.image = UIImage(named: "team1") // Setting Team Logos here directly
            opponentTeamImageView.image = UIImage(named: "team2") // Setting Team Logos here directly

            // Calculate total scores for win/loss styling
            let myTeamScore = (Int(myTeamFieldGoals) ?? 0) + (Int(myTeamThreePointFieldGoals) ?? 0) + (Int(myTeamFreeThrows) ?? 0)
            let opponentTeamScore = (Int(opponentTeamFieldGoals) ?? 0) + (Int(opponentTeamThreePointFieldGoals) ?? 0) + (Int(opponentTeamFreeThrows) ?? 0)


            // Define colors for winner and loser
            let winnerColor = UIColor.green // You can use a specific shade of green
            let loserColor = UIColor.orange // You can use a specific shade of orange
            let defaultColor = UIColor.label // Default label color for tie or no winner/loser indication


            if myTeamScore > opponentTeamScore {
                // Set My team score labels to green, Opponent to orange
                setScoreLabelColor(labels: [myTeamFieldGoalsLabel, myTeamThreePointFieldGoalsLabel, myTeamFreeThrowsLabel], color: winnerColor)
                setScoreLabelColor(labels: [opponentTeamFieldGoalsLabel, opponentTeamThreePointFieldGoalsLabel, opponentTeamFreeThrowsLabel], color: loserColor)

            } else if opponentTeamScore > myTeamScore {
                // Set Opponent team score labels to green, My team to orange
                setScoreLabelColor(labels: [opponentTeamFieldGoalsLabel, opponentTeamThreePointFieldGoalsLabel, opponentTeamFreeThrowsLabel], color: winnerColor)
                setScoreLabelColor(labels: [myTeamFieldGoalsLabel, myTeamThreePointFieldGoalsLabel, myTeamFreeThrowsLabel], color: loserColor)
            } else {
                // Tie: Set all score labels to default color
                setScoreLabelColor(labels: [myTeamFieldGoalsLabel, myTeamThreePointFieldGoalsLabel, myTeamFreeThrowsLabel, opponentTeamFieldGoalsLabel, opponentTeamThreePointFieldGoalsLabel, opponentTeamFreeThrowsLabel], color: defaultColor)
            }
        }

        // Helper function to set color for an array of score labels (reusable from MatchTableViewCell)
        private func setScoreLabelColor(labels: [UILabel], color: UIColor) {
            for label in labels {
                label.textColor = color
            }
        }
}
