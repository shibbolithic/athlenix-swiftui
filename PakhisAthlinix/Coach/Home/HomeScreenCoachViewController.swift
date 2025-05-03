//
//  HomeScreenViewController.swift
//  PakhisAthlinix
//
//  Created by admin65 on 14/12/24.
//
import UIKit
import SDWebImage


class HomeScreenCoachViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Mark: Outlets
    @IBOutlet weak var TeamCoachCollectionView: UICollectionView!
    @IBOutlet weak var BestMatchCollectionView: UICollectionView!
    @IBOutlet weak var CreationCollectionView: UICollectionView!
    @IBOutlet weak var StatsCardLeft: UIView!
    @IBOutlet weak var StatsCardRight: UIView!
    @IBOutlet weak var CustomHeaderCard: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var matchesWonLabel: UILabel!
    @IBOutlet weak var matchesLostLabel: UILabel!
    
    @IBOutlet weak var pinnedMatchesView: UIView!
    
    //@IBOutlet weak var cellView: UIView!
    //@IBOutlet weak var statusLabel: UILabel!
    
    
    // MARK: - Variables
    
    var users101: [Usertable] = []
    var teams11: [TeamTable] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingIndicator.shared.show(in: view)
        Task {
            if let sessionUserID = await SessionManager.shared.getSessionUser() {
                await setupHeader(forUserID: sessionUserID)
                fetchTeamsForUserSupabase(userID: sessionUserID)
            } else {
                print("Warning: No session user available when viewDidLoad, header might not load.")
            }
            //await fetchCoachGameLogs()
            await calculateWinPercentage()
        }
        
        reloadInputViews()
        setupView()
        setupCollectionViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            if let sessionUserID = await SessionManager.shared.getSessionUser() {
                await setupHeader(forUserID: sessionUserID)
                fetchTeamsForUserSupabase(userID: sessionUserID)
                LoadingIndicator.shared.hide()
            } else {
                print("Warning: No session user available when viewWillAppear, header might not load.")
                LoadingIndicator.shared.hide()
            }
            
            // await fetchCoachGameLogs() // Uncomment if needed
            await calculateWinPercentage()
            LoadingIndicator.shared.hide()
        }
        
        reloadInputViews()
        setupView()
        setupCollectionViews()
    }

    
    // MARK: - View Setup
    
    private func setupView() {
        RoundedCard()
        //setupMatchesPlayedVsPointsScoredGraph() // Commented out in original code
    }
    
    private func RoundedCard() {
        styleStatCard(StatsCardLeft)
        styleStatCard(StatsCardRight)
        //styleStatCard(cellView)
    }
    
    private func styleStatCard(_ cardView: UIView) {
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.clipsToBounds = false
    }

    
    
    @IBAction func seeAllButtonTapped(_ sender: UIButton) {
        navigateToMatchHistory()
    }
    
    private func navigateToMatchHistory() {
        //            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //            guard let matchHistoryVC = storyboard.instantiateViewController(withIdentifier: "MatchHistroyNavViewController") as? MatchHistroyNavViewController else {
        //                print("MatchHistoryViewController not found!")
        //                return
        //            }
        //            self.navigationController?.pushViewController(matchHistoryVC, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let matchHistoryVC = storyboard.instantiateViewController(withIdentifier: "MatchHistroyNavViewController") as? MatchHistroyNavViewController {
            // Present the AddTeamViewController
            matchHistoryVC.modalPresentationStyle = .fullScreen // or .overFullScreen if you want a different style
            self.present(matchHistoryVC, animated: true, completion: nil)
            LoadingIndicator.shared.hide()
        } else {
            print("Could not instantiate AddPostViewController")
            LoadingIndicator.shared.hide()
        }
    }
    //    private func navigateToMatchHistory1() {
    //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //
    //        if let matchHistoryVC = storyboard.instantiateViewController(withIdentifier: "MatchHistroyViewController") as? MatchHistroyViewController {
    //            self.navigationController?.pushViewController(matchHistoryVC, animated: true)
    //        } else {
    //            print("Could not instantiate MatchHistoryViewController")
    //        }
    //    }
    
    
    @IBAction func navigateTogameplay(_ sender: UIButton) {
        performSegue(withIdentifier: "gotogameplay", sender: nil)
    }
    
    
    
    // MARK: - Header Setup
    
    private func setupHeader(forUserID userID: UUID) async {
        do {
            let userResponse = try await supabase.from("User").select("*").eq("userID", value: userID).single().execute()
            let userDecoder = JSONDecoder()
            let fetchedUser = try userDecoder.decode(Usertable.self, from: userResponse.data)
            
            var fetchedAthleteProfile: CoachProfileTable?
            if fetchedUser.role == .coach {
                let athleteResponse = try await supabase.from("CoachProfile").select("*").eq("coachID", value: userID).single().execute()
                let athleteDecoder = JSONDecoder()
                fetchedAthleteProfile = try athleteDecoder.decode(CoachProfileTable.self, from: athleteResponse.data)
            }
            
            guard let athleteProfile = fetchedAthleteProfile else {
                print("No athlete profile found.")
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.configureHeaderUI(with: fetchedUser, CoachProfileTable: athleteProfile)
                LoadingIndicator.shared.hide()
            }
            
        } catch {
            print("Error setting up header data: \(error)")
            LoadingIndicator.shared.hide()
        }
    }

    
    private func configureHeaderUI(with fetchedUser: Usertable, CoachProfileTable: CoachProfileTable) {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        userNameLabel.text = fetchedUser.name
        

        if let imageName = fetchedUser.profilePicture,
           let localImage = UIImage(named: imageName) {
            profileImageView.image = localImage
            LoadingIndicator.shared.hide()
        } else if let imageUrlString = fetchedUser.profilePicture,
                  let imageUrl = URL(string: imageUrlString) {
            profileImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
            LoadingIndicator.shared.hide()
        }


    }


    
    
    
    // MARK: - Collection View Setup
    
    private func setupCollectionViews() {
        setupCollectionViewDelegates(TeamCoachCollectionView, delegate: self, dataSource: self)
        setupCollectionViewDelegates(BestMatchCollectionView, delegate: self, dataSource: self)
        setupCollectionViewDelegates(CreationCollectionView, delegate: self, dataSource: self)
    }
    
    private func setupCollectionViewDelegates(_ collectionView: UICollectionView, delegate: UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout, dataSource: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout) {
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource
    }
    
    
    // MARK: - Fetching Best Match Data for Coach for each Team
    
    func fetchBestMatchForCoach(coachID: UUID) async throws -> [UUID: GameTable] {
        // Step 1: Fetch teams where the coach is a member
        let teamMembershipResponse = try await supabase
            .from("teamMembership")
            .select("teamID")
            .eq("userID", value: coachID.uuidString)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let teamMembershipData = teamMembershipResponse.data
        let teamMemberships = try decoder.decode([[String: UUID]].self, from: teamMembershipData)
        let coachTeamIDs = teamMemberships.compactMap { $0["teamID"] }

        // Step 2: Fetch all game logs for those teams
        let gameLogsResponse = try await supabase
            .from("GameLog")
            .select("*")
            .in("teamID", values: coachTeamIDs)
            .execute()

        let gameLogsData = gameLogsResponse.data
        let gameLogs = try decoder.decode([GameLogtable].self, from: gameLogsData)
        
        // Step 3: Fetch all games for those teams
        let gamesResponse = try await supabase
            .from("GameTable")
            .select("*")
            .in("team1ID", values: coachTeamIDs)
            .or("team2ID.in.\(coachTeamIDs.map { "'\($0.uuidString)'" }.joined(separator: ",")))")
            .execute()

        let gamesData = gamesResponse.data
        let games = try decoder.decode([GameTable].self, from: gamesData)

        // Step 4: Determine the best match for each team
        var bestGamesPerTeam: [UUID: GameTable] = [:]

        for teamID in coachTeamIDs {
            var bestGame: GameTable?
            var maxPoints = 0

            for game in games where game.team1ID == teamID || game.team2ID == teamID {
                let teamLogs = gameLogs.filter { $0.gameID == game.gameID }
                let teamPoints = teamLogs.reduce(0) { $0 + $1.totalPoints }

                if teamPoints > maxPoints {
                    maxPoints = teamPoints
                    bestGame = game
                }
            }

            if let bestGame = bestGame {
                bestGamesPerTeam[teamID] = bestGame
            }
        }

        return bestGamesPerTeam
    }
    
    
    
    func createPost() {
        // Code for creating a post
        //        let createPostVC = AddPostViewController()
        //
        //            // Push CreatePostViewController onto the navigation stack
        //            navigationController?.pushViewController(createPostVC, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name if different
        if let createPostVC = storyboard.instantiateViewController(withIdentifier: "PostCreationNavigationController") as? PostCreationNavigationController {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .push
            transition.subtype = .fromRight  // This makes it slide in from the left
            view.window?.layer.add(transition, forKey: kCATransition)
            // Present the AddTeamViewController
            createPostVC.modalPresentationStyle = .fullScreen // or .overFullScreen if you want a different style
            self.present(createPostVC, animated: true, completion: nil)
        } else {
            print("Could not instantiate AddPostViewController")
        }
        print("Create Post tapped")
        
        
    }
    
    func createTeam() {
        // Code for creating a team
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name if different
        if let addTeamVC = storyboard.instantiateViewController(withIdentifier: "TeamNavigationController") as? TeamNavigationController {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .push
            transition.subtype = .fromRight  // This makes it slide in from the left
            view.window?.layer.add(transition, forKey: kCATransition)
            // Present the AddTeamViewController
            addTeamVC.modalPresentationStyle = .fullScreen // or .overFullScreen if you want a different style
            self.present(addTeamVC, animated: true, completion: nil)
        } else {
            print("Could not instantiate AddTeamViewController")
        }
        print("Create Team tapped")
    }
    
    
    func createGame() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let gameNavController = storyboard.instantiateViewController(withIdentifier: "GameNavigationController") as? UINavigationController {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .push
            transition.subtype = .fromRight  // This makes it slide in from the left
            view.window?.layer.add(transition, forKey: kCATransition)
            gameNavController.modalPresentationStyle = .fullScreen // Presentation style is already set because GameNavigationController is a UINavigationController
            self.present(gameNavController, animated: true)
        } else {
            print("Could not instantiate AddGameViewController")
        }
        print("Create Game tapped")
    }
    
    // MARK: - UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // Default section count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case TeamCoachCollectionView:
            return teams11.count // Updated from users101.count
        case CreationCollectionView:
            return 3 // Static cards for CreationCollectionView
        default:
            return 1 // For BestMatchCollectionView and default
        }
    }
    
    private func bestMatchCollectionViewCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BestMatchCollectionViewCell", for: indexPath) as? BestMatchCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        Task {
            do {
                if let sessionUserID = await SessionManager.shared.getSessionUser() {
                    if let bestMatch = try await fetchBestMatchSupabase(forPlayerID: sessionUserID) {
                        await updateBestMatchViewSupabase(with: bestMatch, cell: cell)
                    }
                } else {
                    print("Error: No session user is set")
                }
            } catch {
                print("Error fetching or updating best match: \(error)")
            }
        }
        return cell
    }
    
    private func updateBestMatchViewSupabase(with game: GameTable, cell: BestMatchCollectionViewCell) async {
        do {
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
            
            let logsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("gameID", value: game.gameID.uuidString)
                .execute()
            
            let gameLogs = try decoder.decode([GameLogtable].self, from: logsResponse.data)
            let team1Logs = gameLogs.filter { $0.teamID == game.team1ID }
            let team2Logs = gameLogs.filter { $0.teamID == game.team2ID }
            
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
                cell.configure(myTeamName: team1.teamName, opponentTeamName: team2.teamName, myTeamFieldGoals: "\(team1Logs.reduce(0) { $0 + $1.points2 })", myTeamThreePointFieldGoals: "\(team1Logs.reduce(0) { $0 + $1.points3 })", myTeamFreeThrows: "\(team1Logs.reduce(0) { $0 + $1.freeThrows })", opponentTeamFieldGoals: "\(team2Logs.reduce(0) { $0 + $1.points2 })", opponentTeamThreePointFieldGoals: "\(team2Logs.reduce(0) { $0 + $1.points3 })", opponentTeamFreeThrows: "\(team2Logs.reduce(0) { $0 + $1.freeThrows })")
                
//                cell.myTeamImageView.image = UIImage(named: team1.teamLogo!) // Ensure these images
//                cell.opponentTeamImageView.image = UIImage(named: team2.teamLogo!)
                
                if let imageName = team1.teamLogo,
                   let localImage = UIImage(named: imageName) {
                    cell.myTeamImageView.image = localImage
                } else if let imageUrlString = team1.teamLogo,
                          let imageUrl = URL(string: imageUrlString) {
                    cell.myTeamImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "team1"))
                }
                
                if let newimageName = team2.teamLogo,
                   let localImage = UIImage(named: newimageName) {
                    cell.opponentTeamImageView.image = localImage
                } else if let imageUrlString = team2.teamLogo,
                          let imageUrl = URL(string: imageUrlString) {
                    cell.opponentTeamImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "team1"))
                }
                
            }
        } catch {
            print("Error updating best match view: \(error)")
        }
    }
    
    func fetchBestMatchSupabase(forPlayerID playerID: UUID) async throws -> GameTable? {
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
        
        let gamesResponse = try await supabase
            .from("Game")
            .select("*")
            .in("gameID", values: playerGameIDs)
            .execute()
        
        let gamesData = gamesResponse.data
        let playerGames = try decoder.decode([GameTable].self, from: gamesData)
        
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



    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case TeamCoachCollectionView:
            return teamCoachCollectionViewCell(collectionView, cellForItemAt: indexPath) // Updated from athleteCollectionViewCell
        case BestMatchCollectionView:
            return bestMatchCollectionViewCell(collectionView, cellForItemAt: indexPath)
        case CreationCollectionView:
            return creationCollectionViewCell(collectionView, cellForItemAt: indexPath)
        default:
            return UICollectionViewCell() // Default cell
        }
    }

    
    // Athletes Collection View Cell Configuration
    
    private func updateBestMatchViewSupabase(for bestGames: [UUID: GameTable], cells: [BestMatchCollectionViewCell]) async {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            for (index, (teamID, game)) in bestGames.enumerated() {
                guard index < cells.count else { break } // Ensure we don't access out-of-bounds cells
                
                let cell = cells[index]

                // Fetch teams involved in the game
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

                let team1 = try decoder.decode(TeamTable.self, from: team1Response.data)
                let team2 = try decoder.decode(TeamTable.self, from: team2Response.data)

                // Fetch game logs to calculate points
                let logsResponse = try await supabase
                    .from("GameLog")
                    .select("*")
                    .eq("gameID", value: game.gameID.uuidString)
                    .execute()
                
                let gameLogs = try decoder.decode([GameLogtable].self, from: logsResponse.data)
                let team1Logs = gameLogs.filter { $0.teamID == game.team1ID }
                let team2Logs = gameLogs.filter { $0.teamID == game.team2ID }

                // Update UI on the main thread
                DispatchQueue.main.async { [weak self] in
                    guard self != nil else { return }
                    
                    cell.configure(
                        myTeamName: team1.teamName,
                        opponentTeamName: team2.teamName,
                        myTeamFieldGoals: "\(team1Logs.reduce(0) { $0 + $1.points2 })",
                        myTeamThreePointFieldGoals: "\(team1Logs.reduce(0) { $0 + $1.points3 })",
                        myTeamFreeThrows: "\(team1Logs.reduce(0) { $0 + $1.freeThrows })",
                        opponentTeamFieldGoals: "\(team2Logs.reduce(0) { $0 + $1.points2 })",
                        opponentTeamThreePointFieldGoals: "\(team2Logs.reduce(0) { $0 + $1.points3 })",
                        opponentTeamFreeThrows: "\(team2Logs.reduce(0) { $0 + $1.freeThrows })"
                    )
                    
                    if let team1Logo = team1.teamLogo, let team2Logo = team2.teamLogo {
//                        cell.myTeamImageView.image = UIImage(named: team1Logo)
//                        cell.opponentTeamImageView.image = UIImage(named: team2Logo)
                        
                        if let imageName = team1.teamLogo,
                           let localImage = UIImage(named: imageName) {
                            cell.myTeamImageView.image = localImage
                        } else if let imageUrlString = team1.teamLogo,
                                  let imageUrl = URL(string: imageUrlString) {
                            cell.myTeamImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "team1"))
                        }
                        
                        if let newimageName = team2.teamLogo,
                           let localImage = UIImage(named: newimageName) {
                            cell.opponentTeamImageView.image = localImage
                        } else if let imageUrlString = team2.teamLogo,
                                  let imageUrl = URL(string: imageUrlString) {
                            cell.opponentTeamImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "team1"))
                        }
                        
                    }
                }
            }
        } catch {
            print("Error updating best match view: \(error)")
        }
    }

    
    
    // Creation Collection View Cell Configuration
    private func creationCollectionViewCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreationCollectionViewCell", for: indexPath) as? CreationCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        switch indexPath.item {
        case 0:
            cell.titleLabel.text = "Add Post"
            cell.iconImageView.image = UIImage(named: "AddPost")
        case 1:
            cell.titleLabel.text = "Add Game"
            cell.iconImageView.image = UIImage(named: "AddMatchIcon")
        case 2:
            cell.titleLabel.text = "Add Team"
            cell.iconImageView.image = UIImage(named: "AddTeamIcon")
        default:
            break
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case TeamCoachCollectionView:
            teamCoachCollectionViewDidSelectItem(at: indexPath) // Updated from athleteCollectionViewDidSelectItem
        case CreationCollectionView:
            creationCollectionViewDidSelectItem(at: indexPath)
        default:
            break // Handle other collection views if needed
        }
    }
    
    func teamCoachCollectionViewCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeamCoachCollectionViewCell", for: indexPath) as? TeamCoachCollectionViewCell else {
            return UICollectionViewCell()
        }

        // Ensure teams is an array of `TeamTableCoach`
        let teamTable: TeamTable = teams11[indexPath.item]

        cell.configure1(with: teamTable)

        // Calculate win/loss ratio safely
//        let totalGames = teamTable.teamWins + teamTable.teamLosses
//        let winRatio = totalGames > 0 ? Double(teamTable.teamWins) / Double(totalGames) : 0.0
//        cell.teamWinLooseRatio.text = String(format: "Win Ratio: %.2f", winRatio)

        return cell
    }
    
    func teamCoachCollectionViewDidSelectItem(at indexPath: IndexPath) {
        let selectedTeam = teams11[indexPath.item]
        print(selectedTeam.teamName)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let teamDetailsVC = storyboard.instantiateViewController(withIdentifier: "ViewTeamDetailViewController") as? ViewTeamDetailViewController {
                
                teamDetailsVC.selectedTeam = selectedTeam // ✅ Pass entire team object
                        
                        if let navigationController = self.navigationController {
                            navigationController.pushViewController(teamDetailsVC, animated: true)
                        } else {
                            print("NavigationController not found!")
                        }
                    } else {
                        print("Failed to instantiate ViewTeamDetailViewController from storyboard!")
            }
    }
    
    // Creation Collection View Item Selection
    private func creationCollectionViewDidSelectItem(at indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            createPost()
            print("Create Post tapped")
        case 1:
            createGame()
            print("Create Game tapped")
        case 2:
            createTeam()
            print("Create Team tapped")
        default:
            break
        }
    }
    
    
    // UICollectionViewDelegateFlowLayout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        if collectionView == TeamCoachCollectionView { // Updated from athletesCollectionView
            if indexPath.item == 0 {
                return CGSize(width: screenWidth / 2, height: 150)
            } else {
                return CGSize(width: 128, height: 150)
            }
        } else if collectionView == BestMatchCollectionView {
            let width = screenWidth - 32 // Account for left and right padding
            return CGSize(width: width, height: 220)
        } else if collectionView == CreationCollectionView {
            return CGSize(width: 100, height: 129)
        } else {
            return CGSize(width: 100, height: 100) // Default size
        }
    }
    
    //MARK: FETCH TEAMS
    func fetchTeamsForUserSupabase(userID: UUID?) {
        guard let userID = userID else {
            print("User ID is nil")
            return
        }
        
        Task {
            do {
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
                
                let teams2 = try decoder.decode([TeamTable].self, from: teamsResponse.data)
                
                print("Teams for user: \(teams2)")
                
            
                // Handle the fetched teams (update UI, etc.)
                teams11 = teams2
                TeamCoachCollectionView.reloadData()
            } catch {
                print("Error fetching teams: \(error)")
            }
        }
    }

    

    
    // Update your fetchPlayerGameLogs function to use this new drawing method with proper DispatchQueue syntax
    private func fetchCoachGameLogs() async {
        guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
            print("Error: No session user is set")
            return
        }

        do {
            // Step 1: Fetch all teams where the logged-in user is a coach
            let teamsResponse = try await supabase
                .from("teamMembership")
                .select("teamID")
                .eq("userID", value: sessionUserID.uuidString)
                .eq("roleInTeam", value: Role.coach.rawValue)
                .execute()
            
            let teamIDs = try JSONDecoder().decode([TeamMembershipTable].self, from: teamsResponse.data).map { $0.teamID }
            
            guard !teamIDs.isEmpty else {
                print("Coach is not part of any teams.")
                return
            }

            // Step 2: Fetch all game logs for these teams
            let gameLogsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .in("teamID", values: teamIDs.map { $0.uuidString })
                .execute()
            
            let gameLogs = try JSONDecoder().decode([GameLogtable].self, from: gameLogsResponse.data)

            guard !gameLogs.isEmpty else {
                print("No game logs found for coach's teams.")
                return
            }

            // Step 3: Fetch game results to determine wins/losses
            let gameIDs = gameLogs.map { $0.gameID }
            let gamesResponse = try await supabase
                .from("Game")
                .select("*")
                .in("gameID", values: gameIDs.map { $0.uuidString })
                .execute()
            
            let games = try JSONDecoder().decode([GameTable].self, from: gamesResponse.data)

            // Calculate Wins & Losses
            var matchesWon = 0
            var matchesLost = 0

            for game in games {
                if teamIDs.contains(game.team1ID) {
                    if game.team1finalScore > game.team2finalScore {
                        matchesWon += 1
                    } else {
                        matchesLost += 1
                    }
                } else if teamIDs.contains(game.team2ID) {
                    if game.team2finalScore > game.team1finalScore {
                        matchesWon += 1
                    } else {
                        matchesLost += 1
                    }
                }
            }

            // Step 4: Update UI
            DispatchQueue.main.async {
                self.matchesWonLabel.text = "\(matchesWon)"
                self.matchesLostLabel.text = "\(matchesLost)"
            }

        } catch {
            print("Error fetching coach's game logs: \(error)")
        }
    }
    
    func calculateWinPercentage() async {
        guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
            print("Error: No session user is set")
            return
        }
        
        do {
            // Fetch teams the user is a part of
            let teamMembershipsResponse = try await supabase
                .from("teamMembership")
                .select("*")
                .eq("userID", value: sessionUserID.uuidString)
                .execute()
            
            let teamMemberships = try JSONDecoder().decode([TeamMembershipTable].self, from: teamMembershipsResponse.data)
            let userTeamIDs = teamMemberships.map { $0.teamID }
            
            guard !userTeamIDs.isEmpty else {
                print("User is not part of any teams.")
                return
            }
            
            // Fetch games where the user's teams played
            let gamesResponse = try await supabase
                .from("Game")
                .select("*")
                .or("team1ID.in.(\(userTeamIDs.map { $0.uuidString }.joined(separator: ","))) , team2ID.in.(\(userTeamIDs.map { $0.uuidString }.joined(separator: ",")))")
                .execute()
            
            let games = try JSONDecoder().decode([GameTable].self, from: gamesResponse.data)
            
            guard !games.isEmpty else {
                print("No games found for user's teams.")
                return
            }
            
            var totalGames = 0
            var gamesWon = 0
            
            for game in games {
                if userTeamIDs.contains(game.team1ID) {
                    totalGames += 1
                    if game.team1finalScore > game.team2finalScore {
                        gamesWon += 1
                    }
                } else if userTeamIDs.contains(game.team2ID) {
                    totalGames += 1
                    if game.team2finalScore > game.team1finalScore {
                        gamesWon += 1
                    }
                }
            }
            
            let winPercentage = totalGames > 0 ? (Double(gamesWon) / Double(totalGames)) * 100 : 0
            
            DispatchQueue.main.async {
                self.matchesWonLabel.text = "\(gamesWon)"
                self.matchesLostLabel.text = "\(winPercentage)"
            }

            
            print("Total Games Played: \(totalGames)")
            print("Games Won: \(gamesWon)")
            print("Win Percentage: \(winPercentage)%")
            
        } catch {
            print("Error fetching data: \(error)")
        }
    }


}


