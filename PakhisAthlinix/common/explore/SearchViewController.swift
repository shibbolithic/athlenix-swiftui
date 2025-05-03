//
//  SearchViewController.swift
//  PakhisAthlinix
//
//  Created by admin65 on 07/02/25.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var userTableView: UITableView!
    
    var members: [Usertable] = []
    var filteredMembers: [Usertable] = []
    
    // Variables to track scrolling
    private var lastContentOffset: CGFloat = 0
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadingIndicator.shared.show(in: view)
        
        userTableView.delegate = self
        userTableView.dataSource = self
        searchbar.delegate = self
        
        // Setup tableView for card-style cells
        setupTableViewForCardStyle()
        
        // Configure navigation bar appearance
        configureNavigationBar()
        
        fetchMembers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make sure the navigation bar is visible when the view appears
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func configureNavigationBar() {
        // Set navigation bar to be transparent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        // Make sure scroll edge appearance is properly configured for iOS 15+
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            navigationController?.navigationBar.standardAppearance = appearance
            
            // Configure a transparent appearance for when hidden
            let transparentAppearance = UINavigationBarAppearance()
            transparentAppearance.configureWithTransparentBackground()
            navigationController?.navigationBar.scrollEdgeAppearance = transparentAppearance
        }
    }
    
    private func setupTableViewForCardStyle() {
        // Remove separator lines
        userTableView.separatorStyle = .none
        
        // Add padding around cells
        userTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        // Set background color
        userTableView.backgroundColor = UIColor.systemGroupedBackground
    }
       
    private func fetchMembers() {
        Task {
            do {
                let response = try await supabase
                    .from("User")
                    .select("*")
                    .execute()
                
                let decoder = JSONDecoder()
                let users = try decoder.decode([Usertable].self, from: response.data)
                
                DispatchQueue.main.async {
                    LoadingIndicator.shared.hide()
                    self.members = users
                    self.filteredMembers = users
                    self.userTableView.reloadData()
                }
            } catch {
                print("Error fetching members: \(error)")
                LoadingIndicator.shared.hide()
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMembers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95 // Increased height for better card appearance
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        let user = filteredMembers[indexPath.row]
        
        cell.name.text = user.name
        cell.role.text = user.role.rawValue.capitalized
        
        if let imageName = user.profilePicture,
           let localImage = UIImage(named: imageName) {
            cell.pfpImageView.image = localImage
        } else if let imageUrlString = user.profilePicture,
                  let imageUrl = URL(string: imageUrlString) {
            cell.pfpImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
        }
        
        // Configure cell as an elevated card
        configureCardAppearance(for: cell)

        return cell
    }
    
    private func configureCardAppearance(for cell: UITableViewCell) {
        // Create a container view for card effect
        let cardView = UIView()
        cardView.backgroundColor = .systemGray6
        cardView.layer.cornerRadius = 16
        
        // Add shadow for elevation effect
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.1
        
        // Make sure subviews are clipped to the rounded corners
        cardView.clipsToBounds = true
        
        // Insert the card view between the cell's contentView and its subviews
        cell.contentView.insertSubview(cardView, at: 0)
        
        // Set up constraints for the card view (with margins)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
        ])
        
        // Remove default cell selection style
        cell.selectionStyle = .none
        
        // Set background color to clear so the card is visible
        cell.backgroundColor = .systemBackground
        cell.contentView.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = filteredMembers[indexPath.row]
            
        // Assuming "ViewUserVC" is the identifier of your ViewUserVC in the storyboard
        if let viewUserVC = storyboard?.instantiateViewController(withIdentifier: "ViewUserViewController") as? ViewUserViewController {
            
            // Pass the selected user's data
            viewUserVC.selectedUserID = selectedUser.userID
            
            // Push the ViewUserVC onto the navigation stack
            navigationController?.pushViewController(viewUserVC, animated: true)
        }
    }
    
    // Handle scrolling for navigation bar appearance
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Determine scroll direction
        let currentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        // Check if we're at the top of the table view
        if currentOffset <= 0 {
            // Show navigation bar when at the top
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        // Check if we're at the bottom of the table view
        else if currentOffset >= contentHeight - frameHeight {
            // Show navigation bar when at the bottom
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        else {
            // Determine scroll direction
            if currentOffset > lastContentOffset {
                // Scrolling down, hide navigation bar
                navigationController?.setNavigationBarHidden(true, animated: true)
            } else {
                // Scrolling up, show navigation bar
                navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
        
        // Save current position for next comparison
        lastContentOffset = currentOffset
    }
    
    // Reset offset tracking when dragging ends
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // If not decelerating, update the last content offset
        if !decelerate {
            lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    // Reset offset tracking when scrolling ends
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMembers = members
        } else {
            filteredMembers = members.filter { $0.name.lowercased().contains(searchText.lowercased()) || $0.username.lowercased().contains(searchText.lowercased()) }
        }
        userTableView.reloadData()
    }
}
