//
//  athletesCollectionViewCell.swift
//  Home
//
//  Created by admin65 on 18/11/24.
//

import UIKit

class athletesNewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var athleteProfileImageView: UIImageView!
    
    @IBOutlet weak var athleteNameLabel: UILabel!
    
    @IBOutlet weak var ProfileCardOutlet: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ProfileCardOutlet.layer.cornerRadius = 16
        ProfileCardOutlet.clipsToBounds = true
        ProfileCardOutlet.contentMode = .scaleAspectFit
    }
    
    func configure(with user: Usertable) {
           // Set user name
        athleteNameLabel.text = user.username
           
           // Set profile image (assuming you have a profile picture or a placeholder)
        if let imageName = user.profilePicture,
           let localImage = UIImage(named: imageName) {
            athleteProfileImageView.image = localImage
        } else if let imageUrlString = user.profilePicture,
                  let imageUrl = URL(string: imageUrlString) {
            athleteProfileImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
        }
        
        athleteProfileImageView.layer.cornerRadius = 15

           
        
       }

}
