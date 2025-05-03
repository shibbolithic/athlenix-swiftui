//
//  LogoSelectionViewController.swift
//  PakhisAthlinix
//
//  Created by admin65 on 07/01/25.
//


import UIKit

class LogoSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Delegate to communicate back to AddTeamViewController
    weak var delegate: LogoSelectionDelegate?
    
    // CollectionView for displaying logos
    private var collectionView: UICollectionView!
    
    // Array of logo names (assume these are the names of the images in the assets folder)
    private let logoNames = [
        "unnamed (1)", "unnamed (2)", "unnamed (3)", "unnamed (4)",
        "unnamed (5)", "unnamed (6)", "unnamed (7)", "unnamed (8)",
        "unnamed (9)", "unnamed (10)", "unnamed (11)", "unnamed (12)",
        "unnamed (13)", "unnamed (14)", "unnamed (15)", "unnamed (16)",
        "unnamed (17)", "unnamed (18)", "unnamed (19)", "unnamed (20)",
        "unnamed (21)", "unnamed (22)", "unnamed (23)", "unnamed (24)",
        "unnamed (25)", "unnamed (26)", "unnamed (27)", "unnamed (28)",
        "unnamed (29)", "unnamed (30)", "unnamed (31)", "unnamed (32)"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Select Team Logo"
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(LogoCollectionViewCell.self, forCellWithReuseIdentifier: LogoCollectionViewCell.identifier)
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        
        // Constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return logoNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LogoCollectionViewCell.identifier, for: indexPath) as! LogoCollectionViewCell
        let logoName = logoNames[indexPath.row]
        cell.configure(with: logoName)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedLogoName = logoNames[indexPath.row]
        delegate?.didSelectLogo(named: selectedLogoName)
        dismiss(animated: true, completion: nil)
    }
}

// Protocol for communication
protocol LogoSelectionDelegate: AnyObject {
    func didSelectLogo(named logoName: String)
}

// Custom CollectionView Cell for displaying logos
class LogoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "LogoCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        
        // Constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with logoName: String) {
        imageView.image = UIImage(named: logoName)
    }
}



