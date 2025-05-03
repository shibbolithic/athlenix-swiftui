import UIKit

class ScoreApprovalViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!

    private var pendingGames: [PendingGameTable] = []
    private var teamsDictionary: [UUID: TeamTable] = [:]  // Cache for team details
       
       override func viewDidLoad() {
           super.viewDidLoad()
           LoadingIndicator.shared.show(in: view)
           tableView.delegate = self
           tableView.dataSource = self
           fetchPendingApprovals()
       }
       
    private func fetchPendingApprovals() {
        Task {
            guard let userID = await SessionManager.shared.getSessionUser() else {
                print("User ID is nil")
                LoadingIndicator.shared.hide()
                return
            }
            
            do {
                let response = try await supabase
                    .from("PendingGame")
                    .select("*")
                    .or("team1coachID.eq.\(userID),team2coachID.eq.\(userID)")
                    .eq("status", value: "pending")
                    .execute()
                
                let decoder = JSONDecoder()
                let games = try decoder.decode([PendingGameTable].self, from: response.data)
                
                print("Fetched Pending Approvals:")
                print(games)
                
                // Fetch teams before updating UI
                await fetchTeamDetails(for: games)
                
                Task { @MainActor in
                    self.pendingGames = games
                    self.tableView.reloadData()
                    LoadingIndicator.shared.hide()
                }
            } catch {
                print("Failed to fetch pending games: \(error)")
                LoadingIndicator.shared.hide()
            }
        }
    }

       
       private func fetchTeamDetails(for games: [PendingGameTable]) async {
           let teamIDs = Set(games.flatMap { [$0.team1ID, $0.team2ID] })  // Unique team IDs
           
           do {
               let response = try await supabase
                   .from("teams")
                   .select("*")
                   .in("teamID", values: teamIDs.map { $0.uuidString })
                   .execute()
               
               let decoder = JSONDecoder()
               let teams = try decoder.decode([TeamTable].self, from: response.data)
               
               Task { @MainActor in
                   self.teamsDictionary = Dictionary(uniqueKeysWithValues: teams.map { ($0.teamID, $0) })
                   self.tableView.reloadData()
                   LoadingIndicator.shared.hide()
               }
           } catch {
               print("Failed to fetch teams: \(error.localizedDescription)")
               LoadingIndicator.shared.hide()
           }
       }

   }

   extension ScoreApprovalViewController: UITableViewDelegate, UITableViewDataSource {
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return pendingGames.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreApprovalCell", for: indexPath) as! ScoreApprovalCell
           
           let game = pendingGames[indexPath.row]
           
           let team1 = teamsDictionary[game.team1ID]
           let team2 = teamsDictionary[game.team2ID]
           
           cell.configure(with: game, team1: team1, team2: team2)
           
           return cell
       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let selectedGame = pendingGames[indexPath.row]
           
           let statsVC = storyboard?.instantiateViewController(withIdentifier: "AS") as? AS
           statsVC!.selectedGame = selectedGame

           
           // Print debugging information
           print("Navigating to StatsViewController with selected game: \(selectedGame)")
           navigationController?.pushViewController(statsVC!, animated: true)
       }
   }


class ScoreApprovalCell: UITableViewCell {
    
    @IBOutlet weak var team1Logo: UIImageView!
    @IBOutlet weak var team1Score: UILabel!
    @IBOutlet weak var team1Name: UILabel!
    
    @IBOutlet weak var team2Logo: UIImageView!
    @IBOutlet weak var team2Score: UILabel!
    @IBOutlet weak var team2Name: UILabel!

    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var approvalStatusButton: UIButton!
    
    func configure(with game: PendingGameTable, team1: TeamTable?, team2: TeamTable?) {
           team1Score.text = "\(game.team1finalScore)"
           team2Score.text = "\(game.team2finalScore)"
           
           team1Name.text = team1?.teamName ?? "Unknown Team"
           team2Name.text = team2?.teamName ?? "Unknown Team"
        
            team1Logo.image = UIImage(named: (team1?.teamLogo!)!)
            team2Logo.image = UIImage(named: (team2?.teamLogo!)!)
            
        if let imageName = team1?.teamLogo,
           let localImage = UIImage(named: imageName) {
            team1Logo.image = localImage
        } else if let imageUrlString = team1?.teamLogo,
                  let imageUrl = URL(string: imageUrlString) {
            team1Logo.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
        }
        if let imageName = team2?.teamLogo,
           let localImage = UIImage(named: imageName) {
            team2Logo.image = localImage
        } else if let imageUrlString = team2?.teamLogo,
                  let imageUrl = URL(string: imageUrlString) {
            team2Logo.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
        }
        
       }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        let cardStacks = [contentStack]

        for stack in cardStacks {
            stack?.layer.cornerRadius = 12
            stack?.layer.masksToBounds = false
            stack?.layer.shadowColor = UIColor.black.cgColor
            stack?.layer.shadowOpacity = 0.1
            stack?.layer.shadowOffset = CGSize(width: 0, height: 4)
            stack?.layer.shadowRadius = 6
            stack?.backgroundColor = UIColor.systemBackground
        }
        
        team1Logo.layer.cornerRadius = team1Logo.frame.width / 2
        team1Logo.clipsToBounds = true
        
        team2Logo.layer.cornerRadius = team2Logo.frame.width / 2
        team2Logo.clipsToBounds = true
    }

    
//    func updateUI() {
//        team1Logo.layer.cornerRadius = team1Logo.frame.size.width/2
//        team2Logo.layer.cornerRadius = team2Logo.frame.size.width/2
//
//    }
       
       private func loadImage(from url: URL, into imageView: UIImageView) {
           Task {
               do {
                   let (data, _) = try await URLSession.shared.data(from: url)
                   Task { @MainActor in
                       imageView.image = UIImage(data: data)
                       LoadingIndicator.shared.hide()
                   }
               } catch {
                   print("Failed to load image: \(error.localizedDescription)")
                   LoadingIndicator.shared.hide()
               }
           }
       }
}
