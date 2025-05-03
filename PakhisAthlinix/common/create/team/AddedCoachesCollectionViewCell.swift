//
//  AddedMembersCollectionViewCell.swift
//  PakhisAthlinix
//
//  Created by admin65 on 06/01/25.
//

import UIKit

class AddedCoachesCollectionViewCell: UICollectionViewCell {
        
        @IBOutlet weak var profilePicture: UIImageView!
        @IBOutlet weak var nameLabel: UILabel!
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }
        
        private func setupUI() {
            profilePicture.layer.cornerRadius = profilePicture.frame.width / 2
//            profilePicture.clipsToBounds = true
            profilePicture.contentMode = .scaleAspectFill
//            nameLabel.textAlignment = .center
        }
        
        func configure(with coach: Usertable) {
            nameLabel.text = coach.name
            //profilePicture.image = UIImage(named: coach.profilePicture!)
            
            if let imageName = coach.profilePicture,
               let localImage = UIImage(named: imageName) {
                profilePicture.image = localImage
            } else if let imageUrlString = coach.profilePicture,
                      let imageUrl = URL(string: imageUrlString) {
                profilePicture.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
            }
        }
    }

