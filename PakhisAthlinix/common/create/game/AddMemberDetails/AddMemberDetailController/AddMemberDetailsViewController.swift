//
//  AddMemberDetailsViewController.swift
//  Athlinix
//
//  Created by Vivek Jaglan on 1/7/25.
//

import UIKit
import Supabase

class AddMemberDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Variables
    var yourTeam: TeamTable?
    var yourTeamMembers: [TeamMembershipTable] = []
    var opponentTeam: TeamTable?
    var opponentTeamMembers: [TeamMembershipTable] = []

    @IBOutlet weak var undoButtonContainer: UIView!
    @IBOutlet weak var team2score: UILabel!
    @IBOutlet weak var team1score: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var actionButtons: [UIButton]!
    @IBOutlet weak var teamName2Label: UILabel!
    @IBOutlet weak var teamName1Label: UILabel!
    @IBOutlet weak var teamLogo2: UIImageView!
    @IBOutlet weak var teamLogo1: UIImageView!
    
    private lazy var undoButton: UIButton = {
        let button = UIButton(type: .system)
        
        // Create modern symbol configuration
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let image = UIImage(systemName: "arrow.uturn.backward", withConfiguration: config)
        
        // Configure button appearance
        var configuration = UIButton.Configuration.filled()
        configuration.image = image
        configuration.title = "Undo"
        configuration.imagePadding = 8
        configuration.cornerStyle = .medium
        configuration.baseBackgroundColor = .systemIndigo
        configuration.baseForegroundColor = .white
        
        // Font customization
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            return outgoing
        }
        
        // Apply configuration
        button.configuration = configuration
        
        // Shadow for depth
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.15
        
        // Layout and action setup
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(undoLastAction), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    private var lastAction: Action?
        private var lastHighlightedIndexPath: IndexPath?
        private let highlightDuration: TimeInterval = 1.0
    
    
    private func setupUndoButton() {
            // Add to view hierarchy
        undoButtonContainer.addSubview(undoButton)
            
            // Setup constraints - position next to the action buttons
        NSLayoutConstraint.activate([
            undoButton.centerXAnchor.constraint(equalTo: undoButtonContainer.centerXAnchor),
            undoButton.centerYAnchor.constraint(equalTo: undoButtonContainer.centerYAnchor),
            undoButton.heightAnchor.constraint(equalTo: undoButtonContainer.heightAnchor, multiplier: 0.7), // 70% of container height
            undoButton.widthAnchor.constraint(equalTo: undoButtonContainer.widthAnchor, multiplier: 0.5)  // 50% of container width
                ])
        }
    
    @objc private func undoLastAction() {
            guard let action = lastAction else { return }
            
            scoreUpdateQueue.sync {
                // Revert player stats
                if action.team == .team1 {
                    team1.players[action.indexPath.row] = action.previousState
                    team1Score -= action.scoreChange
                } else {
                    team2.players[action.indexPath.row] = action.previousState
                    team2Score -= action.scoreChange
                }
                
                // Clear the last action
                lastAction = nil
                updateUndoButtonState()
                
                DispatchQueue.main.async { [weak self] in
                                self?.tableView.reloadData()
                                self?.updateHeaderUI()
                            }
            }
        }
    
    private func updateUndoButtonState() {
            DispatchQueue.main.async { [weak self] in
                self?.undoButton.isEnabled = self?.lastAction != nil
                self?.undoButton.alpha = self?.lastAction != nil ? 1.0 : 0.5
            }
        }
    
    private struct Action {
            let player: Player
            let previousState: Player
            let team: TeamIdentifier
            let indexPath: IndexPath
            let scoreChange: Int
        }
    
    var team1Score = 0
    var team2Score = 0
    
    var team1 = Team(name: "Lakers", players: [
        Player(name: "Player 1", reb: 0, ast: 0, stl: 0, foul: 0, pts: 0, points3: 0, freeThrows: 0, missed2Points: 0, missed3Points: 0),
        Player(name: "Player 2", reb: 0, ast: 0, stl: 0, foul: 0, pts: 0, points3: 0, freeThrows: 0, missed2Points: 0, missed3Points: 0),
        Player(name: "Player 3", reb: 0, ast: 0, stl: 0, foul: 0, pts: 0, points3: 0, freeThrows: 0, missed2Points: 0, missed3Points: 0),
        Player(name: "Player 4", reb: 0, ast: 0, stl: 0, foul: 0, pts: 0, points3: 0, freeThrows: 0, missed2Points: 0, missed3Points: 0),
        Player(name: "Player 5", reb: 0, ast: 0, stl: 0, foul: 0, pts: 0, points3: 0, freeThrows: 0, missed2Points: 0, missed3Points: 0)
    ])
    
    var team2 = Team(name: "Raptors", players: [
        Player(name: "Player 1", reb: 0, ast: 0, stl: 0, foul: 0, pts: 0, points3: 0, freeThrows: 0, missed2Points: 0, missed3Points: 0),
        Player(name: "Player 2", reb: 0, ast: 0, stl: 0, foul: 0, pts: 0, points3: 0, freeThrows: 0, missed2Points: 0, missed3Points: 0),
        Player(name: "Player 3", reb: 0, ast: 0, stl: 0, foul: 0, pts: 0, points3: 0, freeThrows: 0, missed2Points: 0, missed3Points: 0),
        Player(name: "Player 4", reb: 0, ast: 0, stl: 0, foul: 0, pts: 0, points3: 0, freeThrows: 0, missed2Points: 0, missed3Points: 0),
        Player(name: "Player 5", reb: 0, ast: 0, stl: 0, foul: 0, pts: 0, points3: 0, freeThrows: 0, missed2Points: 0, missed3Points: 0)
    ])
    
    var selectedAction: String?
    
    private var team1AnimationLabel: UILabel?
    private var team2AnimationLabel: UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
        setupUndoButton()
        setupAnimationLabels()
        setupCustomNavigationBar()
        
        // Populate team1 and team2 with actual data
        initializeTeams()
        
        // Update the UI with the passed data
        updateHeaderUI()
        
    }
    //MARK: ANIMATIONS

    private func setupAnimationLabels() {
           // Setup floating animation label for team 1
           team1AnimationLabel = UILabel()
           team1AnimationLabel?.textAlignment = .center
           team1AnimationLabel?.font = .boldSystemFont(ofSize: 24)
           team1AnimationLabel?.textColor = .systemGreen
           team1AnimationLabel?.alpha = 0
           view.addSubview(team1AnimationLabel!)
           
           // Setup floating animation label for team 2
           team2AnimationLabel = UILabel()
           team2AnimationLabel?.textAlignment = .center
           team2AnimationLabel?.font = .boldSystemFont(ofSize: 24)
           team2AnimationLabel?.textColor = .systemGreen
           team2AnimationLabel?.alpha = 0
           view.addSubview(team2AnimationLabel!)
       }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCustomNavigationBar()
    }
    
    
    
    
    private func setupCustomNavigationBar() {
        // Ensure the function is called after view layout when safe area insets are available
        if view.safeAreaInsets.top == 0 {
            // If safe area insets aren't available yet, wait for layout
            DispatchQueue.main.async {
                self.setupCustomNavigationBar()
            }
            return
        }
        
        // Get safe area top inset
        let safeAreaTopInset = view.safeAreaInsets.top
        let navBarHeight: CGFloat = 44
        
        // Create a view that will serve as your navigation bar
        let navBar = UIView(frame: CGRect(x: 0,
                                         y: safeAreaTopInset,
                                         width: view.frame.width,
                                         height: navBarHeight))
        navBar.backgroundColor = .systemBackground
        navBar.tag = 100 // Tag to find and remove if recreated
        
        // Remove any existing navbar (in case this method is called multiple times)
        if let existingNavBar = view.viewWithTag(100) {
            existingNavBar.removeFromSuperview()
        }
        
        // Rest of the code remains the same...
        // (Add bottom border, back button, title label, etc.)
        
        // Add a bottom border to the navigation bar
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: navBar.frame.height - 1, width: navBar.frame.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.systemGray.cgColor
        navBar.layer.addSublayer(bottomBorder)
        
        // Add a back button
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.setTitle("Back", for: .normal)
        backButton.sizeToFit()
        backButton.frame = CGRect(x: 16,
                                 y: (navBar.frame.height - backButton.frame.height)/2,
                                 width: backButton.frame.width,
                                 height: backButton.frame.height)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Add a title label
        let titleLabel = UILabel()
        titleLabel.text = "Game Scoring"
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        titleLabel.center = CGPoint(x: navBar.center.x, y: navBar.frame.height/2)
        
        // Add elements to navigation bar
        navBar.addSubview(backButton)
        navBar.addSubview(titleLabel)
        
        // Add navigation bar to view
        view.addSubview(navBar)
    }
    
    @objc private func backButtonTapped() {
        // Handle back button action
        dismiss(animated: true)
        // or
        // navigationController?.popViewController(animated: true)
    }
    private func animateScoreUpdate(for team: TeamIdentifier, points: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let scoreLabel = team == .team1 ? self.team1score : self.team2score
            guard let scoreLabel = scoreLabel, let superview = scoreLabel.superview else { return }
            
            // Create a full-screen container for the animation
            let animationContainer = UIView(frame: UIScreen.main.bounds)
            animationContainer.backgroundColor = .clear
            UIApplication.shared.windows.first?.addSubview(animationContainer)
            
            // Add blur effect
            let blurEffect = UIBlurEffect(style: .light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = animationContainer.bounds
            blurView.alpha = 0
            animationContainer.addSubview(blurView)
            
            // Create vibrancy effect for better text visibility on blur
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            vibrancyView.frame = blurView.bounds
            blurView.contentView.addSubview(vibrancyView)
            
            // Create a large animated label
            let pointsLabel = UILabel()
            pointsLabel.text = "+\(points)"
            pointsLabel.textColor = team == .team1 ? .systemBlue : .systemRed
            pointsLabel.font = UIFont.systemFont(ofSize: 60, weight: .heavy)
            pointsLabel.textAlignment = .center
            pointsLabel.alpha = 0
            pointsLabel.translatesAutoresizingMaskIntoConstraints = false
            animationContainer.addSubview(pointsLabel)
            
            // Center the label in the screen
            NSLayoutConstraint.activate([
                pointsLabel.centerXAnchor.constraint(equalTo: animationContainer.centerXAnchor),
                pointsLabel.centerYAnchor.constraint(equalTo: animationContainer.centerYAnchor)
            ])
            
            // Create a pulse effect view behind the score
            let pulseView = UIView()
            pulseView.backgroundColor = team == .team1 ? UIColor.systemBlue.withAlphaComponent(0.3) : UIColor.systemRed.withAlphaComponent(0.3)
            pulseView.layer.cornerRadius = 50
            pulseView.alpha = 0
            pulseView.translatesAutoresizingMaskIntoConstraints = false
            animationContainer.insertSubview(pulseView, belowSubview: pointsLabel)
            animationContainer.bringSubviewToFront(pointsLabel)
            
            NSLayoutConstraint.activate([
                pulseView.centerXAnchor.constraint(equalTo: pointsLabel.centerXAnchor),
                pulseView.centerYAnchor.constraint(equalTo: pointsLabel.centerYAnchor),
                pulseView.widthAnchor.constraint(equalToConstant: 100),
                pulseView.heightAnchor.constraint(equalToConstant: 100)
            ])
            
            // Scale up the score label with a bounce effect
            scoreLabel.transform = .identity
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
                scoreLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    scoreLabel.transform = .identity
                }
            }
            
            // Main animation sequence
            UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: [], animations: {
                // Fade in blur
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
                    blurView.alpha = 0.8
                }
                
                // Fade in and scale up pulse
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
                    pulseView.alpha = 1
                    pulseView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }
                
                // Fade in points label
                UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.2) {
                    pointsLabel.alpha = 1
                    pointsLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }
                
                // Hold animation
                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3) {
                    pointsLabel.transform = .identity
                    pulseView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                }
                
                // Begin fade out
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                    pointsLabel.alpha = 0
                    pointsLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    pulseView.alpha = 0
                    pulseView.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
                    blurView.alpha = 0
                }
            }) { _ in
                // Clean up
                animationContainer.removeFromSuperview()
            }
        }
    }
    
//MARK: INTIALIZE TEAMS
    private var userNames: [UUID: String] = [:] // Dictionary to store userID -> player name mapping

    private func initializeTeams() {
        Task {
            do {
                // Fetch all team members
                let allMembers: [TeamMembershipTable] = try await supabase
                    .from("teamMembership")
                    .select()
                    .execute()
                    .value
                
                // Extract all userIDs
                let userIDs = allMembers.map { $0.userID }

                // Fetch users in a single query
                let users: [Usertable] = try await supabase
                    .from("User")
                    .select()
                    .in("userID", values: userIDs)
                    .execute()
                    .value
                
                // Create a dictionary of userID -> name
                for user in users {
                    userNames[user.userID] = user.name
                }

                // Assign team members to respective teams
                if let yourTeamID = yourTeam?.teamID {
                    yourTeamMembers = allMembers.filter { $0.teamID == yourTeamID }
                    team1 = Team(name: yourTeam?.teamName ?? "Team 1", players: mapMembersToPlayers(yourTeamMembers))
                }
                
                if let opponentTeamID = opponentTeam?.teamID {
                    opponentTeamMembers = allMembers.filter { $0.teamID == opponentTeamID }
                    team2 = Team(name: opponentTeam?.teamName ?? "Team 2", players: mapMembersToPlayers(opponentTeamMembers))
                }

                // Refresh UI
                DispatchQueue.main.async {
                    self.updateHeaderUI()
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching teams and players: \(LocalizedError.self)")
            }
        }
    }

    
    // MARK: - Helper to Convert TeamMembershipTable to Player
    private func mapMembersToPlayers(_ members: [TeamMembershipTable]) -> [Player] {
        return members.map { member in
            let playerName = userNames[member.userID] ?? "Unknown Player"
            return Player(name: playerName, reb: 0, ast: 0, stl: 0, foul: 0, pts: 0, points3: 0, freeThrows: 0, missed2Points: 0, missed3Points: 0)
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupUI() {
        // Configure save button
        saveButton.layer.cornerRadius = 12
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        saveButton.layer.shadowRadius = 5
        saveButton.layer.shadowOpacity = 0.15
        
        // Configure action buttons with consistent styling
        for button in actionButtons {
            // Use slightly smaller corner radius for a more modern look
            button.layer.cornerRadius = 12
            
            // Apply single color styling
            button.backgroundColor = UIColor.systemGray5
            button.setTitleColor(.darkGray, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            
            // Add subtle shadow for depth
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 1)
            button.layer.shadowRadius = 3
            button.layer.shadowOpacity = 0.1
        }
    }
    
    private func updateHeaderUI() {
        teamName1Label.text = yourTeam?.teamName ?? "Your Team"
        teamName2Label.text = opponentTeam?.teamName ?? "Opponent Team"
        team1score.text = "\(team1Score)"
        team2score.text = "\(team2Score)"
        
        teamLogo1.layer.cornerRadius = teamLogo1.frame.width / 2
        teamLogo1.clipsToBounds = true
        
        teamLogo2.layer.cornerRadius = teamLogo2.frame.width / 2
        teamLogo2.clipsToBounds = true
        
        teamLogo1.image = UIImage(named: (yourTeam?.teamLogo!)!)
        teamLogo2.image = UIImage(named: (opponentTeam?.teamLogo!)!)
        
//        if let logoName = yourTeam?.teamLogo, let teamImage = UIImage(named: logoName) {
//            teamLogo1.image = teamImage
//        } else {
//            teamLogo1.image = UIImage(named: "default_team_logo") // Provide a fallback image
//        }        //teamLogo1.image = UIImage(named: "team1") // Replace with your actual image names
//        //teamLogo2.image = UIImage(named: "team2")
//        if let logoName2 = yourTeam?.teamLogo, let teamImage2 = UIImage(named: logoName2) {
//            teamLogo2.image = teamImage2
//        } else {
//            teamLogo2.image = UIImage(named: "default_team_logo") // Provide a fallback image
//        }
        //teamLogo2.image = UIImage(named: (opponentTeam?.teamLogo!)!)
    }
    
    
    
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        // Reset all buttons to default style
        for button in actionButtons {
            button.backgroundColor = UIColor.systemGray5
            button.setTitleColor(.darkGray, for: .normal)
            button.layer.shadowOpacity = 0.1
        }
        
        // If tapping the same button again, deselect it
        if selectedAction == sender.titleLabel?.text {
            selectedAction = nil
            return
        }
        
        // Highlight the selected button with a more subtle approach
        sender.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.9)
        sender.setTitleColor(.white, for: .normal)
        sender.layer.shadowOpacity = 0.2
        
        // Store the selected action
        selectedAction = sender.titleLabel?.text
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = self.view.center
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            print("Team 1 Stats: \(team1.players)")
            print("Team 2 Stats: \(team2.players)")
            print("Team 1 Score: \(team1Score), Team 2 Score: \(team2Score)")
            
            let newGame = GameTable(
                gameID: UUID(),
                team1ID: yourTeam?.teamID ?? UUID(),
                team2ID: opponentTeam?.teamID ?? UUID(),
                dateOfGame: ISO8601DateFormatter().string(from: Date()),
                venue: "Some Venue",
                team1finalScore: team1Score,
                team2finalScore: team2Score
            )
            
            Task {
                do {
                    // Insert the new game into the GameTable
                    try await supabase.from("Game").insert(newGame).execute()
                    
                    // Fetch player IDs for both teams
                    let team1Members: [TeamMembershipTable] = try await supabase
                        .from("teamMembership")
                        .select()
                        .eq("teamID", value: newGame.team1ID)
                        .execute()
                        .value
                    
                    let team2Members: [TeamMembershipTable] = try await supabase
                        .from("teamMembership")
                        .select()
                        .eq("teamID", value: newGame.team2ID)
                        .execute()
                        .value
                    
                    let team1PlayerIDs = team1Members.map { $0.userID }
                    let team2PlayerIDs = team2Members.map { $0.userID }
                    
                    // Insert game logs and update player stats
                    for (index, player) in team1.players.enumerated() {
                        if index < team1PlayerIDs.count {
                            let playerID = team1PlayerIDs[index]
                            let gameLog = GameLogtable(
                                logID: UUID(),
                                gameID: newGame.gameID,
                                teamID: newGame.team1ID,
                                playerID: playerID,
                                points2: player.pts,
                                points3: player.points3,
                                freeThrows: player.freeThrows,
                                rebounds: player.reb,
                                assists: player.ast,
                                steals: player.stl,
                                fouls: player.foul,
                                missed2Points: player.missed2Points,
                                missed3Points: player.missed3Points
                            )
                            try await supabase.from("GameLog").insert(gameLog).execute()
                            try await updatePlayerStats(playerID: playerID, newPoints: gameLog.totalPoints, newRebounds: player.reb, newAssists: player.ast)
                        }
                    }
                    
                    for (index, player) in team2.players.enumerated() {
                        if index < team2PlayerIDs.count {
                            let playerID = team2PlayerIDs[index]
                            let gameLog = GameLogtable(
                                logID: UUID(),
                                gameID: newGame.gameID,
                                teamID: newGame.team2ID,
                                playerID: playerID,
                                points2: player.pts,
                                points3: player.points3,
                                freeThrows: player.freeThrows,
                                rebounds: player.reb,
                                assists: player.ast,
                                steals: player.stl,
                                fouls: player.foul,
                                missed2Points: player.missed2Points,
                                missed3Points: player.missed3Points
                            )
                            try await supabase.from("GameLog").insert(gameLog).execute()
                            
                            try await updatePlayerStats(playerID: playerID, newPoints: gameLog.totalPoints, newRebounds: player.reb, newAssists: player.ast)
                        }
                    }
                    
                    print("Game data successfully uploaded to Supabase.")
                    
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        self.showAlert(success: true)
                    }
                    
                } catch {
                    print("Error uploading game data to Supabase: \(error)")
                    
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        self.showAlert(success: false)
                    }
                }
            }
        }

    
    @IBAction func saveButtonTapped1(_ sender: UIButton) {
        Task { @MainActor in
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = self.view.center
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            // Fetch player IDs for both teams
            let team1Coaches: [TeamMembershipTable] = try await supabase
                        .from("teamMembership")
                        .select()
                        .eq("teamID", value: yourTeam?.teamID ?? UUID())
                        .eq("roleInTeam", value: "coach") // Filter for coach
                        .execute()
                        .value
        
            let team2Coaches: [TeamMembershipTable] = try await supabase
                           .from("teamMembership")
                           .select()
                           .eq("teamID", value: opponentTeam?.teamID ?? UUID())
                           .eq("roleInTeam", value: "coach")
                           .execute()
                           .value

                    // Ensure at least one coach is found
            guard let team1CoachID = team1Coaches.first?.userID,
                              let team2coachID = team2Coaches.first?.userID else {
                            print("Error: Missing coaches for one or both teams.")
                            return
                        }
            
            let newPendingGame = PendingGameTable(
                            gameID: UUID(),
                            team1ID: yourTeam?.teamID ?? UUID(),
                            team2ID: opponentTeam?.teamID ?? UUID(),
                            dateOfGame: ISO8601DateFormatter().string(from: Date()),
                            venue: "Some Venue",
                            team1finalScore: team1Score,
                            team2finalScore: team2Score,
                            status: "pending",
                            team1coachID: team1CoachID,
                            team2coachID: team2coachID,
                            team1CoachApproval: false, // Pending approval
                            team2CoachApproval: false  // Pending approval
                        )
            
            let team1Members: [TeamMembershipTable] = try await supabase
                .from("teamMembership")
                .select()
                .eq("teamID", value: newPendingGame.team1ID)
                .execute()
                .value
            
            let team2Members: [TeamMembershipTable] = try await supabase
                .from("teamMembership")
                .select()
                .eq("teamID", value: newPendingGame.team2ID)
                .execute()
                .value
            
            // Extract player IDs
            let team1PlayerIDs = team1Members.map { $0.userID }
            let team2PlayerIDs = team2Members.map { $0.userID }
            
            
            Task {
                do {
                    try await supabase.from("PendingGame").insert(newPendingGame).execute()
                    
                    // Insert player stats into PendingGameLog
                    for (index, player) in team1.players.enumerated() {
                        let playerID = team1PlayerIDs[index]
                        let pendingGameLog = PendingGameLogTable(
                            logID: UUID(),
                            gameID: newPendingGame.gameID,
                            teamID: newPendingGame.team1ID,
                            playerID: playerID,
                            points2: player.pts,
                            points3: player.points3,
                            freeThrows: player.freeThrows,
                            rebounds: player.reb,
                            assists: player.ast,
                            steals: player.stl,
                            fouls: player.foul,
                            missed2Points: player.missed2Points,
                            missed3Points: player.missed3Points
                        )
                        try await supabase.from("PendingGameLog").insert(pendingGameLog).execute()
                    }
                    
                    for (index, player) in team2.players.enumerated() {
                        let playerID = team2PlayerIDs[index]
                        let pendingGameLog = PendingGameLogTable(
                            logID: UUID(),
                            gameID: newPendingGame.gameID,
                            teamID: newPendingGame.team2ID,
                            playerID: playerID,
                            points2: player.pts,
                            points3: player.points3,
                            freeThrows: player.freeThrows,
                            rebounds: player.reb,
                            assists: player.ast,
                            steals: player.stl,
                            fouls: player.foul,
                            missed2Points: player.missed2Points,
                            missed3Points: player.missed3Points
                        )
                        try await supabase.from("PendingGameLog").insert(pendingGameLog).execute()
                    }
                    
                    print("Game submitted for coach approval.")
                    
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        self.showAlert2(success: true, message: "Game submitted for approval.")
                    }
                    
                } catch {
                    print("Error submitting game data: \(error)")
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        self.showAlert2(success: false, message: "Error submitting game.")
                    }
                }
            }
        }
    }
        //MARK:   Function to display an alert and navigate on success
        func showAlert(success: Bool) {
            let message = success ? "Game data successfully uploaded!" : "Failed to upload game data. Please try again."
            let alert = UIAlertController(title: "Upload Status", message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                if success {
                    self.navigateToHome()
                }
            }
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    
    func showAlert2(success: Bool, message: String) {
        let alert = UIAlertController(
            title: success ? "Success" : "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                if success {
                    self?.navigateToHome()
                }
            }))
        present(alert, animated: true)
    }

        // Function to handle navigation
    private func navigateToHome() {
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
                    transition.subtype = .fromLeft // 👈 This makes the screen slide in from the right (left-to-right effect)
                    view.window?.layer.add(transition, forKey: kCATransition)
                    
                    homeVC.modalPresentationStyle = .fullScreen
                    self.present(homeVC, animated: false, completion: nil) // `animated: false` because we're handling animation manually
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
        
    
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Two sections: Team 1 and Team 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? team1.players.count : team2.players.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? team1.name : team2.name
    }
    
    private let scoreUpdateQueue = DispatchQueue(label: "com.athlinix.scoreupdates")
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemberScoreTableViewCell", for: indexPath) as? MemberScoreTableViewCell else {
                return UITableViewCell()
            }
            
            let player = indexPath.section == 0 ? team1.players[indexPath.row] : team2.players[indexPath.row]
            cell.configure(with: player)
            
            // Apply highlight if this is the last modified cell
            if indexPath == lastHighlightedIndexPath {
                cell.contentView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)
            } else {
                cell.contentView.backgroundColor = .clear
            }
            
            return cell
        }
    
    private func highlightCell(at indexPath: IndexPath) {
            lastHighlightedIndexPath = indexPath
            tableView.reloadRows(at: [indexPath], with: .none)
            
            // Remove highlight after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + highlightDuration) { [weak self] in
                guard let self = self else { return }
                self.lastHighlightedIndexPath = nil
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let action = selectedAction else {
                print("No action selected")
                return
            }
            
            if indexPath.section == 0 {
                updatePlayer(&team1.players[indexPath.row], with: action, forTeam: .team1, at: indexPath)
            } else {
                updatePlayer(&team2.players[indexPath.row], with: action, forTeam: .team2, at: indexPath)
            }
            
            // Deselect the action button after use
            deselectActionButton()
            
            tableView.reloadData()
            updateHeaderUI()
        }
    
    private enum TeamIdentifier {
            case team1
            case team2
    }
    
    private func deselectActionButton() {
            // Reset all buttons to default style
            for button in actionButtons {
                if button.titleLabel?.text == selectedAction {
                    button.backgroundColor = .lightGray
                }
            }
            selectedAction = nil
        }
    
    
    
    // MARK: - Player Stats Update
    private func updatePlayer(_ player: inout Player, with action: String, forTeam team: TeamIdentifier, at indexPath: IndexPath) {
            scoreUpdateQueue.sync {
                // Store previous state for undo
                let previousState = player
                var scoreChange = 0
                
                switch action {
                case "+2 PFG":
                    player.pts += 2
                    scoreChange = 2
                    updateTeamScore(for: team, points: 2)
                case "FREE THROW":
                    player.pts += 1
                    scoreChange = 1
                    updateTeamScore(for: team, points: 1)
                case "+3 PFG":
                    player.pts += 3
                    scoreChange = 3
                    updateTeamScore(for: team, points: 3)
                case "REBOUND":
                    player.reb += 1
                    print("Rebound updated for player: \(player.name), new rebounds: \(player.reb)")
                    
                case "ASSIST":
                    player.ast += 1
                case "STEAL":
                    player.stl += 1
                case "FOUL":
                    player.foul += 1
                default:
                    print("Unknown action")
                }
                
                // Store the action for potential undo
                lastAction = Action(
                    player: player,
                    previousState: previousState,
                    team: team,
                    indexPath: indexPath,
                    scoreChange: scoreChange
                )
                
                DispatchQueue.main.async { [weak self] in
                                self?.updateUndoButtonState()
                                self?.highlightCell(at: indexPath)
                            }
            }
        }
    
    private func updateTeamScore(for team: TeamIdentifier, points: Int) {
            switch team {
            case .team1:
                team1Score += points
            case .team2:
                team2Score += points
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.updateHeaderUI()
                self?.animateScoreUpdate(for: team, points: points)
            }
        }
    
    func updatePlayerStats(playerID: UUID, newPoints: Int, newRebounds: Int, newAssists: Int) async throws {
        do {
            // Fetch player's current stats
            let playerStats: [AthleteProfileTable] = try await supabase
                .from("AthleteProfile")
                .select()
                .eq("athleteID", value: playerID)
                .execute()
                .value

            guard var currentStats = playerStats.first else { return }

            // Calculate total games played by fetching existing game logs
            let previousGameLogs: [GameLogtable] = try await supabase
                .from("GameLog")
                .select()
                .eq("playerID", value: playerID)
                .execute()
                .value

            let previousGamesCount = previousGameLogs.count

            // Compute new averages
            let updatedAvgPoints = ((currentStats.averagePointsPerGame * Float(previousGamesCount)) + Float(newPoints)) / Float(previousGamesCount + 1)
            let updatedAvgRebounds = ((currentStats.averageReboundsPerGame * Float(previousGamesCount)) + Float(newRebounds)) / Float(previousGamesCount + 1)
            let updatedAvgAssists = ((currentStats.averageAssistsPerGame * Float(previousGamesCount)) + Float(newAssists)) / Float(previousGamesCount + 1)
            
            print(")))))))))(((((((")
            
            print(currentStats.averageReboundsPerGame)
            
            print(newRebounds)
            
            print(updatedAvgRebounds)
            
            print(")))))))))(((((((")

            // Update player's average stats
            try await supabase.from("AthleteProfile")
                .update([
                    "averagePointsPerGame": updatedAvgPoints,
                    "averageReboundsPerGame": updatedAvgRebounds,
                    "averageAssistsPerGame": updatedAvgAssists
                ])
                .eq("athleteID", value: playerID)
                .execute()

            print("Updated player stats for playerID: \(playerID)")

        } catch {
            print("Error updating player stats: \(error)")
        }
    }



    
//    private func extractPoints(from action: String) -> Int {
//        if action.contains("+2") { return 2 }
//        if action.contains("+3") { return 3 }
//        if action.contains("FREE THROW") { return 1 }
//        return 0
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UIImageView
extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
