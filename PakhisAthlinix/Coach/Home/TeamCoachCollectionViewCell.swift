//
//  TeamCoachCollectionViewCell.swift
//  PakhisAthlinix
//
//  Created by Vivek Jaglan on 3/14/25.
//

import UIKit

class TeamCoachCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var teamImage: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    
    @IBOutlet weak var teamWinLooseRatio: UILabel!
    
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var cell1: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        teamImage.layer.cornerRadius = teamImage.frame.height / 2
        teamImage.clipsToBounds = true
        //styleStatCard(cellView)
    }
    
    func configure(with team: TeamTableCoach) {
    teamName.text = team.teamName

    // Load image safely
    if let logoName = team.teamLogo, !logoName.isEmpty {
        teamImage.image = UIImage(named: logoName)
    } else {
        teamImage.image = UIImage(named: "defaultTeamLogo") // Fallback image
    }

    // Display win/loss count
//    teamWinLooseRatio.text = "W: \(team.teamWins) | L: \(team.teamLosses)"
        teamWinLooseRatio.text = " "
}
    
    func configure1(with team: TeamTable) {
        // Set team name, logo, etc.
        teamName.text = team.teamName
        
        if let imageName = team.teamLogo,
           let localImage = UIImage(named: imageName) {
            teamImage.image = localImage
        } else if let imageUrlString = team.teamLogo,
                  let imageUrl = URL(string: imageUrlString) {
            teamImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
        }
        
        teamWinLooseRatio.text = " "

    }
    
    private func styleStatCard(_ cardView: UIView) {
        cardView.layer.cornerRadius = 14
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.clipsToBounds = false
    }


}


