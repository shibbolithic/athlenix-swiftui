//
//  AddedCoachesCollectionViewCell 2.swift
//  PakhisAthlinix
//
//  Created by admin65 on 07/01/25.
//

import UIKit
import Foundation
import Supabase

class AddedMemberssCollectionViewCell: UICollectionViewCell {
    
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
    
    func configure(with member: Usertable) {
        nameLabel.text = member.name
        //profilePicture.image = UIImage(named: member.profilePicture!)
        
        if let imageName = member.profilePicture,
           let localImage = UIImage(named: imageName) {
            profilePicture.image = localImage
        } else if let imageUrlString = member.profilePicture,
                  let imageUrl = URL(string: imageUrlString) {
            profilePicture.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
        }
    }
}
