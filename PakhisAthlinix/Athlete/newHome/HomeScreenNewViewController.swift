//
//  HomeScreenViewController.swift
//  PakhisAthlinix
//
//  Created by admin65 on 14/12/24.
//
import UIKit
import SDWebImage
import SwiftUI


class HomeScreenNewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Mark: Outlets
    @IBOutlet weak var BestMatchCollectionView: UICollectionView!
    @IBOutlet weak var CreationCollectionView: UICollectionView!
    @IBOutlet weak var StatsCardLeft: UIView!
    @IBOutlet weak var StatsCardRight: UIView!
    @IBOutlet weak var CustomHeaderCard: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ppgLabel: UILabel!
    @IBOutlet weak var bpgLabel: UILabel!
    @IBOutlet weak var pointsScoredImageView: UIView!
    @IBOutlet weak var seeAnalyticsButton: UIButton!
    @IBOutlet weak var pointsScoredBarGraphView: UIView!
    @IBOutlet weak var pinnedMatchesView: UIView!
    @IBOutlet weak var pinnedMatchesCardView: UIView!
    @IBOutlet weak var athletesCollectionView: UICollectionView!
    @IBOutlet weak var matchesPlayedvsPointsScoredView: UIView!
    @IBOutlet weak var teamgraphview: TeamPerformanceBarChartViewClass!
    
    //@IBOutlet weak var statusLabel: UILabel!
    
    
    // MARK: - Variables
    
    var users101: [Usertable] = []
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingIndicator.shared.show(in: view)
        
        Task {
            if let sessionUserID = await SessionManager.shared.getSessionUser() {
                await setupHeader(forUserID: sessionUserID)
                LoadingIndicator.shared.hide()
            } else {
                print("Warning: No session user available when viewDidLoad, header might not load.")
                LoadingIndicator.shared.hide()
            }
            //await fetchPlayerGameLogs()
            
        }
        
        reloadInputViews()
        setupView()
        setupCollectionViews()
        //    setupHeaderGradient()
        styleSectionViews()
        setupPointsScoredSection()
        fetchAthletesData()
        
        addSwiftUIChart()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderGradientFrame()
    }
    
    
    // MARK: - View Setup
    
    private func setupView() {
        RoundedCard()
        //setupMatchesPlayedVsPointsScoredGraph() // Commented out in original code
    }
    
    private func RoundedCard() {
        styleStatCard(StatsCardLeft)
        styleStatCard(StatsCardRight)
        styleStatCard(CustomHeaderCard)
    }
    
    private func styleStatCard(_ cardView: UIView) {
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.clipsToBounds = false
    }
    
    private func setupHeaderGradient() {
        let gradientLayer = CAGradientLayer()
        if let color1 = UIColor(hex: "#367BFF")?.cgColor,
           let color2 = UIColor(hex: "#668FFD")?.cgColor,
           let color3 = UIColor(hex: "#95A4FC")?.cgColor {
            gradientLayer.colors = [color1, color2, color3]
        } else {
            gradientLayer.colors = [UIColor.orange.cgColor, UIColor.white.cgColor, UIColor.white.cgColor] // Fallback colors
        }
        gradientLayer.locations = [0.0, 0.5, 1.0]
        CustomHeaderCard.layer.cornerRadius = 16
        CustomHeaderCard.clipsToBounds = true
        self.gradientLayer = gradientLayer // Store reference
        CustomHeaderCard.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func updateHeaderGradientFrame() {
        gradientLayer?.frame = CustomHeaderCard.bounds
    }
    
    private func styleSectionViews() {
        let viewsToStyle = [pointsScoredImageView, matchesPlayedvsPointsScoredView]
        for view in viewsToStyle {
            //                view?.layer.borderColor = UIColor.lightGray.cgColor
            //                view?.layer.borderWidth = 1.0
            //                view?.layer.cornerRadius = 16
            //                view?.clipsToBounds = true
            
            view?.layer.cornerRadius = 16
            view?.layer.shadowColor = UIColor.black.cgColor
            view?.layer.shadowOpacity = 0.1
            view?.layer.shadowOffset = CGSize(width: 2, height: 2)
            view?.layer.shadowRadius = 4
            view?.clipsToBounds = true
        }
    }
    
    private func setupPointsScoredSection() {
        // pointsScoredBarGraphView.layer.cornerRadius = 8 // Commented out in original code
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
        } else {
            print("Could not instantiate AddPostViewController")
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
            
            var fetchedAthleteProfile: AthleteProfileTable?
            if fetchedUser.role == .athlete {
                let athleteResponse = try await supabase.from("AthleteProfile").select("*").eq("athleteID", value: userID).single().execute()
                let athleteDecoder = JSONDecoder()
                fetchedAthleteProfile = try athleteDecoder.decode(AthleteProfileTable.self, from: athleteResponse.data)
            }
            
            guard let athleteProfile = fetchedAthleteProfile else {
                print("No athlete profile found.")
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.configureHeaderUI(with: fetchedUser, athleteProfile: athleteProfile)
            }
            
        } catch {
            print("Error setting up header data: \(error)")
        }
    }
    
    private func configureHeaderUI(with fetchedUser: Usertable, athleteProfile: AthleteProfileTable) {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        userNameLabel.text = fetchedUser.name
        ppgLabel.text = String(format: "%.1f", athleteProfile.averagePointsPerGame)
        bpgLabel.text = String(format: "%.1f", athleteProfile.averageReboundsPerGame)
        // self.astLabel.text = String(format: "%.1f", athleteProfile.averageAssistsPerGame) // Commented out in original code
        

        if let imageName = fetchedUser.profilePicture,
           let localImage = UIImage(named: imageName) {
            profileImageView.image = localImage
        } else if let imageUrlString = fetchedUser.profilePicture,
                  let imageUrl = URL(string: imageUrlString) {
            profileImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }
    }
    
    
    // MARK: - Data Fetching
    
    private func fetchAthletesData() {
        Task {
            await fetchAndReloadAthletes()
        }
    }
    
    private func fetchAndReloadAthletes() async {
        do {
            let response = try await supabase.from("User").select("*").eq("role", value: Role.athlete.rawValue).execute()
            let decoder = JSONDecoder()
            users101 = try decoder.decode([Usertable].self, from: response.data)
            
            DispatchQueue.main.async { [weak self] in
                self?.athletesCollectionView.reloadData()
                LoadingIndicator.shared.hide()
            }
        } catch {
            print("Error fetching athletes: \(error)")
            LoadingIndicator.shared.hide()
        }
    }
    
    
    // MARK: - Collection View Setup
    
    private func setupCollectionViews() {
        setupCollectionViewDelegates(athletesCollectionView, delegate: self, dataSource: self)
        setupCollectionViewDelegates(BestMatchCollectionView, delegate: self, dataSource: self)
        setupCollectionViewDelegates(CreationCollectionView, delegate: self, dataSource: self)
    }
    
    private func setupCollectionViewDelegates(_ collectionView: UICollectionView, delegate: UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout, dataSource: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout) {
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource
    }
    
    
    // MARK: - Best Match Fetching
    
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
    
    
    // MARK: - Points Scored Graph Setup
    
    func setupPointsScoredGraph(for userID: UUID) async {
        do {
            let gameLogResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("playerID", value: userID)
                .execute()
            
            let gameLogDecoder = JSONDecoder()
            let gameLogs = try gameLogDecoder.decode([GameLogtable].self, from: gameLogResponse.data)
            
            let gameIDs = gameLogs.map { $0.gameID }
            let gameResponse = try await supabase
                .from("Game")
                .select("*")
                .in("gameID", values: gameIDs)
                .execute()
            
            let gameDecoder = JSONDecoder()
            let games = try gameDecoder.decode([GameTable].self, from: gameResponse.data)
            
            guard !gameLogs.isEmpty else { return }
            
            pointsScoredBarGraphView.subviews.forEach { $0.removeFromSuperview() }
            pointsScoredBarGraphView.clipsToBounds = true
            
            drawPointsScoredGraph(gameLogs: gameLogs, games: games)
            
            
        } catch {
            print("Error fetching data for points scored graph: \(error)")
        }
    }
    
    private func drawPointsScoredGraph(gameLogs: [GameLogtable], games: [GameTable]) {
        let leftPadding: CGFloat = 50
        let bottomPadding: CGFloat = 30
        let graphHeight: CGFloat = pointsScoredBarGraphView.bounds.height - bottomPadding
        let graphWidth: CGFloat = pointsScoredBarGraphView.bounds.width - leftPadding
        let maxPoints: CGFloat = 150
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        let calendar = Calendar.current
        var monthlyPoints = [Int](repeating: 0, count: 12)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for log in gameLogs {
            if let game = games.first(where: { $0.gameID == log.gameID }),
               let gameDate = dateFormatter.date(from: game.dateOfGame) {
                let totalPoints = (log.points2 * 2) + (log.points3 * 3) + log.freeThrows
                let month = calendar.component(.month, from: gameDate) - 1
                monthlyPoints[month] += totalPoints
            }
        }
        
        let numberOfBars = monthlyPoints.filter { $0 > 0 }.count
        let barWidth = numberOfBars > 0 ? graphWidth / CGFloat(numberOfBars * 2) : 0
        let spacing = barWidth
        
        drawGridLinesAndLabels(numberOfGridLines: 5, graphHeight: graphHeight, graphWidth: graphWidth, leftPadding: leftPadding, maxPoints: maxPoints)
        drawBarsAndMonthLabels(monthlyPoints: monthlyPoints, months: months, graphHeight: graphHeight, graphWidth: graphWidth, leftPadding: leftPadding, barWidth: barWidth, spacing: spacing, maxPoints: maxPoints)
    }
    
    private func drawGridLinesAndLabels(numberOfGridLines: Int, graphHeight: CGFloat, graphWidth: CGFloat, leftPadding: CGFloat, maxPoints: CGFloat) {
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
    }
    
    private func drawBarsAndMonthLabels(monthlyPoints: [Int], months: [String], graphHeight: CGFloat, graphWidth: CGFloat, leftPadding: CGFloat, barWidth: CGFloat, spacing: CGFloat, maxPoints: CGFloat) {
        var xOffset = leftPadding
        for (index, points) in monthlyPoints.enumerated() {
            let barHeight = graphHeight * CGFloat(points) / maxPoints
            let barX = xOffset
            
            let barView = UIView(frame: CGRect(x: barX, y: graphHeight - barHeight, width: barWidth, height: barHeight))
            barView.backgroundColor = points > 0 ? .systemOrange : .lightGray.withAlphaComponent(0.3)
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
    }
    
    
    
    // MARK: - Creation Actions
    
    func createPost() {
        
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
        case athletesCollectionView:
            return users101.count
        case CreationCollectionView:
            return 3 // Static cards for CreationCollectionView
        default:
            return 1 // For BestMatchCollectionView and default
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case athletesCollectionView:
            return athleteCollectionViewCell(collectionView, cellForItemAt: indexPath)
        case BestMatchCollectionView:
            return bestMatchCollectionViewCell(collectionView, cellForItemAt: indexPath)
        case CreationCollectionView:
            return creationCollectionViewCell(collectionView, cellForItemAt: indexPath)
        default:
            return UICollectionViewCell() // Default cell
        }
    }
    
    // Athletes Collection View Cell Configuration
    private func athleteCollectionViewCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "athletesNewCollectionViewCell", for: indexPath) as? athletesNewCollectionViewCell else {
            return UICollectionViewCell()
        }
        let user = users101[indexPath.row]
        cell.configure(with: user)
        return cell
    }
    
    // Best Match Collection View Cell Configuration
    private func bestMatchCollectionViewCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BestMatchCollectionViewCell", for: indexPath) as? BestMatchCollectionViewCell else {
            return UICollectionViewCell()
        }
        Task {
            do {
                if let sessionUserID = await SessionManager.shared.getSessionUser() {
                    if let bestMatch = try await fetchBestMatchSupabase(forPlayerID: sessionUserID) {
                        await updateBestMatchViewSupabase(with: bestMatch, cell: cell)
                        LoadingIndicator.shared.hide()
                    }
                } else {
                    print("Error: No session user is set")
                    LoadingIndicator.shared.hide()
                }
            } catch {
                print("Error fetching or updating best match: \(error)")
                LoadingIndicator.shared.hide()
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
                    cell.myTeamImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
                }
                
                if let newimageName = team2.teamLogo,
                   let localImage = UIImage(named: newimageName) {
                    cell.opponentTeamImageView.image = localImage
                } else if let imageUrlString = team2.teamLogo,
                          let imageUrl = URL(string: imageUrlString) {
                    cell.opponentTeamImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "person.circle"))
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
        case athletesCollectionView:
            athleteCollectionViewDidSelectItem(at: indexPath)
        case CreationCollectionView:
            creationCollectionViewDidSelectItem(at: indexPath)
        default:
            break // Handle other collection views if needed
        }
    }
    
    // Athlete Collection View Item Selection
    private func athleteCollectionViewDidSelectItem(at indexPath: IndexPath) {
        let selectedAthlete = users101[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ViewUserViewController") as? ViewUserViewController {
            profileVC.selectedUserID = selectedAthlete.userID
            navigationController?.pushViewController(profileVC, animated: true)
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
        if collectionView == athletesCollectionView {
            if indexPath.item == 0 {
                return CGSize(width: screenWidth/2, height: 150)
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
    
    
    
    func drawSmoothLineGraph(in view: UIView, dataPoints: [CGFloat], months: [String]) {
        // Remove any existing layers
        view.layer.sublayers?.forEach { if $0 is CAShapeLayer || $0 is CATextLayer { $0.removeFromSuperlayer() } }
        
        // Set up drawing area
        let width = view.bounds.width
        let height = view.bounds.height
        let padding: CGFloat = 30  // Padding for labels
        
        // Find min and max values for scaling
        guard let minValue = dataPoints.min(),
              let maxValue = dataPoints.max(),
              dataPoints.count > 1 else { return }
        
        // Calculate spacing between points
        let pointSpacing = (width - 2 * padding) / CGFloat(dataPoints.count - 1)
        
        // Create path for the smooth curve
        let path = UIBezierPath()
        
        // Calculate points
        var points = [CGPoint]()
        
        // Transform data points to coordinates
        for (index, dataPoint) in dataPoints.enumerated() {
            // Normalize value between 0 and 1, then scale to view height (inverted, since drawing from top)
            let normalizedValue = (dataPoint - minValue) / (maxValue - minValue)
            let yPosition = height - padding - normalizedValue * (height - 2 * padding)
            let xPosition = padding + CGFloat(index) * pointSpacing
            
            points.append(CGPoint(x: xPosition, y: yPosition))
        }
        
        // Draw smooth curve through points
        if points.count > 0 {
            path.move(to: points[0])
            
            if points.count == 2 {
                // Only two points, draw a straight line
                path.addLine(to: points[1])
            } else {
                // Draw smooth curve for 3+ points
                for i in 1..<points.count-1 {
                    let currentPoint = points[i]
                    let nextPoint = points[i+1]
                    
                    // Calculate control points for cubic Bezier curve
                    let controlPoint1 = CGPoint(
                        x: currentPoint.x + (nextPoint.x - points[i-1].x) / 4,
                        y: currentPoint.y + (nextPoint.y - points[i-1].y) / 4
                    )
                    
                    let controlPoint2 = CGPoint(
                        x: nextPoint.x - (points[i+1 == points.count ? i : i+1].x - currentPoint.x) / 4,
                        y: nextPoint.y - (points[i+1 == points.count ? i : i+1].y - currentPoint.y) / 4
                    )
                    
                    path.addCurve(to: nextPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                }
            }
        }
        
        // Create line layer
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = UIColor(hex: "#FD6330")?.cgColor
        lineLayer.lineWidth = 3.0
        lineLayer.lineCap = .round
        lineLayer.lineJoin = .round
        
        // Add line layer to view
        view.layer.addSublayer(lineLayer)
        
        // Draw data points as circles
        for point in points {
            let circleLayer = CAShapeLayer()
            let circlePath = UIBezierPath(ovalIn: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8))
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor(hex: "#FD6330")?.cgColor
            view.layer.addSublayer(circleLayer)
        }
        
        // Add month labels and grid lines
        for (index, month) in months.enumerated() {
            // Skip some months if there are too many to avoid label overlap
            let skipFactor = max(1, Int(ceil(Double(months.count) / 6.0)))
            if index % skipFactor != 0 && index != months.count - 1 { continue }
            
            let xPosition = padding + CGFloat(index) * pointSpacing
            
            // Add month label
            let textLayer = CATextLayer()
            textLayer.string = month
            textLayer.fontSize = 12
            textLayer.alignmentMode = .center
            textLayer.foregroundColor = UIColor.darkGray.cgColor
            textLayer.frame = CGRect(x: xPosition - 20, y: height - 25, width: 40, height: 20)
            // Fix for proper text rendering
            textLayer.contentsScale = UIScreen.main.scale
            view.layer.addSublayer(textLayer)
            
            // Draw light vertical grid line
            let gridLayer = CAShapeLayer()
            let gridPath = UIBezierPath()
            gridPath.move(to: CGPoint(x: xPosition, y: padding))
            gridPath.addLine(to: CGPoint(x: xPosition, y: height - padding))
            gridLayer.path = gridPath.cgPath
            gridLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
            gridLayer.lineWidth = 1
            view.layer.addSublayer(gridLayer)
        }
        
        // Animate the drawing of the line
        lineLayer.strokeEnd = 0
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.0
        lineLayer.strokeEnd = 1
        lineLayer.add(animation, forKey: "drawLineAnimation")
    }
    
   
    
    func addSwiftUIChart() {
        let graph2 = HomeFieldGoalChartView()
        // Create a UIHostingController with the SwiftUI view
        let hostingController2 = UIHostingController(rootView: graph2)
        // Add the hosting controller as a child view controller
        addChild(hostingController2)
        // Set the frame of the hosting controller's view to match someView
        hostingController2.view.frame = pointsScoredImageView.bounds
        pointsScoredImageView.clipsToBounds = true
        // Add the hosting controller's view to someView
        pointsScoredImageView.addSubview(hostingController2.view)
        
        hostingController2.view.translatesAutoresizingMaskIntoConstraints = false

        // Set Auto Layout constraints to match the bounds of graphView2
        NSLayoutConstraint.activate([
            hostingController2.view.leadingAnchor.constraint(equalTo: pointsScoredImageView.leadingAnchor),
            hostingController2.view.trailingAnchor.constraint(equalTo: pointsScoredImageView.trailingAnchor),
            hostingController2.view.topAnchor.constraint(equalTo: pointsScoredImageView.topAnchor),
            hostingController2.view.bottomAnchor.constraint(equalTo: pointsScoredImageView.bottomAnchor,constant: -50)
        ])

        // Notify the hosting controller that it has been moved to the parent view controller
        hostingController2.didMove(toParent: self)

    }
}


