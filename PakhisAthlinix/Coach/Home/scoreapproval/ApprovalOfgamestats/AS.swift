//
//  ViewController.swift
//  MATCHES
//
//  Created by admin65 on 15/11/24.
//

import UIKit
import SDWebImage
import SDWebImageMapKit

class AS: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var team1Logo: UIImageView!
    @IBOutlet weak var team2Logo: UIImageView!
    @IBOutlet weak var team1Name: UILabel!
    @IBOutlet weak var team1Score: UILabel!
    @IBOutlet weak var team2Score: UILabel!
    @IBOutlet weak var team2Name: UILabel!
    
    
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var playerStackView: UITableView!
    
    @IBOutlet weak var playerLabel: UILabel!
    
    private var pendingGames: [PendingGameTable] = []
    
       var selectedGame: PendingGameTable?
       var selectedTeam: TeamTable?
       var stats: [(category: String, team1Value: Int, team2Value: Int)] = []
       var gameLogs: [PendingGameLogTable] = []
       var users: [Usertable] = []
       var teams1: [TeamTable] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingIndicator.shared.show(in: view)
        
        print("playerStackView: \(String(describing: playerStackView))")
        playerStackView.dataSource = self
        playerStackView.delegate = self

        if selectedGame != nil {
            Task {
                await fetchInitialData()
                updateUI()  // Move this inside to ensure data is available
                LoadingIndicator.shared.hide()
            }
        } else {
            print("No selected game passed!")
            LoadingIndicator.shared.hide()
        }
        
        print("StatsViewController received game: \(String(describing: selectedGame))")
        
        team1Logo.layer.cornerRadius = team1Logo.frame.size.width / 2
        team1Logo.clipsToBounds = true
        team2Logo.layer.cornerRadius = team2Logo.frame.size.width / 2
        team2Logo.clipsToBounds = true
        
        // Add a bottom border
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = UIColor.lightGray.cgColor // Or any color you prefer
        
    }

     // MARK: - Fetch Data
     func fetchInitialData() async {
         do {
             // Fetch games
             let gamesResponse = try await supabase.from("PendingGame").select("*").execute()
             let gamesDecoder = JSONDecoder()
             let games = try gamesDecoder.decode([PendingGameTable].self, from: gamesResponse.data)

             // Fetch teams
             let teamsResponse = try await supabase.from("teams").select("*").execute()
             let teamsDecoder = JSONDecoder()
             self.teams1 = try teamsDecoder.decode([TeamTable].self, from: teamsResponse.data)

             // Fetch game logs
             let gameLogsResponse = try await supabase.from("PendingGameLog").select("*").execute()
             let gameLogsDecoder = JSONDecoder()
             self.gameLogs = try gameLogsDecoder.decode([PendingGameLogTable].self, from: gameLogsResponse.data)

             // Fetch users
             let usersResponse = try await supabase.from("User").select("*").execute()
             let usersDecoder = JSONDecoder()
             self.users = try usersDecoder.decode([Usertable].self, from: usersResponse.data)

             // Select the first game by default
             // self.selectedGame = games[2]
             LoadingIndicator.shared.hide()

         } catch {
             print("Error fetching data: \(error)")
             LoadingIndicator.shared.hide()
         }
     }

     // MARK: - Update UI
     func updateUI() {
         guard let selectedGame = selectedGame else { return }
         
         let team1 = teams1.first { $0.teamID == selectedGame.team1ID }
         let team2 = teams1.first { $0.teamID == selectedGame.team2ID }
         
         guard let team1 = team1, let team2 = team2 else {
             print("Teams not found for the selected game.")
             return
         }

         // Calculate scores
         let team1ScoreValue = calculateTeamScore(teamID: team1.teamID, gameID: selectedGame.gameID)
         let team2ScoreValue = calculateTeamScore(teamID: team2.teamID, gameID: selectedGame.gameID)

//          Set UI elements
//         team1Logo.image = UIImage(named: team1.teamLogo ?? "defaultTeamLogo")
//         team2Logo.image = UIImage(named: team2.teamLogo ?? "defaultTeamLogo")
         
         if let imageName = team1.teamLogo,
            let localImage = UIImage(named: imageName) {
             team1Logo.image = localImage
         } else if let imageUrlString = team1.teamLogo,
                   let imageUrl = URL(string: imageUrlString) {
             team1Logo.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defaultTeamLogo"))
         }
         
         if let newimageName = team2.teamLogo,
            let localImage = UIImage(named: newimageName) {
             team2Logo.image = localImage
         } else if let imageUrlString = team2.teamLogo,
                   let imageUrl = URL(string: imageUrlString) {
             team2Logo.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defaultTeamLogo"))
         }
         
         team1Name.text = team1.teamName
         team2Name.text = team2.teamName
         team1Score.text = "\(team1ScoreValue)"
         team2Score.text = "\(team2ScoreValue)"
         segmentedController.setTitle(team1.teamName, forSegmentAt: 0)
         segmentedController.setTitle(team2.teamName, forSegmentAt: 1)
         segmentedController.setTitle("Game Stats", forSegmentAt: 2)

         // Populate stats
         stats = calculateGameStats(gameID: selectedGame.gameID, team1ID: team1.teamID, team2ID: team2.teamID)
         selectedTeam = team1
         
         playerStackView.reloadData()
         LoadingIndicator.shared.hide()
     }

    
        //MARK: SWITCH TABLE VIEW
        @IBAction func switchTableViewAction(_ sender: UISegmentedControl) {
            switch sender.selectedSegmentIndex {
                    case 0, 1: // Team 1 or Team 2
                        labelStackView.isHidden = false
                        playerLabel.isHidden = false
                        playerStackView.isHidden = false
                        selectedTeam = sender.selectedSegmentIndex == 0 ? teams1.first { $0.teamID == selectedGame?.team1ID } : teams1.first { $0.teamID == selectedGame?.team2ID }
                    case 2: // Game Stats
                        labelStackView.isHidden = true
                        playerLabel.isHidden = true
                        playerStackView.isHidden = false
                    default:
                        labelStackView.isHidden = false
                        playerLabel.isHidden = false
                        playerStackView.isHidden = false
                        selectedTeam = sender.selectedSegmentIndex == 0 ? teams1.first { $0.teamID == selectedGame?.team1ID } : teams1.first { $0.teamID == selectedGame?.team2ID }
                    }
                    playerStackView.reloadData()
                }
    
        // MARK: UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedController.selectedSegmentIndex {
                case 0, 1:
                    return gameLogs.filter { $0.teamID == selectedTeam?.teamID && $0.gameID == selectedGame?.gameID }.count
                case 2:
                    return stats.count
                default:
                    return gameLogs.filter { $0.teamID == selectedTeam?.teamID && $0.gameID == selectedGame?.gameID }.count
                }
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovePlayerStatsCell", for: indexPath) as? ApprovePlayersStatsTableViewCell else {
            let playerLogs = gameLogs.filter { $0.teamID == selectedTeam?.teamID && $0.gameID == selectedGame?.gameID }
            _ = playerLogs[indexPath.row]
            if indexPath.row >= playerLogs.count {
                print("⚠️ Index out of bounds! indexPath.row: \(indexPath.row), playerLogs.count: \(playerLogs.count)")
                return UITableViewCell()  // Prevents a crash
            }
            return UITableViewCell()  // Prevents a crash
        }

        switch segmentedController.selectedSegmentIndex {
              case 0, 1:
            let playerLogs = gameLogs.filter { $0.teamID == selectedTeam?.teamID && $0.gameID == selectedGame?.gameID }
            
                  let playerLog = playerLogs[indexPath.row]
                  let playerName = users.first { $0.userID == playerLog.playerID }?.name ?? "Unknown Player"
                  cell.resetCell()
                  cell.configure(with: playerLog, playerName: playerName)
                  cell.setCategoryView(hidden: true)
              case 2:
                  let stat = stats[indexPath.row]
                  cell.resetCell()
                  cell.configureCategoryCell(with: stat.category, team1Value: stat.team1Value, team2Value: stat.team2Value)
                  cell.setPlayerView(hidden: true)
              default:
                    let playerLogs = gameLogs.filter { $0.teamID == selectedTeam?.teamID && $0.gameID == selectedGame?.gameID }
                    let playerLog = playerLogs[indexPath.row]
                    let playerName = users.first { $0.userID == playerLog.playerID }?.name ?? "Unknown Player"
                    cell.resetCell()
                    cell.configure(with: playerLog, playerName: playerName)
                    cell.setCategoryView(hidden: true)
              }

              return cell
          }
    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 45
        }

        //MARK: Helper Methods
    private func calculateTeamScore(teamID: UUID, gameID: UUID) -> Int {
          let teamLogs = gameLogs.filter { $0.teamID == teamID && $0.gameID == gameID }
          return teamLogs.reduce(0) { $0 + ($1.points2 * 2) + ($1.points3 * 3) + $1.freeThrows }
      }

    private func calculateGameStats(gameID: UUID, team1ID: UUID, team2ID: UUID) -> [(category: String, team1Value: Int, team2Value: Int)] {
          let team1Logs = gameLogs.filter { $0.teamID == team1ID && $0.gameID == gameID }
          let team2Logs = gameLogs.filter { $0.teamID == team2ID && $0.gameID == gameID }

          func statSum(for logs: [PendingGameLogTable], keyPath: KeyPath<PendingGameLogTable, Int>) -> Int {
              return logs.reduce(0) { $0 + $1[keyPath: keyPath] }
          }

          return [
              ("Field Goals", statSum(for: team1Logs, keyPath: \.points2), statSum(for: team2Logs, keyPath: \.points2)),
              ("3P Field Goals", statSum(for: team1Logs, keyPath: \.points3), statSum(for: team2Logs, keyPath: \.points3)),
              ("Free Throws", statSum(for: team1Logs, keyPath: \.freeThrows), statSum(for: team2Logs, keyPath: \.freeThrows)),
              ("Rebounds", statSum(for: team1Logs, keyPath: \.rebounds), statSum(for: team2Logs, keyPath: \.rebounds)),
              ("Assists", statSum(for: team1Logs, keyPath: \.assists), statSum(for: team2Logs, keyPath: \.assists)),
              ("Steals", statSum(for: team1Logs, keyPath: \.steals), statSum(for: team2Logs, keyPath: \.steals)),
              ("Fouls", statSum(for: team1Logs, keyPath: \.fouls), statSum(for: team2Logs, keyPath: \.fouls))
          ]
      }
    
    @IBAction func approveButtonTapped(_ sender: UIButton) {
        Task {
                    do {
                        try await approveGame(gameID: selectedGame!.gameID, coachID: await SessionManager.shared.getSessionUser()!, isApproved: true)
                        showAlert(title: "Success", message: "Game approved successfully!")
                        LoadingIndicator.shared.hide()
                    } catch {
                        showAlert(title: "Error", message: "Failed to approve game.")
                        LoadingIndicator.shared.hide()
                    }
                }
    }
    
    @IBAction func rejectButtonTapped(_ sender: UIButton) {
//        Task {
//            do {
//                try await rejectGame(gameID: selectedGameID, coachID: currentUserID)
//                self.showAlert2(success: false, message: "Game rejected.")
//            } catch {
//                print("Error rejecting game: \(error)")
//            }
//        }
        Task {
                    do {
                        try await approveGame(gameID: selectedGame!.gameID, coachID: await SessionManager.shared.getSessionUser()!, isApproved: false)
                        showAlert(title: "Success", message: "Game rejected.")
                    } catch {
                        showAlert(title: "Error", message: "Failed to reject game.")
                    }
                }
    }
    
    func approveGame(gameID: UUID, coachID: UUID, isApproved: Bool) async throws {
        do {
            // Fetch the pending game
            let response = try await supabase
                .from("PendingGame")
                .select("*")
                .eq("gameID", value: gameID.uuidString)
                .single()
                .execute()

            guard let game = try? JSONDecoder().decode(PendingGameTable.self, from: response.data) else {
                print("Game not found or decoding error")
                return
            }
            
            try await moveToMainTables(game: game)
            print(game)

//            var updateData: [String: Any] = [:]
//
//            // Check which coach is approving/rejecting
//            if game.team1coachID == coachID {
//                updateData["team1CoachApproval"] = true
//            } else if game.team2coachID == coachID {
//                updateData["team2CoachApproval"] = true
//            } else {
//                print("Coach not authorized to approve this game")
//                return
//            }
//
//            // Update pending game approval status
//            try await supabase.from("PendingGame")
//                .update([
//                    "team1CoachApproval": game.team1CoachApproval,
//                    "team2CoachApproval": game.team2CoachApproval
//                ])
//                .eq("gameID", value: gameID.uuidString)
//                .execute()
//
//            // Check if both coaches have approved
//            if let team1Approval = game.team1CoachApproval, let team2Approval = game.team2CoachApproval {
//                if team1Approval && team2Approval {
//                    try await moveToMainTables(game: game)
//                } else if !team1Approval || !team2Approval {
//                    // Mark the game as rejected
//                    try await supabase.from("PendingGame")
//                        .update(["status": "rejected"])
//                        .eq("gameID", value: gameID.uuidString)
//                        .execute()
//                }
//            }
        } catch {
            print("Error approving game: \(error)")
        }
    }

    // Move game to main tables once approved
    func moveToMainTables(game: PendingGameTable) async throws {
        do {
            // Insert into GameTable
            let newGame = GameTable(gameID: game.gameID, team1ID: game.team1ID, team2ID: game.team2ID, dateOfGame: game.dateOfGame, venue: game.venue, team1finalScore: game.team1finalScore, team2finalScore: game.team2finalScore)

            try await supabase.from("Game").insert(newGame).execute()
            print(newGame)

            // Fetch and move all game logs
            let logsResponse = try await supabase
                .from("PendingGameLog")
                .select("*")
                .eq("gameID", value: game.gameID.uuidString)
                .execute()

            let gameLogs = try JSONDecoder().decode([PendingGameLogTable].self, from: logsResponse.data)

            for log in gameLogs {
                
                let newLog = GameLogtable(logID: log.logID, gameID: log.gameID, teamID: log.teamID, playerID: log.playerID, points2: log.points2, points3: log.points3, freeThrows: log.freeThrows, rebounds: log.rebounds, assists: log.assists, steals: log.steals, fouls: log.fouls, missed2Points: log.missed2Points, missed3Points: log.missed3Points)

                try await supabase.from("GameLog").insert(newLog).execute()
            }

            // Delete from pending tables
            try await supabase.from("PendingGame").delete().eq("gameID", value: game.gameID.uuidString).execute()
            try await supabase.from("PendingGameLog").delete().eq("gameID", value: game.gameID.uuidString).execute()

            print("Game successfully moved to main tables")

        } catch {
            print("Error moving game to main tables: \(error)")
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }

}
