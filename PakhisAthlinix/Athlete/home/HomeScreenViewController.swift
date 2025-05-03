//
//  HomeScreenViewController.swift
//  PakhisAthlinix
//
//  Created by admin65 on 14/12/24.
//
import UIKit
import SDWebImage


class HomeScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ppgLabel: UILabel!
    @IBOutlet weak var bpgLabel: UILabel!
    @IBOutlet weak var astLabel: UILabel!
    
    @IBOutlet weak var pointsScoredImageView: UIView!
    @IBOutlet weak var seeAnalyticsButton: UILabel!
    @IBOutlet weak var pointsScoredBarGraphView: UIView!
    
    @IBOutlet weak var pinnedMatchesView: UIView!
    @IBOutlet weak var pinnedMatchesCardView: UIView!
    @IBOutlet weak var team2ImageView: UIImageView!
    @IBOutlet weak var team2Name: UILabel!
    @IBOutlet weak var team1ImageView: UIImageView!
    @IBOutlet weak var team1Name: UILabel!
    @IBOutlet weak var team12ptfgs: UILabel!
    @IBOutlet weak var team13ptfgs: UILabel!
    @IBOutlet weak var team1FreeThrows: UILabel!
    @IBOutlet weak var team22ptfgs: UILabel!
    @IBOutlet weak var team23ptfgs: UILabel!
    @IBOutlet weak var team2FreeThrows: UILabel!
    
    
    @IBOutlet weak var highlightCardView: UIView!
    @IBOutlet weak var highlightImageView: UIImageView!
    @IBOutlet weak var highlightGameName: UILabel!
    @IBOutlet weak var highlightDate: UILabel!
    
    
    @IBOutlet weak var athletesCollectionView: UICollectionView!
    
    @IBOutlet weak var matchesPlayedvsPointsScoredView: UIView!
    
    //@IBOutlet weak var teamgraphview: UIView!
    
    @IBOutlet weak var teamgraphview: TeamPerformanceBarChartViewClass!
    
    //MARK: Variables
    var users101: [Usertable] = []
    
    
    
    
    
    //let loggedInUserID = "2"
    
    //@IBOutlet weak var teamPerformanceBarChartView: TeamPerformanceBarGamePlayChartView!
    
    
    // MARK: viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.layer.cornerRadius = 16
        // Do any additional setup after loading the view.
        
        //setupMatchesPlayedVsPointsScoredGraph()
        
        let viewsToStyle = [pointsScoredImageView, pinnedMatchesView, matchesPlayedvsPointsScoredView]
        
        for view in viewsToStyle {
            view?.layer.borderColor = UIColor.lightGray.cgColor
            view?.layer.borderWidth = 1.0 // Thickness of the border
            view?.layer.cornerRadius = 8 // Optional: Rounded corners
            view?.clipsToBounds = true
        }
        
        // MARK: NEW
        // Fetch the best match data and update UI
        
        Task {
            if let sessionUserID = await SessionManager.shared.getSessionUser() {
                if let bestMatch1 = try await fetchBestMatchSupabase(forPlayerID: sessionUserID) {
                    await updateBestMatchViewSupabase(with: bestMatch1)
                }
            } else {
                print("Error: No session user is set")
            }
        }
        
        
        // MARK: FLOATING BUTTON
                let floatingButton = UIButton(type: .system)
                floatingButton.frame = CGRect(x: view.frame.width - 30 - 70, y: view.frame.height - 120 - 70, width: 70, height: 70)
                floatingButton.layer.cornerRadius = 35 // Half of width/height to make it circular
                floatingButton.backgroundColor = UIColor(red: 253/255, green: 100/255, blue: 48/255, alpha: 1.0) // FD6430 color
                floatingButton.setTitle("+", for: .normal)
                floatingButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
                floatingButton.setTitleColor(.white, for: .normal)
        
                // Add shadow for better visibility
                floatingButton.layer.shadowColor = UIColor.black.cgColor
                floatingButton.layer.shadowOpacity = 0.3
                floatingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
                floatingButton.layer.shadowRadius = 4
        
                // Add target action for the button
                floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        
       //  Add the button to the view
                view.addSubview(floatingButton)
        
        setupPointsScoredSection()
        // setupPinnedMatches()
        Task{
            if let sessionUserID = await SessionManager.shared.getSessionUser() {
                await setupHighlightSection(forUserID: sessionUserID)
                await setupHeader(forUserID: sessionUserID)
                await setupPointsScoredGraph(for: sessionUserID)
            } else {
                print("Error: No session user is set")
            }
        }
        
        setupAthletesCollectionView()
        fetchAthletesData()
        //setupMatchesPlayedvsPointsScoredSection()
        //setupMatchesPlayedvsPointsScoredSection()
    }
    
    
    // MARK: - Setup Header
    private func setupHeader(forUserID userID: UUID) async {
        do {
            // Fetch User data
            let userResponse = try await supabase.from("User").select("*").eq("userID", value: userID).single().execute()
            let userDecoder = JSONDecoder()
            let fetchedUser = try userDecoder.decode(Usertable.self, from: userResponse.data)
            
            // Fetch Athlete Profile data (if applicable)
            var fetchedAthleteProfile: AthleteProfileTable?
            if fetchedUser.role == .athlete {
                let athleteResponse = try await supabase.from("AthleteProfile").select("*").eq("athleteID", value: userID).single().execute()
                let athleteDecoder = JSONDecoder()
                fetchedAthleteProfile = try athleteDecoder.decode(AthleteProfileTable.self, from: athleteResponse.data)
            }
            
            // Ensure the user is an athlete and has a profile
            guard let athleteProfile = fetchedAthleteProfile else {
                print("No athlete profile found.")
                return
            }
            
            // Configure the header view
            DispatchQueue.main.async {
                self.headerView.layer.cornerRadius = 16
                self.headerView.backgroundColor = UIColor(hex: "#FD6430")
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
                self.profileImageView.clipsToBounds = true
                
                // Set data dynamically from `fetchedUser` and `athleteProfile`
                self.userNameLabel.text = fetchedUser.name
                self.ppgLabel.text = String(format: "%.1f", athleteProfile.averagePointsPerGame)
                self.bpgLabel.text = String(format: "%.1f", athleteProfile.averageReboundsPerGame)
                self.astLabel.text = String(format: "%.1f", athleteProfile.averageAssistsPerGame)
                
                // Set profile picture (ensure the image exists in your assets)
                if let profilePicture = fetchedUser.profilePicture, let profileImage = UIImage(named: profilePicture) {
                    self.profileImageView.image = profileImage
                } else {
                    self.profileImageView.image = UIImage(named: "placeholder") // Fallback image
                }
            }
        } catch {
            print("Error setting up header data: \(error)")
        }
    }
    
    
    // MARK: - Points Scored Section
    private func setupPointsScoredSection() {
        pointsScoredBarGraphView.layer.cornerRadius = 8
    }
    
    
    @IBAction func seeAllButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name
        guard let matchHistoryVC = storyboard.instantiateViewController(withIdentifier: "MatchHistoryViewController") as? MatchHistoryViewController else {
            print("MatchHistoryViewController not found!")
            return
        }
        
        // Push the MatchHistoryViewController onto the navigation stack
        self.navigationController?.pushViewController(matchHistoryVC, animated: true)
    }
    
    
    /// MARK: - Pinned Matches
    // MARK: - Fetch Best Match from Supabase
    func fetchBestMatchSupabase(forPlayerID playerID: UUID) async throws -> GameTable? {
        // Step 1: Fetch game logs for the player
        let gameLogsResponse = try await supabase
            .from("GameLog")
            .select("*")
            .eq("playerID", value: playerID.uuidString)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let gameLogsData = gameLogsResponse.data
        
        let playerGameLogs = try decoder.decode([GameLogtable].self, from: gameLogsData)
        let playerGameIDs = playerGameLogs.map { $0.gameID }
        
        // Step 2: Fetch games for the extracted game IDs
        let gamesResponse = try await supabase
            .from("Game")
            .select("*")
            .in("gameID", values: playerGameIDs)
            .execute()
        
        let gamesData = gamesResponse.data
        let playerGames = try decoder.decode([GameTable].self, from: gamesData)
        
        // Step 3: Find the best game
        var bestGame: GameTable?
        var maxPoints = 0
        
        for game in playerGames {
            let teamLogs = playerGameLogs.filter { $0.gameID == game.gameID }
            let teamPoints = teamLogs.reduce(0) { $0 + $1.totalPoints }
            
            if teamPoints > maxPoints {
                maxPoints = teamPoints
                bestGame = game
            }
        }
        
        return bestGame
    }
    
    // MARK: - Update Best Match View with Supabase Data
    func updateBestMatchViewSupabase(with game: GameTable) async {
        do {
            // Fetch team details
            let team1Response = try await supabase
                .from("teams")
                .select("*")
                .eq("teamID", value: game.team1ID.uuidString)
                .single()
                .execute()
            
            let team2Response = try await supabase
                .from("teams")
                .select("*")
                .eq("teamID", value: game.team2ID.uuidString)
                .single()
                .execute()
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let team1 = try decoder.decode(TeamTable.self, from: team1Response.data)
            let team2 = try decoder.decode(TeamTable.self, from: team2Response.data)
            
            // Fetch game logs for the match
            let logsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("gameID", value: game.gameID.uuidString)
                .execute()
            
            let gameLogs = try decoder.decode([GameLogtable].self, from: logsResponse.data)
            let team1Logs = gameLogs.filter { $0.teamID == game.team1ID }
            let team2Logs = gameLogs.filter { $0.teamID == game.team2ID }
            
            // Update UI
            DispatchQueue.main.async {
                self.team1Name.text = team1.teamName
                self.team2Name.text = team2.teamName
                self.team1ImageView.image = UIImage(named: team1.teamLogo ?? "placeholder")
                self.team2ImageView.image = UIImage(named: team2.teamLogo ?? "placeholder")
                
                self.team12ptfgs.text = "\(team1Logs.reduce(0) { $0 + $1.points2 })"
                self.team13ptfgs.text = "\(team1Logs.reduce(0) { $0 + $1.points3 })"
                self.team1FreeThrows.text = "\(team1Logs.reduce(0) { $0 + $1.freeThrows })"
                
                self.team22ptfgs.text = "\(team2Logs.reduce(0) { $0 + $1.points2 })"
                self.team23ptfgs.text = "\(team2Logs.reduce(0) { $0 + $1.points3 })"
                self.team2FreeThrows.text = "\(team2Logs.reduce(0) { $0 + $1.freeThrows })"
            }
        } catch {
            print("Error updating best match view: \(error)")
        }
    }
    
    
    // MARK: - Highlight Section
    // Step 2: Filter posts to show only the logged-in user's posts
    private func setupHighlightSection(forUserID userID: UUID) async {
        do {
            // Fetch posts created by the logged-in user
            let postsResponse = try await supabase.from("posts").select("*").eq("createdBy", value: userID).execute()
            let postsDecoder = JSONDecoder()
            let userPosts = try postsDecoder.decode([PostsTable].self, from: postsResponse.data)
            print(userPosts)
            
            // Ensure there's at least one post to display
            guard let post = userPosts.last else {
                print("No posts available to display highlights.")
                return
            }
            
            // Configure the highlight card view
            highlightCardView.layer.cornerRadius = 12
            highlightCardView.layer.shadowColor = UIColor.black.cgColor
            highlightCardView.layer.shadowOpacity = 0.1
            highlightCardView.layer.shadowOffset = CGSize(width: 0, height: 4)
            highlightCardView.layer.shadowRadius = 8
            
            // ✅ Load the highlight image from URL using SDWebImage
            if let imageUrl = URL(string: post.image3) {
                highlightImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
            } else {
                highlightImageView.image = UIImage(named: "placeholder") // Default placeholder
            }
            highlightImageView.layer.cornerRadius = 12
            highlightImageView.clipsToBounds = true
            
            // Set other UI elements
            highlightGameName.text = post.content
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM '24"
            highlightDate.text = " " // Format date
            
        } catch {
            print("Error fetching user posts: \(error)")
        }
    }
    
    
    
    
    // MARK: - Athletes Collection View
    private func setupAthletesCollectionView() {
        athletesCollectionView.delegate = self
        athletesCollectionView.dataSource = self
    }
    
    private func fetchAthletesData() {
        Task {
            do {
                let response = try await supabase.from("User").select("*").eq("role", value: Role.athlete.rawValue).execute()
                let decoder = JSONDecoder()
                users101 = try decoder.decode([Usertable].self, from: response.data)
                
                // Update local data source
                //user101 = fetchedUsers
                
                // Reload the collection view on the main thread
                DispatchQueue.main.async {
                    self.athletesCollectionView.reloadData()
                }
            } catch {
                print("Error fetching athletes: \(error)")
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users101.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AthletesCell", for: indexPath) as! athletesCollectionViewCell
        let user = users101[indexPath.row]  // Fetch the user at the given index
        
        
        cell.configure(with: user)  // Assuming your cell has a configure method that accepts a `User`
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAthlete = users101[indexPath.row] // Assume athletes array stores athlete data
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ViewUserViewController") as? ViewUserViewController {
            profileVC.selectedUserID = selectedAthlete.userID// Pass the UUID
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    // MARK: GRAPH
    func setupPointsScoredGraph(for userID: UUID) async {
        do {
            // Fetch game logs for the user
            let gameLogResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("playerID", value: userID)
                .execute()
            
            let gameLogDecoder = JSONDecoder()
            let gameLogs = try gameLogDecoder.decode([GameLogtable].self, from: gameLogResponse.data)
            
            // Fetch games associated with the logs
            let gameIDs = gameLogs.map { $0.gameID }
            let gameResponse = try await supabase
                .from("Game")
                .select("*")
                .in("gameID", values: gameIDs)
                .execute()
            
            let gameDecoder = JSONDecoder()
            let games = try gameDecoder.decode([GameTable].self, from: gameResponse.data)
            
            guard !gameLogs.isEmpty else { return }
            
            // Clear previous views
            pointsScoredBarGraphView.subviews.forEach { $0.removeFromSuperview() }
            pointsScoredBarGraphView.clipsToBounds = true
            
            // Graph setup
            let leftPadding: CGFloat = 50 // Padding for grid labels
            let bottomPadding: CGFloat = 30 // Padding for month labels
            let graphHeight: CGFloat = pointsScoredBarGraphView.bounds.height - bottomPadding
            let graphWidth: CGFloat = pointsScoredBarGraphView.bounds.width - leftPadding
            let maxPoints: CGFloat = 150
            let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            
            // Filter logs for the user and group by month
            let calendar = Calendar.current
            var monthlyPoints = [Int](repeating: 0, count: 12)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            for log in gameLogs {
                if let game = games.first(where: { $0.gameID == log.gameID }) {
                    let totalPoints = (log.points2 * 2) + (log.points3 * 3) + log.freeThrows
                    if let gameDate = dateFormatter.date(from: game.dateOfGame) {
                        let month = calendar.component(.month, from: gameDate) - 1
                        monthlyPoints[month] += totalPoints
                    }
                }
            }
            
            // Calculate dynamic bar width and spacing
            let numberOfBars = monthlyPoints.filter { $0 > 0 }.count
            let barWidth = graphWidth / CGFloat(numberOfBars * 2) // Half of the total available space for bars
            let spacing = barWidth // Equal spacing to bar width
            
            // Add grid lines
            let numberOfGridLines = 5
            for i in 0...numberOfGridLines {
                let yPosition = graphHeight - (graphHeight / CGFloat(numberOfGridLines) * CGFloat(i))
                let gridLine = UIView(frame: CGRect(x: leftPadding, y: yPosition, width: graphWidth, height: 1))
                gridLine.backgroundColor = .lightGray.withAlphaComponent(0.3)
                pointsScoredBarGraphView.addSubview(gridLine)
                
                let valueLabel = UILabel(frame: CGRect(x: 0, y: yPosition - 8, width: leftPadding - 10, height: 15))
                valueLabel.text = "\(Int(maxPoints / CGFloat(numberOfGridLines) * CGFloat(i)))"
                valueLabel.font = UIFont.systemFont(ofSize: 10)
                valueLabel.textAlignment = .right
                valueLabel.textColor = .gray
                pointsScoredBarGraphView.addSubview(valueLabel)
            }
            
            // Add bars and month labels
            var xOffset = leftPadding
            for (index, points) in monthlyPoints.enumerated() where points > 0 {
                let barHeight = graphHeight * CGFloat(points) / maxPoints
                let barX = xOffset
                
                let barView = UIView(frame: CGRect(x: barX, y: graphHeight - barHeight, width: barWidth, height: barHeight))
                barView.backgroundColor = .systemOrange
                barView.layer.cornerRadius = 4
                pointsScoredBarGraphView.addSubview(barView)
                
                let monthLabel = UILabel(frame: CGRect(x: barX - 5, y: graphHeight + 5, width: barWidth + 10, height: 15))
                monthLabel.text = months[index]
                monthLabel.font = UIFont.systemFont(ofSize: 10)
                monthLabel.textAlignment = .center
                monthLabel.textColor = .gray
                pointsScoredBarGraphView.addSubview(monthLabel)
                
                xOffset += barWidth + spacing
            }
        } catch {
            print("Error fetching data for points scored graph: \(error)")
        }
    }
    
    
    
    // MARK: additional funcs
    
    //    @IBAction func navigateToHierarchy(_ sender: UIButton) {
    //        performSegue(withIdentifier: "goToNavigation", sender: nil)
    //
    //    }
    
    @IBAction func navigateTogameplay(_ sender: UIButton) {
        performSegue(withIdentifier: "gotogameplay", sender: nil)
        
    }
    
    
        @objc func floatingButtonTapped() {
            // Create an action sheet
            let actionSheet = UIAlertController(title: "Select an Option", message: nil, preferredStyle: .actionSheet)
    
            // Create "Create Post" action
            let createPostAction = UIAlertAction(title: "Create Post", style: .default) { _ in
                // Handle Create Post action
                self.createPost()
            }
    
            // Create "Create Team" action
            let createTeamAction = UIAlertAction(title: "Create Team", style: .default) { _ in
                // Handle Create Team action
                self.createTeam()
            }
    
            // Create "Create Game" action
            let createGameAction = UIAlertAction(title: "Create Game", style: .default) { _ in
                // Handle Create Game action
                self.createGame()
            }

 //        Add actions to the action sheet
        actionSheet.addAction(createPostAction)
        actionSheet.addAction(createTeamAction)
        actionSheet.addAction(createGameAction)
        
//         Add a cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        // Present the action sheet
        present(actionSheet, animated: true, completion: nil)
    }

    // MARK: Create
    func createPost() {
        // Code for creating a post
//        let createPostVC = AddPostViewController()
//            
//            // Push CreatePostViewController onto the navigation stack
//            navigationController?.pushViewController(createPostVC, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name if different
           if let createPostVC = storyboard.instantiateViewController(withIdentifier: "AddPostViewController") as? AddPostViewController {
               // Present the AddTeamViewController
               createPostVC.modalPresentationStyle = .fullScreen // or .overFullScreen if you want a different style
               self.present(createPostVC, animated: true, completion: nil)
           } else {
               print("Could not instantiate AddPostViewController")
           }
        print("Create Post tapped")
        
        
        }
        // Add this helper function if needed to refresh the home feed
        private func refreshHomeFeed() {
            print("Home feed refreshed with the new post")
            // Add logic to update the home feed with the new post
        }

    func createTeam() {
        // Code for creating a team
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name if different
           if let addTeamVC = storyboard.instantiateViewController(withIdentifier: "TeamNavigationController") as? TeamNavigationController {
               // Present the AddTeamViewController
               addTeamVC.modalPresentationStyle = .fullScreen // or .overFullScreen if you want a different style
               self.present(addTeamVC, animated: true, completion: nil)
           } else {
               print("Could not instantiate AddTeamViewController")
           }
        print("Create Team tapped")
    }

    func createGame() {
        // Code for creating a game
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name if different
           if let addGameVC = storyboard.instantiateViewController(withIdentifier: "GameNavigationController") as? GameNavigationController {
               // Present the AddTeamViewController
               addGameVC.modalPresentationStyle = .fullScreen // or .overFullScreen if you want a different style
               self.present(addGameVC, animated: true, completion: nil)
           } else {
               print("Could not instantiate AddGameViewController")
           }
        print("Create Game tapped")
    }
    
    // MARK: LOL
    
//    extension UIColor {
//        convenience init(hex: String) {
//            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
//
//            var rgb: UInt64 = 0
//            Scanner(string: hexSanitized).scanHexInt64(&rgb)
//
//            let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//            let blue = CGFloat(rgb & 0x0000FF) / 255.0
//
//            self.init(red: red, green: green, blue: blue, alpha: 1.0)
//        }
//    }

    
}
