//
//  ViewController.swift
//  MatchHistory
//
//  Created by admin65 on 14/11/24.
//

import UIKit

class TeamMatchHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
  
    var games: [GameTable] = []
    var filteredGames: [GameTable] = []
    var teams: [TeamTable] = []
    var gameLogs: [GameLogtable] = []

    override func viewDidLoad() {
           super.viewDidLoad()
           
           tableView.dataSource = self
           searchBar.delegate = self
           
           Task {
               do {
                   try await fetchGamesAndTeams()
                   filteredGames = games
                   DispatchQueue.main.async {
                       self.tableView.reloadData()
                   }
               } catch {
                   print("Error fetching data: \(error)")
               }
           }
        
        setupBackButton()
        
        
       }
       
       // MARK: - Fetch Games, Teams, and Logs
    func fetchGamesAndTeams() async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Get session user ID
        guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
            print("Error: No session user is set")
            return
        }

        // Fetch all game logs
        let gameLogsResponse = try await supabase
            .from("GameLog")
            .select("*")
            .execute()
        gameLogs = try decoder.decode([GameLogtable].self, from: gameLogsResponse.data)

        // Filter game logs to only those where the session user has played
        let userGameLogs = gameLogs.filter { $0.playerID == sessionUserID }

        // Extract game IDs from the filtered logs
        let userGameIDs = Set(userGameLogs.map { $0.gameID })

        // Fetch games
        let gamesResponse = try await supabase
            .from("Game")
            .select("*")
            .execute()
        let allGames = try decoder.decode([GameTable].self, from: gamesResponse.data)

        // Filter games to only those played by the session user
        games = allGames.filter { userGameIDs.contains($0.gameID) }

        // Fetch teams
        let teamsResponse = try await supabase
            .from("teams")
            .select("*")
            .execute()
        teams = try decoder.decode([TeamTable].self, from: teamsResponse.data)

        // Update filteredGames to reflect the session user's matches
        filteredGames = games

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }



       
       // MARK: - Get game stats function
    func getGameStats(gameID: UUID) -> (team1Name: String, team1Logo: String, team2Name: String, team2Logo: String, team1Stats: [String: Int], team2Stats: [String: Int]) {
        // Find the game by ID
        guard let game = games.first(where: { $0.gameID == gameID }) else {
            fatalError("Game not found")
        }
        
        // Retrieve the teams
        guard let team1 = teams.first(where: { $0.teamID == game.team1ID }),
              let team2 = teams.first(where: { $0.teamID == game.team2ID }) else {
            fatalError("Teams not found")
        }

        // Get the game logs for the game
        let team1GameLogs = gameLogs.filter { $0.gameID == gameID && $0.teamID == game.team1ID }
        let team2GameLogs = gameLogs.filter { $0.gameID == gameID && $0.teamID == game.team2ID }
           
        // Calculate total stats for Team 1
        let team1Stats = [
            "2pt Field Goals": team1GameLogs.reduce(0) { $0 + $1.points2 },
            "3pt Field Goals": team1GameLogs.reduce(0) { $0 + $1.points3 },
            "Free Throws": team1GameLogs.reduce(0) { $0 + $1.freeThrows },
            "Rebounds": team1GameLogs.reduce(0) { $0 + $1.rebounds },
            "Assists": team1GameLogs.reduce(0) { $0 + $1.assists },
            "Steals": team1GameLogs.reduce(0) { $0 + $1.steals },
            "Fouls": team1GameLogs.reduce(0) { $0 + $1.fouls }
        ]
        
        // Calculate total stats for Team 2
        let team2Stats = [
            "2pt Field Goals": team2GameLogs.reduce(0) { $0 + $1.points2 },
            "3pt Field Goals": team2GameLogs.reduce(0) { $0 + $1.points3 },
            "Free Throws": team2GameLogs.reduce(0) { $0 + $1.freeThrows },
            "Rebounds": team2GameLogs.reduce(0) { $0 + $1.rebounds },
            "Assists": team2GameLogs.reduce(0) { $0 + $1.assists },
            "Steals": team2GameLogs.reduce(0) { $0 + $1.steals },
            "Fouls": team2GameLogs.reduce(0) { $0 + $1.fouls }
        ]
        
        // Use a default value for optional team logos
        let team1Logo = team1.teamLogo ?? "default_logo"
        let team2Logo = team2.teamLogo ?? "default_logo"
        
        // Return the result
        return (team1Name: team1.teamName, team1Logo: team1Logo, team2Name: team2.teamName, team2Logo: team2Logo, team1Stats: team1Stats, team2Stats: team2Stats)
    }



       
       // MARK: - Search Functionality
       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           if searchText.isEmpty {
               filteredGames = games
           } else {
               filteredGames = games.filter { game in
                   guard let team1 = teams.first(where: { $0.teamID == game.team1ID }),
                         let team2 = teams.first(where: { $0.teamID == game.team2ID }) else {
                       return false
                   }
                   return team1.teamName.lowercased().contains(searchText.lowercased()) ||
                          team2.teamName.lowercased().contains(searchText.lowercased())
               }
           }
           tableView.reloadData()
       }

       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.text = ""
           filteredGames = games
           tableView.reloadData()
           searchBar.resignFirstResponder()
       }
       
       // MARK: - UITableViewDataSource
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return filteredGames.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "MatchTableViewCell", for: indexPath) as! MatchTableViewCell
           let game = filteredGames[indexPath.row]
           let gameStats = getGameStats(gameID: game.gameID)
           cell.configure(with: gameStats)
           //print(cell)
           return cell
       }
       

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedGame = filteredGames[indexPath.row]
        
        // Initialize StatsViewController programmatically
        let statsVC = storyboard?.instantiateViewController(withIdentifier: "StatsViewController") as? StatsViewController
       // let statsVC = StatsViewController()
        statsVC!.selectedGame = selectedGame

        
        // Print debugging information
        print("Navigating to StatsViewController with selected game: \(selectedGame)")
        
        // Present the StatsViewController
        
        
        navigationController?.pushViewController(statsVC!, animated: true)
    }
    
    private func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }

    // Back button action
    @objc private func backButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .push
            transition.subtype = .fromLeft  // This makes it slide in from the left
            view.window?.layer.add(transition, forKey: kCATransition)
            
            homeVC.modalPresentationStyle = .fullScreen
            self.present(homeVC, animated: false, completion: nil)  // animated should be false to avoid conflicts
        } else {
            print("Could not instantiate MainTabBarController")
        }
    }

}
