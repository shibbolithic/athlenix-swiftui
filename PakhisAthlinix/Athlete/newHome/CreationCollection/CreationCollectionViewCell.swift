import UIKit


class CreationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func styleStatCard(_ cardView: UIView) {
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.clipsToBounds = false
    }
    
    private func setupUI() {
        // Style the cell
        
        self.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 250/255, alpha: 1)
        self.layer.cornerRadius = 12
        
        // Style the plus button
        plusButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        
        // Style the label
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
    }
}
