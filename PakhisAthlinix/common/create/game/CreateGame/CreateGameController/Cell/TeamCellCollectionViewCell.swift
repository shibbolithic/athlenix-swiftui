//
//  TeamCellCollectionViewCell.swift
//  Athlinix
//
//  Created by Vivek Jaglan on 12/31/24.
//

import UIKit

class TeamCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var CellOutlet: UIView!
    @IBOutlet weak var TeamLogoOutlet: UIImageView!
    @IBOutlet weak var TeamNameOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    func setupUI() {
        CellOutlet.layer.cornerRadius = 8
        CellOutlet.clipsToBounds = true
        
        TeamLogoOutlet.layer.cornerRadius = TeamLogoOutlet.frame.width / 2
        TeamLogoOutlet.clipsToBounds = true
        
    }
    
    func configure(with team: TeamTable) {
        TeamNameOutlet.text = team.teamName
        if let imageName = team.teamLogo,
           let localImage = UIImage(named: imageName) {
            TeamLogoOutlet.image = localImage
        } else if let imageUrlString = team.teamLogo,
                  let imageUrl = URL(string: imageUrlString) {
            TeamLogoOutlet.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
        }
        //TeamLogoOutlet
    
        
        
//        if let logoURLString = team.teamLogo, let logoURL = URL(string: logoURLString) {
//            loadImage(from: logoURL) { [weak self] image in
//                DispatchQueue.main.async {
//                    self?.TeamLogoOutlet.image = image
//                }
//            }
//        } else {
//            TeamLogoOutlet.image = UIImage(named: "placeholder") // Add a placeholder image in your assets
//        }
    }
    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
        task.resume()
    }

}
