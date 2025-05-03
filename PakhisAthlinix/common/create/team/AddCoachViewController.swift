import UIKit
import Supabase

protocol AddCoachDelegate: AnyObject {
    func didSelectCoaches(_ coaches: [Usertable])
}

class AddCoachViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // Properties
    weak var delegate: AddCoachDelegate?
    var coaches: [Usertable] = []
    var filteredCoaches: [Usertable] = []
    var selectedCoaches: [Usertable] = []
    
    // Programmatic Table View
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CoachCell.self, forCellReuseIdentifier: "CoachCell")
        return tableView
    }()
    
    // Search Bar
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search Coaches"
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchCoaches()
    }
    
    // Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Select Coaches"
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
    
    // Fetch Coaches
    private func fetchCoaches() {
        Task {
            do {
                let response = try await supabase
                    .from("User")
                    .select("*")
                    .eq("role", value: Role.coach.rawValue)
                    .execute()
                
                let decoder = JSONDecoder()
                coaches = try decoder.decode([Usertable].self, from: response.data)
                filteredCoaches = coaches
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching coaches: \(error)")
            }
        }
    }
    
    // Done Button Action
    @objc private func doneButtonTapped() {
        if selectedCoaches.count > 2 {
            let alert = UIAlertController(title: "Error", message: "You can select up to 2 coaches only.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        delegate?.didSelectCoaches(selectedCoaches)
        self.dismiss(animated: true)
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCoaches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoachCell", for: indexPath) as! CoachCell
        let coach = filteredCoaches[indexPath.row]
        cell.configure(with: coach, isSelected: selectedCoaches.contains { $0.userID == coach.userID })
        return cell
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coach = filteredCoaches[indexPath.row]
        if selectedCoaches.contains(where: { $0.userID == coach.userID }) {
            selectedCoaches.removeAll { $0.userID == coach.userID }
        } else if selectedCoaches.count < 2 {
            selectedCoaches.append(coach)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCoaches = searchText.isEmpty ? coaches : coaches.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
}

// Custom TableViewCell with Image
