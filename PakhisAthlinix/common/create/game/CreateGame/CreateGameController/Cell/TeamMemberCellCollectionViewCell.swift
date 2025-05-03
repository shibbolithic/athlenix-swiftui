//
//  TeamMemberCellCollectionViewCell.swift
//  Athlinix
//
//  Created by Vivek Jaglan on 12/31/24.
//

import UIKit

class TeamMemberCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var MemberContainer: UIView!

    @IBOutlet weak var MemberAvatarOutlet: UIImageView!
    
    @IBOutlet weak var UsernameOutlet: UILabel!
    @IBOutlet weak var NameOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    func setupUI() {
        MemberContainer.layer.cornerRadius = 10
        MemberContainer.clipsToBounds = true
        
        MemberAvatarOutlet.layer.cornerRadius = MemberAvatarOutlet.frame.width / 2
        MemberAvatarOutlet.clipsToBounds = true
    }
    
    func configure(with member: TeamMembershipTable, users: [Usertable]) {
        if let user = users.first(where: { $0.userID == member.userID }) {
            
            NameOutlet.text = user.name
            UsernameOutlet.text = user.username
//            MemberAvatarOutlet.image = UIImage(named: user.profilePicture!)
            
            if let imageName = user.profilePicture,
               let localImage = UIImage(named: imageName) {
                MemberAvatarOutlet.image = localImage
            } else if let imageUrlString = user.profilePicture,
                      let imageUrl = URL(string: imageUrlString) {
                MemberAvatarOutlet.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
            }

        } else {
            NameOutlet.text = "Unknown"
            UsernameOutlet.text = ""
            MemberAvatarOutlet.image = UIImage(named: "person.circle")
        }
    }

}

//MARK: URL
//            if let profilePictureURL = user.profilePicture, let url = URL(string: profilePictureURL) {
//                // Load image asynchronously
//                DispatchQueue.global().async {
//                    if let data = try? Data(contentsOf: url) {
//                        DispatchQueue.main.async {
//                            self.MemberAvatarOutlet.image = UIImage(data: data)
//                        }
//                    }
//                }
//            } else {
//                // Set a placeholder image if no profile picture
//                self.MemberAvatarOutlet.image = UIImage(named: "defaultAvatar")
//            }
