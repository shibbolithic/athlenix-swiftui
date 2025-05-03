//
//  TeamPerformanceBarChartView.swift
//  PakhisAthlinix
//
//  Created by admin65 on 15/12/24.
//


import UIKit

class TeamPerformanceBarChartViewClass: UIView {
   
    // Data for the graph
    var playerScores: [CGFloat] = [] // Holds scores from GameLogs
    var playerImages: [UIImage?] = [] // Holds images of team members
    
    // Assuming the current team ID and user ID are available
    var currentTeamID = UUID(uuidString: "ba1faa4a-e1b6-4389-9fc5-8997d54a7dec") // Replace with dynamic value if necessary
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Fetch data from team and game logs
        Task{
            do{
                if let teamData = await fetchTeamPerformanceDataSupabase(teamID: currentTeamID!) {
                    playerScores = teamData.map { $0.score }
                    playerImages = teamData.map { UIImage(named: $0.image) }
                    setNeedsDisplay()
            }
        }
        // Trigger a redraw with the updated data
        }
    }

    // MARK: - Fetch Team Performance Data
    
    //MARK: SUPABASE
    private func fetchTeamPerformanceDataSupabase(teamID: UUID) async -> [(score: CGFloat, image: String)]? {
        do {
            // Fetch team members with the given team ID and role "Player"
            let teamMembershipResponse = try await supabase
                .from("teamMembership")
                .select("*")
                .eq("teamID", value: teamID.uuidString)
                .eq("roleInTeam", value: "athlete")
                .execute()
            let teamMembers = try JSONDecoder().decode([TeamMembershipTable].self, from: teamMembershipResponse.data)
            
            // Fetch game logs for the given team
            let gameLogsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("teamID", value: teamID.uuidString)
                .execute()
            let gameLogs = try JSONDecoder().decode([GameLogtable].self, from: gameLogsResponse.data)
            
            var performanceData: [(score: CGFloat, image: String)] = []
            
            for member in teamMembers {
                let userID = member.userID
                
                // Filter logs for the specific player
                let playerLogs = gameLogs.filter { $0.playerID == userID }
                
                // Calculate total points for the player
                let totalPoints = playerLogs.reduce(0) { $0 + $1.totalPoints }
                
                // Fetch player's profile picture
                let userResponse = try await supabase
                    .from("User")
                    .select("*")
                    .eq("userID", value: userID.uuidString)
                    .execute()
                let userData = try JSONDecoder().decode([Usertable].self, from: userResponse.data)
                let profilePicture = userData.first?.profilePicture ?? ""
                
                // Append to performance data
                performanceData.append((score: CGFloat(totalPoints), image: profilePicture))
            }
            
            return performanceData
        } catch {
            print("Error fetching team performance data: \(error)")
            return nil
        }
    }

    
    // MARK: - Drawing Properties
    var barColor: UIColor = UIColor.systemPurple.withAlphaComponent(0.5)
    var dotColor: UIColor = UIColor.orange
    var gridLineColor: UIColor = UIColor.systemGray3
    var maxScore: CGFloat = 300 // Maximum score for the graph
    var padding: CGFloat = 20 // Padding for labels and gridlines
    
    private var dotCenters: [CGPoint] = [] // To store dot centers for tap detection
    private let popupLabel = UILabel() // Popup to display the data point

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizer()
        setupPopupLabel()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestureRecognizer()
        setupPopupLabel()
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }

    private func setupPopupLabel() {
        popupLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        popupLabel.textColor = .white
        popupLabel.font = UIFont.systemFont(ofSize: 12)
        popupLabel.textAlignment = .center
        popupLabel.layer.cornerRadius = 5
        popupLabel.clipsToBounds = true
        popupLabel.isHidden = true
        self.addSubview(popupLabel)
    }

    override func draw(_ rect: CGRect) {
        guard playerScores.count == playerImages.count else { return }

        dotCenters = [] // Clear dot centers before redrawing

        let context = UIGraphicsGetCurrentContext()
        let gridSpacing: CGFloat = maxScore / 4 // Grid intervals (e.g., 0, 100, 200, 300)
        let gridLineHeight = rect.height * 0.7 // Height where gridlines end
        let chartTop = rect.height * 0.1 + padding
        let chartBottom = gridLineHeight + padding
        let barWidth: CGFloat = 30 // Width of each bar
        let spacing: CGFloat = 40 // Space between each bar
        let barStartX = rect.width * 0.1 // Starting X position for bars

        // Draw gridlines and labels
        for i in 0...4 {
            let y = chartBottom - (CGFloat(i) * (gridLineHeight / 4))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: padding, y: y))
            path.addLine(to: CGPoint(x: rect.width - padding, y: y))
            context?.setStrokeColor(gridLineColor.cgColor)
            context?.setLineWidth(1)
            context?.addPath(path.cgPath)
            context?.strokePath()

            // Draw grid labels
            let label = "\(Int(gridSpacing * CGFloat(i)))"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            let labelSize = label.size(withAttributes: attributes)
            label.draw(at: CGPoint(x: 5, y: y - labelSize.height / 2), withAttributes: attributes)
        }

        // Draw bars and dots
        for (index, score) in playerScores.enumerated() {
            let barHeight = (score / maxScore) * gridLineHeight
            let x = barStartX + CGFloat(index) * (barWidth + spacing)
            let y = chartBottom - barHeight

            // Draw bar
            context?.setFillColor(barColor.cgColor)
            context?.fill(CGRect(x: x, y: y, width: barWidth, height: barHeight))

            // Draw dot at the top of the bar
            let dotRadius: CGFloat = 6
            let dotCenter = CGPoint(x: x + barWidth / 2, y: y)
            dotCenters.append(dotCenter) // Save dot center for tap detection
            context?.setFillColor(dotColor.cgColor)
            context?.fillEllipse(in: CGRect(x: dotCenter.x - dotRadius, y: dotCenter.y - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
        }

        // Add profile pictures below bars
        for (index, image) in playerImages.enumerated() {
            let x = barStartX + CGFloat(index) * (barWidth + spacing)
            let imageY = chartBottom + 10
            let imageSize: CGFloat = 30
            let imageView = UIImageView(frame: CGRect(x: x + (barWidth - imageSize) / 2, y: imageY, width: imageSize, height: imageSize))
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = imageSize / 2 // Circular profile picture
            addSubview(imageView)
        }
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self)

        for (index, dotCenter) in dotCenters.enumerated() {
            let dotRadius: CGFloat = 6
            let distance = sqrt(pow(tapLocation.x - dotCenter.x, 2) + pow(tapLocation.y - dotCenter.y, 2))

            if distance <= dotRadius { // Check if tap is within the circle
                showPopup(at: dotCenter, value: Int(playerScores[index]))
                break
            }
        }
    }

    private func showPopup(at point: CGPoint, value: Int) {
        popupLabel.text = "\(value)"
        popupLabel.sizeToFit()
        popupLabel.frame = CGRect(
            x: point.x - popupLabel.frame.width / 2 - 5,
            y: point.y - popupLabel.frame.height - 10,
            width: popupLabel.frame.width + 10,
            height: popupLabel.frame.height + 5
        )
        popupLabel.isHidden = false

        // Hide the popup after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.popupLabel.isHidden = true
        }
    }
}
