//
//  ViewTeamDetailViewController.swift.swift
//  PakhisAthlinix
//
//  Created by Vivek Jaglan on 3/17/25.
//

import UIKit

class ViewTeamDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var apgStack: UIStackView!
    @IBOutlet weak var rpgStack: UIStackView!
    @IBOutlet weak var ppgStack: UIStackView!
    @IBOutlet weak var oppgStack: UIStackView!
    @IBOutlet weak var TeamIcon: UIImageView!
    
    @IBOutlet weak var TeamNameLabel12: UILabel!
    @IBOutlet weak var TeamWinPerLabel: UILabel!
    
    @IBOutlet weak var TeamCoachCollectionView: UICollectionView!
    @IBOutlet weak var TeamPlayersCollectionView: UICollectionView!
    @IBOutlet weak var teamOPPGLabel: UILabel!
    @IBOutlet weak var teamAPGLabel: UILabel!
    @IBOutlet weak var teamRPGLabel: UILabel!
    @IBOutlet weak var teamPPGLabel: UILabel!
    @IBOutlet weak var TeamWinLooseCountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var teamID: UUID? // Set this before pushing this screen
    let decoder = JSONDecoder()
    var selectedTeam: TeamTable?
    var teamCoaches: [Usertable] = [] // ✅ Store coaches
    var teamPlayers: [Usertable] = [] // ✅ Store players
    
    var games: [GameTable] = []
    var filteredGames: [GameTable] = []
    var teams: [TeamTable] = []
    var gameLogs: [GameLogtable] = []
    
    @IBOutlet weak var teamHeaderStack: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingIndicator.shared.show(in: view)
        
        let cardStacks = [apgStack, rpgStack, ppgStack, oppgStack]

        for stack in cardStacks {
            stack?.layer.cornerRadius = 12
            stack?.layer.masksToBounds = false
            stack?.layer.shadowColor = UIColor.black.cgColor
            stack?.layer.shadowOpacity = 0.05
            stack?.layer.shadowOffset = CGSize(width: 0, height: 4)
            stack?.layer.shadowRadius = 6
            stack?.backgroundColor = UIColor.systemBackground
        }

        
        guard let team = selectedTeam else {
            print("Error: selectedTeam is nil")
            return
        }
        setupUI(with: team)
        
        TeamCoachCollectionView.delegate = self
        TeamCoachCollectionView.dataSource = self
        TeamPlayersCollectionView.delegate = self
        TeamPlayersCollectionView.dataSource = self
        tableView.dataSource = self
        tableView.delegate = self
        fetchTeamMembers()
        fetchTeamDetails(teamID: selectedTeam!.teamID)
        
        TeamIcon.layer.cornerRadius = TeamIcon.frame.width / 2
        TeamIcon.clipsToBounds = true
        
        
        Task {
            do {
                try await fetchGamesAndTeams(for: selectedTeam!.teamID)
                filteredGames = games
                print(games)
                print(filteredGames)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    LoadingIndicator.shared.hide()
                }
            } catch {
                print("Error fetching data: \(error)")
                LoadingIndicator.shared.hide()
            }
        }
        
    }
    
    func setupUI(with team: TeamTable) {
        
        guard let team = selectedTeam else {
            print("Error: selectedTeam is nil")
            return
        }
        TeamNameLabel12.text = team.teamName.uppercased()
        print(team.teamName)
        //TeamNameLabel12
        print(TeamNameLabel12 as Any)
        //TeamIcon.image = UIImage(named: team.teamLogo!)
        if let imageName = team.teamLogo,
           let localImage = UIImage(named: imageName) {
            TeamIcon.image = localImage
        } else if let imageUrlString = team.teamLogo,
                  let imageUrl = URL(string: imageUrlString) {
            TeamIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
        }
    }
    
    func fetchTeamDetails(teamID: UUID) {
        Task {
            do {
                // Fetch Team Details
                let teamResponse = try await supabase
                    .from("teams")
                    .select("*")
                    .eq("teamID", value: teamID.uuidString)
                    .single()
                    .execute()
                
                _ = try decoder.decode(TeamTable.self, from: teamResponse.data)
                
                // Update UI with Team Details
                
                // Fetch Game Logs for Team Stats
                let gameLogsResponse = try await supabase
                    .from("GameLog")
                    .select("*")
                    .eq("teamID", value: teamID.uuidString)
                    .execute()
                
                let gameLogs = try decoder.decode([GameLogtable].self, from: gameLogsResponse.data)
                
                // Calculate Stats
                let totalGames = gameLogs.count
                
                let totalPoints = gameLogs.reduce(0) { $0 + $1.totalPoints }
                let totalRebounds = gameLogs.reduce(0) { $0 + $1.rebounds }
                let totalAssists = gameLogs.reduce(0) { $0 + $1.assists }
                
                let ppg = totalGames > 0 ? Double(totalPoints) / Double(totalGames) : 0
                let rpg = totalGames > 0 ? Double(totalRebounds) / Double(totalGames) : 0
                let apg = totalGames > 0 ? Double(totalAssists) / Double(totalGames) : 0
                
                // Fetch Games to Calculate Wins/Losses
                let gamesResponse = try await supabase
                    .from("Game")
                    .select("*")
                    .or("team1ID.eq.\(teamID.uuidString),team2ID.eq.\(teamID.uuidString)")
                    .execute()
                
                let games = try decoder.decode([GameTable].self, from: gamesResponse.data)
                
                var wins = 0
                var losses = 0
                var totalOppPoints = 0
                
                for game in games {
                    if game.team1ID == teamID {
                        totalOppPoints += game.team2finalScore
                        if game.team1finalScore > game.team2finalScore {
                            wins += 1
                        } else {
                            losses += 1
                        }
                    } else if game.team2ID == teamID {
                        totalOppPoints += game.team1finalScore
                        if game.team2finalScore > game.team1finalScore {
                            wins += 1
                        } else {
                            losses += 1
                        }
                    }
                }
                
                let oppg = games.count > 0 ? Double(totalOppPoints) / Double(games.count) : 0
                let winPercentage = (wins + losses) > 0 ? Double(wins) / Double(wins + losses) * 100 : 0
                
                // Update UI
                DispatchQueue.main.async {
                    self.teamPPGLabel.text = String(format: "%.2f", ppg)
                    self.teamRPGLabel.text = String(format: "%.2f", rpg)
                    self.teamAPGLabel.text = String(format: "%.2f", apg)
                    self.teamOPPGLabel.text = String(format: "%.2f", oppg)
                    self.TeamWinLooseCountLabel.text = "\(wins) - \(losses)"
                    self.TeamWinPerLabel.text = String(format: "%.2f%", winPercentage)
                    LoadingIndicator.shared.hide()
                }
                
                print(ppg, rpg, apg, oppg, losses, winPercentage)
                
            } catch {
                print("Error fetching team details: \(error)")
                LoadingIndicator.shared.hide()
            }
        }
    }
    
    func fetchTeamMembers() {
        guard let teamID = selectedTeam?.teamID else { return }

        Task {
            do {
                let membershipResponse = try await supabase
                    .from("teamMembership")
                    .select("*")
                    .eq("teamID", value: teamID.uuidString)
                    .execute()
                
                let decoder = JSONDecoder()
                let memberships = try decoder.decode([TeamMembershipTable].self, from: membershipResponse.data)
                
                let playerIDs = memberships
                    .filter { $0.roleInTeam == .athlete } // ✅ Filter Players
                    .map { $0.userID.uuidString }
                
                let coachIDs = memberships
                    .filter { $0.roleInTeam == .coach } // ✅ Filter Coaches
                    .map { $0.userID.uuidString }
                
                // Fetch Players
                let playersResponse = try await supabase
                    .from("User")
                    .select("*")
                    .in("userID", values: playerIDs)
                    .execute()
                teamPlayers = try decoder.decode([Usertable].self, from: playersResponse.data)

                // Fetch Coaches
                let coachesResponse = try await supabase
                    .from("User")
                    .select("*")
                    .in("userID", values: coachIDs)
                    .execute()
                teamCoaches = try decoder.decode([Usertable].self, from: coachesResponse.data)
                
                // Reload Collection Views
                DispatchQueue.main.async {
                    self.TeamCoachCollectionView.reloadData()
                    self.TeamPlayersCollectionView.reloadData()
                    LoadingIndicator.shared.hide()
                }

            } catch {
                print("Error fetching team members: \(error)")
                LoadingIndicator.shared.hide()
            }
        }
    }
    //
    // MARK: - Match Histroy
    //Fetch Games, Teams, and Logs
 func fetchGamesAndTeams(for teamUUID: UUID) async throws {
     let decoder = JSONDecoder()
     decoder.dateDecodingStrategy = .iso8601

     // Fetch all game logs
     let gameLogsResponse = try await supabase
         .from("GameLog")
         .select("*")
         .execute()
     gameLogs = try decoder.decode([GameLogtable].self, from: gameLogsResponse.data)

     // Filter game logs to only those where the given team has played
     let teamGameLogs = gameLogs.filter { $0.teamID == teamUUID }

     // Extract game IDs from the filtered logs
     let teamGameIDs = Set(teamGameLogs.map { $0.gameID })

     // Fetch all games
     let gamesResponse = try await supabase
         .from("Game")
         .select("*")
         .execute()
     let allGames = try decoder.decode([GameTable].self, from: gamesResponse.data)

     // Filter games to only those played by the given team
     games = allGames.filter { teamGameIDs.contains($0.gameID) }

     // Fetch all teams
     let teamsResponse = try await supabase
         .from("teams")
         .select("*")
         .execute()
     teams = try decoder.decode([TeamTable].self, from: teamsResponse.data)

     // Update filteredGames to reflect the selected team's matches
     filteredGames = games
     print(filteredGames)

     DispatchQueue.main.async {
         self.tableView.reloadData()
         LoadingIndicator.shared.hide()
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

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(filteredGames.count)
        print("eowifrjvdkn")
        return filteredGames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamMatchTableViewCell", for: indexPath) as! TeamMatchTableViewCell
        
        cell.selectionStyle = .none
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

}

extension ViewTeamDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == TeamCoachCollectionView {
            return teamCoaches.count
        } else {
            return teamPlayers.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == TeamCoachCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoachCollectionViewCell", for: indexPath) as! CoachCollectionViewCell
            
            let coach = teamCoaches[indexPath.item]
            cell.configure(with: coach)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCollectionViewCell", for: indexPath) as! PlayerCollectionViewCell
            let player = teamPlayers[indexPath.item]
            cell.configure(with: player)
            return cell
        }
    }
}
