//
//  UserCollectionViewCell.swift
//  PakhisAthlinix
//
//  Created by admin65 on 17/03/25.
//

import UIKit

class PlayerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func configure(with user: Usertable) {
        nameLabel.text = user.name
//        profileImageView.image = UIImage(named: user.profilePicture!)
        
        if let imageName = user.profilePicture,
           let localImage = UIImage(named: imageName) {
            profileImageView.image = localImage
        } else if let imageUrlString = user.profilePicture,
                  let imageUrl = URL(string: imageUrlString) {
            profileImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
    }
}
