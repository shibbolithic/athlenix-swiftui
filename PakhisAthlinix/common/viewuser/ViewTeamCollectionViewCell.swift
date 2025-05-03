////
////  TeamCollectionViewCell.swift
////  PakhisAthlinix
////
////  Created by admin65 on 16/12/24.
////
//
//
import UIKit
//
class ViewTeamCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var teamImage: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        teamImage.layer.cornerRadius = teamImage.frame.height / 2
        teamImage.clipsToBounds = true
    }
    
    func configure(with team: TeamTable) {
        // Set team name, logo, etc.
        teamName.text = team.teamName
        
        if let imageName = team.teamLogo,
           let localImage = UIImage(named: imageName) {
            teamImage.image = localImage
        } else if let imageUrlString = team.teamLogo,
                  let imageUrl = URL(string: imageUrlString) {
            teamImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
        }

    }

}
