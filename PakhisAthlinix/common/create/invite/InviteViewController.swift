import UIKit

class InviteViewController: UIViewController {
    
    @IBOutlet weak var InvitePeopleTableViewOutlet: UITableView!
    
    private var teams: [TeamTable] = []
    private var filteredTeams: [TeamTable] = [] // For storing filtered search results
    private var isSearching: Bool = false
    var delegate: InviteDelegate?
    
    @IBOutlet weak var SearchBar: UISearchBar!
    let cellReuseIdentifier = "InivitePeopleCellTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InvitePeopleTableViewOutlet.delegate = self
        InvitePeopleTableViewOutlet.dataSource = self
        
        // Set up search bar delegate
        SearchBar.delegate = self
        
        // Setup tableView for card-style cells
        setupTableViewForCardStyle()
        
        fetchTeams()
    }
    
    private func setupTableViewForCardStyle() {
        // Remove separator lines
        InvitePeopleTableViewOutlet.separatorStyle = .none
        
        // Add padding around cells
        InvitePeopleTableViewOutlet.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        // Set background color
        InvitePeopleTableViewOutlet.backgroundColor = UIColor.systemGroupedBackground
    }
    
    private func fetchTeams() {
        Task {
            do {
                let response: [TeamTable] = try await supabase
                    .from("teams")
                    .select()
                    .execute()
                    .value
                
                self.teams = response
                self.filteredTeams = response // Initialize filteredTeams with all teams
                print("Fetched Teams: \(response)")
                
                DispatchQueue.main.async {
                    self.InvitePeopleTableViewOutlet.reloadData()
                }
            } catch {
                print("Failed to fetch teams: \(error.localizedDescription)")
            }
        }
    }
    
    // Filter teams based on search text
    private func filterTeams(with searchText: String) {
        if searchText.isEmpty {
            filteredTeams = teams
            isSearching = false
        } else {
            isSearching = true
            filteredTeams = teams.filter { team in
                team.teamName.lowercased().contains(searchText.lowercased())
            }
        }
        InvitePeopleTableViewOutlet.reloadData()
    }
}

extension InviteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95 // Increased height for better card appearance
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTeams.count : teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? InivitePeopleCellTableViewCell else {
            fatalError("Unable to dequeue InivitePeopleCellTableViewCell")
        }
        
        // Use filtered teams when searching
        let team = isSearching ? filteredTeams[indexPath.row] : teams[indexPath.row]
        cell.nameLabelOutlet.text = team.teamName
        cell.dateLabelOutlet.text = " \(team.teamMotto ?? "")"
        
        if let imageName = team.teamLogo,
           let localImage = UIImage(named: imageName) {
            cell.logoImageOutlet.image = localImage
        } else if let imageUrlString = team.teamLogo,
                  let imageUrl = URL(string: imageUrlString) {
            cell.logoImageOutlet.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
        }
        
        // Configure cell as an elevated card
        configureCardAppearance(for: cell)
        
        cell.delegate = self
        return cell
    }
    
    private func configureCardAppearance(for cell: UITableViewCell) {
        // Create a container view for card effect
        let cardView = UIView()
        cardView.backgroundColor = .systemGray6
        cardView.layer.cornerRadius = 15
        
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
        let selectedTeam = isSearching ? filteredTeams[indexPath.row] : teams[indexPath.row]
        delegate?.didSelectTeam(selectedTeam)
        self.dismiss(animated: true, completion: nil)
    }
}

extension InviteViewController: ButtonCelldelegate {
    
    func addButtonTapped(in cell: InivitePeopleCellTableViewCell) {
        guard let indexPath = InvitePeopleTableViewOutlet.indexPath(for: cell) else { return }
        let selectedTeam = isSearching ? filteredTeams[indexPath.row] : teams[indexPath.row]
        delegate?.didSelectTeam(selectedTeam)
        print("Selected team: \(selectedTeam.teamName)")
        self.dismiss(animated: true, completion: nil)
    }
    
    func logoButtonTapped(in cell: InivitePeopleCellTableViewCell) {
        print("Logo button tapped for cell at index: \(InvitePeopleTableViewOutlet.indexPath(for: cell)?.row ?? -1)")
    }
}

// Add UISearchBarDelegate extension
extension InviteViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTeams(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterTeams(with: "")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
