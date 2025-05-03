//
//  CreateGameViewController.swift
//  Athlinix
//
//  Created by Vivek Jaglan on 12/30/24.
//

import UIKit

class CreateGameViewController: UIViewController{
    
    
    @IBOutlet weak var GameHeaderViewOutlet: UIView!
    //All the Outlets
    @IBOutlet weak var gameNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var yourTeamCollectionView: UICollectionView!
    @IBOutlet weak var yourTeamMembersCollectionView: UICollectionView!
    @IBOutlet weak var addOpponentTeamButton: UIButton!
    @IBOutlet weak var opponentTeamMembersCollectionView: UICollectionView!
    @IBOutlet weak var createButton: UIButton!
    
    
    
    var teams: [TeamTable] = []
    var members: [TeamMembershipTable] = []
    var selectedTeam: TeamTable?
    var selectedOppoTeam: TeamTable?
    var opponentTeam: TeamTable?
    var opponentMembers: [TeamMembershipTable] = []
    
    var allUsers: [Usertable] = []
    
    var allMembers: [Usertable] = []
    
    
    
    private let teamCellId = "TeamCellCollectionViewCell"
    private let memberCellId = "TeamMemberCellCollectionViewCell"
    private let opponentCellId = "OpponentTeamMemberCellCollectionViewCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task{
            await fetchTeams()
        }
        //fetchTeams()
        
        setupCollectionViews()
        setupUI()
        setupBackButton()
        
        
        navigationController?.navigationBar.isTranslucent = false
            
            // Prevent the navigation bar from hiding when scrolling
            navigationController?.hidesBarsOnSwipe = false
        
        navigationController?.navigationBar.prefersLargeTitles = false
           
           // Ensure nav bar appearance is consistent
           if #available(iOS 15.0, *) {
               let appearance = UINavigationBarAppearance()
               appearance.configureWithOpaqueBackground()
               navigationController?.navigationBar.standardAppearance = appearance
               navigationController?.navigationBar.scrollEdgeAppearance = appearance
           }
        //fetchSingleMemberProfile(for: allUsers.userID)
//        if let firstUserID = userIDs.first {
//            fetchSingleMemberProfile(for: firstUserID)
//        }
    }
    
    private func setupUI() {
        GameHeaderViewOutlet.layer.cornerRadius = 25
        addOpponentTeamButton.layer.cornerRadius = 16
        
        setupKeyboardHandling()
    }
    
    private func setupCollectionViews() {
        // Configure collection view delegates and data sources
        let collectionViews = [
            yourTeamCollectionView,
            yourTeamMembersCollectionView,
            opponentTeamMembersCollectionView
        ]
        
        collectionViews.forEach { collectionView in
            collectionView?.delegate = self
            collectionView?.dataSource = self
        }
        
        if let layout = yourTeamCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 69, height: 79)
        }
        
        if let layout = opponentTeamMembersCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 69, height: 94)
        }
        
        if let layout = yourTeamMembersCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 69, height: 94)
        }
    }
    
    @IBAction func opponentTeamButtonTapped(_ sender: Any) {
        // Present modal for selecting opponent team
        
        //open InviteViewController as Modal
//        let vc = InviteViewController()
//            vc.delegate = self
//            present(vc, animated: true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let inviteVC = storyboard.instantiateViewController(withIdentifier: "InviteViewController") as? InviteViewController {
                inviteVC.delegate = self
                // Present the ViewController modally
                present(inviteVC, animated: true, completion: nil)
            }

    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        guard
            validateInputs() else { return }
        createGame()
    }
    //Navigate to Next Screen for adding scores
    
    private func validateInputs() -> Bool {
        guard let gameName = gameNameTextField.text, !gameName.isEmpty else {
            showAlert(message: "Please enter a game name")
            return false
        }
        
        guard let location = locationTextField.text, !location.isEmpty else {
            showAlert(message: "Please enter a location")
            return false
        }
        
        guard selectedTeam != nil else {
            showAlert(message: "Please select your team")
            return false
        }
        
        guard opponentTeam != nil else {
            showAlert(message: "Please add an opponent team")
            return false
        }
        
        return true
    }
    
    private func createGame() {
        // Ensure both teams are selected
        guard let selectedTeam = selectedTeam,
              let opponentTeam = opponentTeam else {
            showAlert(message: "Teams are not properly selected.")
            return
        }
        
        // Instantiate AddMemberDetailsViewController from the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addMemberVC = storyboard.instantiateViewController(withIdentifier: "AddMemberDetailsViewController") as? AddMemberDetailsViewController else {
            print("Failed to instantiate AddMemberDetailsViewController")
            return
        }
        
        // Pass data to AddMemberDetailsViewController
        addMemberVC.yourTeam = selectedTeam
        addMemberVC.yourTeamMembers = members
        addMemberVC.opponentTeam = opponentTeam
        addMemberVC.opponentTeamMembers = opponentMembers
        
        // Navigate to AddMemberDetailsViewController
        navigationController?.pushViewController(addMemberVC, animated: true)
    }

    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    //MARK: FETCH TEAMS

    private func fetchTeams() async {
        guard let userID =  await SessionManager.shared.getSessionUser()  else {
            print("User ID is nil")
            return
        }
        
        Task {
            do {
                // Fetch team memberships for the current user
                let membershipsResponse = try await supabase
                    .from("teamMembership")
                    .select("*")
                    .eq("userID", value: userID.uuidString)
                    .execute()
                
                let decoder = JSONDecoder()
                let memberships = try decoder.decode([TeamMembershipTable].self, from: membershipsResponse.data)
                
                // Extract teamIDs from memberships
                let teamIDs = memberships.map { $0.teamID.uuidString }
                
                // Fetch teams matching the teamIDs
                let teamsResponse = try await supabase
                    .from("teams")
                    .select("*")
                    .in("teamID", values: teamIDs)
                    .execute()
                
                let teams = try decoder.decode([TeamTable].self, from: teamsResponse.data)
                
                // Update the teams array and reload the collection view
                Task { @MainActor in
                    print("Success: Data fetched successfully")
                    self.teams = teams
                    self.yourTeamCollectionView.reloadData()
                }
                
            } catch {
                print("Failed to fetch teams: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Keyboard Handling

    private func setupKeyboardHandling() {
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 7
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    private func fetchTeamMembers(for teamID: UUID) {
        Task {
            do {
                let response = try await supabase
                    .from("teamMembership")
                    .select("*")
                    .eq("teamID", value: teamID)
                    .execute()

                let decoder = JSONDecoder()
                members = try decoder.decode([TeamMembershipTable].self, from: response.data)
                
                print(members)
                
                let userIDs = members.map { $0.userID }
                
                print(userIDs)
                
                fetchMemberProfiles(for: userIDs) // Fetch all user profiles at once
                //fetchOpponentMembers(for: userIDs)
                // Reload UI on the main thread
                DispatchQueue.main.async {
                    self.yourTeamMembersCollectionView.reloadData()
                    //self.opponentTeamMembersCollectionView.reloadData()
                }
            } catch {
                print("Error fetching team members: \(error.localizedDescription)")
            }
        }
    }

    
//MARK: FETCH MEMBERS
    private func fetchMemberProfiles(for userIDs: [UUID]) {
        Task {
            do {
                let response = try await supabase
                    .from("User")
                    .select("*")
                    .in("userID", values: userIDs) // Fetch multiple users at once
                    .execute()
                
                print(response)
                
                let decoder = JSONDecoder()
                
                allUsers = try decoder.decode([Usertable].self, from: response.data)
                //allMembers = try decoder.decode([Usertable].self, from: response.data)
                
                print(allUsers)
                
                // Reload UI on the main thread
                DispatchQueue.main.async {
                    self.yourTeamMembersCollectionView.reloadData()
                    //self.opponentTeamMembersCollectionView.reloadData()
                }
            } catch {
                print("Error fetching member profiles: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchOpponentMembers(for teamID: UUID) {
            Task {
                do {
                    let response = try await supabase
                        .from("teamMembership")
                        .select("*")
                        .eq("teamID", value: teamID)
                        .execute()

                    let decoder = JSONDecoder()
                    let opponentMembers = try decoder.decode([TeamMembershipTable].self, from: response.data)
                    
                    self.opponentMembers = opponentMembers
                    
                    let opponentUserIDs = opponentMembers.map { $0.userID }
                    fetchOpponentMemberProfiles(for: opponentUserIDs) // Fetch opponent user profiles
                    
                    DispatchQueue.main.async {
                        self.opponentTeamMembersCollectionView.reloadData()
                    }
                } catch {
                    print("Failed to fetch opponent team members: \(error.localizedDescription)")
                }
            }
        }
    
    private func fetchOpponentMemberProfiles(for userIDs: [UUID]) {
        Task {
            do {
                let response = try await supabase
                    .from("User")
                    .select("*")
                    .in("userID", values: userIDs)
                    .execute()
                
                let decoder = JSONDecoder()
                self.allMembers = try decoder.decode([Usertable].self, from: response.data)
                
                DispatchQueue.main.async {
                    self.opponentTeamMembersCollectionView.reloadData()
                }
            } catch {
                print("Error fetching opponent member profiles: \(error.localizedDescription)")
            }
        }
    }
    
}

extension CreateGameViewController: InviteDelegate {
    func didSelectTeam(_ team: TeamTable) {
        opponentTeam = team  // Assuming you only want one opponent team
        fetchOpponentMembers(for: team.teamID)
        print("Selected Opponent Team: \(team.teamName)")
    }
}

extension CreateGameViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case yourTeamCollectionView:
            print("Number of teams: \(teams.count)")
            return teams.count
        case yourTeamMembersCollectionView:
            return members.count
        case opponentTeamMembersCollectionView:
            print("Opponent Members Count: \(opponentMembers.count)")
            return opponentMembers.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case yourTeamCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: teamCellId, for: indexPath) as! TeamCellCollectionViewCell
            let team = teams[indexPath.row]
            print("Configuring cell for team: \(team.teamName)")
            cell.configure(with: teams[indexPath.row])
            return cell
            
        case yourTeamMembersCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: memberCellId, for: indexPath) as! TeamMemberCellCollectionViewCell
            cell.configure(with: members[indexPath.row], users: allUsers)
            return cell
            
        case opponentTeamMembersCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: opponentCellId, for: indexPath) as! OpponentTeamMemberCellCollectionViewCell
            //let member = opponentMembers[indexPath.row]
            cell.configure101(with: opponentMembers[indexPath.row], users: allMembers)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == yourTeamCollectionView {
            
            selectedTeam = teams[indexPath.row]
            // You might want to fetch members for the selected team here
            // fetchTeamMembers(for: selectedTeam)
            print("selected team: \(String(describing: selectedTeam))")
            selectedTeam = teams[indexPath.row]
            guard let teamID = selectedTeam?.teamID else { return }
            fetchTeamMembers(for: teamID)
            
        } else if collectionView == opponentTeamMembersCollectionView {
            // Handle selection of opponent team members
            
        }
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
    }
    
    private func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back",
                                             style: .plain,
                                             target: self,
                                             action: #selector(backButtonTapped))
            
            // Set chevron.left icon
            backButton.image = UIImage(systemName: "chevron.left")
            //backButton.tintColor = .label // Adapts to light/dark mode
            
            navigationItem.leftBarButtonItem = backButton
    }

    // Back button action
    @objc private func backButtonTapped() {
        Task {
                guard let userID = await SessionManager.shared.getSessionUser() else {
                    print("User ID is nil")
                    return
                }
                
                do {
                    let userRole = try await fetchUserRole(userID: userID)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewControllerIdentifier = (userRole == .coach) ? "CoachMainTabBarController" : "MainTabBarController"
                    
                    if let homeVC = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? UITabBarController {
                        let transition = CATransition()
                        transition.duration = 0.3
                        transition.type = .push
                        transition.subtype = .fromLeft
                        view.window?.layer.add(transition, forKey: kCATransition)
                        
                        homeVC.modalPresentationStyle = .fullScreen
                        //homeVC.selectedIndex = 2
                        self.present(homeVC, animated: true, completion: nil)
                    } else {
                        print("❌ Could not instantiate \(viewControllerIdentifier)")
                    }
                } catch {
                    print("❌ Error fetching user role: \(error.localizedDescription)")
                }
            }
    }
    
    private func fetchUserRole(userID: UUID) async throws -> Role {
        let response = try await supabase
            .from("User")
            .select("*")
            .eq("userID", value: userID)
            .single()
            .execute()
        
        print("🔍 Raw Response: \(String(data: response.data, encoding: .utf8) ?? "No Data")")
        
        let decoder = JSONDecoder()
        let user = try decoder.decode(Usertable.self, from: response.data)
        
        return user.role
    }

}
