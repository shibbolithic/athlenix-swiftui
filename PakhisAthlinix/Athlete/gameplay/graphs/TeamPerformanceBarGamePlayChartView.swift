import UIKit

class TeamPerformanceBarGamePlayChartView: UIView {

    // Data for the graph
    var playerScores: [CGFloat] = [] // Scores of team members
    var playerImages: [UIImage?] = [] // Profile images of team members

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Fetch and process team data
        if let teamPerformanceData = fetchTeamPerformanceData(teamID: "1") { // Replace "1" with the desired team ID
            playerScores = teamPerformanceData.map { CGFloat($0.score) }
            playerImages = teamPerformanceData.map { UIImage(named: $0.image) }
            setNeedsDisplay() // Trigger a redraw
        }
    }

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
        let gridSpacing: CGFloat = maxScore / 4
        let gridLineHeight = rect.height * 0.7
        let chartTop = rect.height * 0.1 + padding
        let chartBottom = gridLineHeight + padding
        let barWidth: CGFloat = 30
        let spacing: CGFloat = 40
        let barStartX = rect.width * 0.1

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

            context?.setFillColor(barColor.cgColor)
            context?.fill(CGRect(x: x, y: y, width: barWidth, height: barHeight))

            let dotRadius: CGFloat = 6
            let dotCenter = CGPoint(x: x + barWidth / 2, y: y)
            dotCenters.append(dotCenter)
            context?.setFillColor(dotColor.cgColor)
            context?.fillEllipse(in: CGRect(x: dotCenter.x - dotRadius, y: dotCenter.y - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
        }

        for (index, image) in playerImages.enumerated() {
            let x = barStartX + CGFloat(index) * (barWidth + spacing)
            let imageY = chartBottom + 10
            let imageSize: CGFloat = 30
            let imageView = UIImageView(frame: CGRect(x: x + (barWidth - imageSize) / 2, y: imageY, width: imageSize, height: imageSize))
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = imageSize / 2
            addSubview(imageView)
        }
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self)

        for (index, dotCenter) in dotCenters.enumerated() {
            let dotRadius: CGFloat = 6
            let distance = sqrt(pow(tapLocation.x - dotCenter.x, 2) + pow(tapLocation.y - dotCenter.y, 2))

            if distance <= dotRadius {
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.popupLabel.isHidden = true
        }
    }

    private func fetchTeamPerformanceData(teamID: String) -> [(score: Int, image: String)]? {
        // Fetch members of the team
        let teamMembers = teamMemberships.filter { $0.teamID == teamID }.map { $0.userID }
        
        // Calculate total scores for each member
        var teamPerformanceData: [(score: Int, image: String)] = []
        
        for memberID in teamMembers {
            let totalScore = gameLogs
                .filter { $0.playerID == memberID && $0.teamID == teamID }
                .reduce(0) { $0 + $1.points2 + $1.points3 + $1.freeThrows }
            
//            if let user = users.first(where: { $0.userID == memberID }) {
//                teamPerformanceData.append((score: totalScore, image: user.profilePicture))
//            }
        }
        
        return teamPerformanceData
    }
}
