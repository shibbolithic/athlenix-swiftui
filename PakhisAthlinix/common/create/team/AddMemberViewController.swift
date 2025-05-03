import UIKit
import Supabase

protocol AddMemberDelegate: AnyObject {
    func didSelectMembers(_ members: [Usertable])
}

class AddMemberViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // Properties
    weak var delegate: AddMemberDelegate?
    var members: [Usertable] = []
    var filteredMembers: [Usertable] = []
    var selectedMembers: [Usertable] = []
    
    // Programmatic Table View
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MemberCell.self, forCellReuseIdentifier: "MemberCell")
        return tableView
    }()
    
    // Search Bar
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search Members"
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchMembers()
    }
    
    // Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Select Members"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        // Search Bar Constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        // Table View Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        searchBar.delegate = self
    }
    
    // Setup Table View
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // Fetch Members
    private func fetchMembers() {
        Task {
            do {
                let response = try await supabase
                    .from("User")
                    .select("*")
                    .eq("role", value: Role.athlete.rawValue)
                    .execute()
                
                let decoder = JSONDecoder()
                members = try decoder.decode([Usertable].self, from: response.data)
                filteredMembers = members
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching members: \(error)")
            }
        }
    }
    
    // Done Button Action
    @objc private func doneButtonTapped() {
        if selectedMembers.count > 15 {
            let alert = UIAlertController(title: "Error", message: "You can select up to 15 members only.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        delegate?.didSelectMembers(selectedMembers)
        self.dismiss(animated: true)
    }

    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
        let member = filteredMembers[indexPath.row]
        cell.configure(with: member, isSelected: selectedMembers.contains { $0.userID == member.userID })
        return cell
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let member = filteredMembers[indexPath.row]
        if selectedMembers.contains(where: { $0.userID == member.userID }) {
            selectedMembers.removeAll { $0.userID == member.userID }
        } else if selectedMembers.count < 15 {
            selectedMembers.append(member)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMembers = searchText.isEmpty ? members : members.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
}

// Custom TableViewCell with Image
class MemberCell: UITableViewCell {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with member: Usertable, isSelected: Bool) {
        nameLabel.text = member.name
//        profileImageView.image = UIImage(named: member.profilePicture!) ?? UIImage(systemName: "person.circle")
        
        if let imageName = member.profilePicture,
           let localImage = UIImage(named: imageName) {
            profileImageView.image = localImage
        } else if let imageUrlString = member.profilePicture,
                  let imageUrl = URL(string: imageUrlString) {
            profileImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
        }
        
//        if let urlString = member.profilePicture, let url = URL(string: urlString) {
//            // Load image from URL (use libraries like SDWebImage for efficiency)
//        }
        accessoryType = isSelected ? .checkmark : .none
    }
}
