//
//  MemberScoreTableViewCell.swift
//  Athlinix
//
//  Created by Vivek Jaglan on 2/7/25.
//

import UIKit

class MemberScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var foulsLabel: UILabel!
    @IBOutlet weak var stealsLabel: UILabel!
    @IBOutlet weak var assistsLabel: UILabel!
    @IBOutlet weak var reboundsLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(with player: Player) {
        playerNameLabel.text = player.name
        reboundsLabel.text = "\(player.reb)"
        assistsLabel.text = "\(player.ast)"
        stealsLabel.text = "\(player.stl)"
        foulsLabel.text = "\(player.foul)"
        pointsLabel.text = "\(player.pts)"
    }
    
}
