import UIKit

class GoalsPieChartView: UIView {
    
    // Properties for the graph data
    var percentages: [CGFloat] = []
    var colors: [UIColor] = [
        UIColor(hex: "#962DFF")!,
        UIColor(hex: "#C6D2FD")!,
        UIColor(hex: "#4A3AFF")!
    ]
    var ringWidths: [CGFloat] = [20, 15, 10]
    private var arcs: [CGRect] = []
    private var radiusList: [CGFloat] = []
    private var percentageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        Task {
            await loadDataFromSupabase()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        Task {
            await loadDataFromSupabase()
        }
    }
    
    private func setup() {
        // Initialize the label for percentage display
        self.backgroundColor = .white
        
        percentageLabel = UILabel()
        percentageLabel.textAlignment = .center
        percentageLabel.font = UIFont.boldSystemFont(ofSize: 20)
        percentageLabel.textColor = .black
        percentageLabel.alpha = 0 // Initially hidden
        addSubview(percentageLabel)
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    private func loadDataFromSupabase() async {
        guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
            print("Error: No session user is set")
            return
        }
        
        do {
            // Fetch game logs for the specific team
           /* let teamID = UUID()*/ // Replace with actual teamID
            let gameLogsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("playerID", value: sessionUserID.uuidString)
                .execute()
            
            let gameLogs = try JSONDecoder().decode([GameLogtable].self, from: gameLogsResponse.data)
            
            // Aggregate the data for calculating percentages
            let totalFreeThrowsMade = gameLogs.reduce(0) { $0 + $1.freeThrows }
            let totalFreeThrowsMissed = gameLogs.reduce(0) { $0 + $1.missed2Points }
            let totalTwoPointsMade = gameLogs.reduce(0) { $0 + $1.points2 }
            let totalTwoPointsMissed = gameLogs.reduce(0) { $0 + $1.missed2Points }
            let totalThreePointsMade = gameLogs.reduce(0) { $0 + $1.points3 }
            let totalThreePointsMissed = gameLogs.reduce(0) { $0 + $1.missed3Points }
            
            // Calculate percentages
            let totalFreeThrows = CGFloat(totalFreeThrowsMade + totalFreeThrowsMissed)
            let totalTwoPoints = CGFloat(totalTwoPointsMade + totalTwoPointsMissed)
            let totalThreePoints = CGFloat(totalThreePointsMade + totalThreePointsMissed)
            
            percentages = [
                totalFreeThrows == 0 ? 0 : CGFloat(totalFreeThrowsMade) / totalFreeThrows,
                totalTwoPoints == 0 ? 0 : CGFloat(totalTwoPointsMade) / totalTwoPoints,
                totalThreePoints == 0 ? 0 : CGFloat(totalThreePointsMade) / totalThreePoints
            ]
            print(percentages)
            
            // Redraw the pie chart with the new data
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        } catch {
            print("Error fetching data from Supabase: \(error)")
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard percentages.count == colors.count, percentages.count == ringWidths.count else {
            print("Mismatch in the number of percentages, colors, or ring widths!")
            print(percentages)
            print(percentages.count)
            print(colors.count)
            print(ringWidths.count)
            return
        }
        
        arcs = [] // Reset the arcs for tap detection
        radiusList = []
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        var radius = min(rect.width, rect.height) / 2 - ringWidths.max()! // Adjust radius based on ring width
        
        for (index, percentage) in percentages.enumerated() {
            // Draw full grey ring
            drawCircle(center: center,
                       radius: radius,
                       startAngle: 0,
                       endAngle: 2 * .pi,
                       color: UIColor.systemGray6,
                       lineWidth: ringWidths[index])
            
            // Draw percentage arc
            let endAngle = 2 * .pi * percentage
            drawCircle(center: center,
                       radius: radius,
                       startAngle: -.pi / 2,
                       endAngle: endAngle - .pi / 2,
                       color: colors[index],
                       lineWidth: ringWidths[index])
            
            // Track arcs and radii for tap detection
            let arcRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            arcs.append(arcRect)
            radiusList.append(radius)
            
            // Update the radius for the next ring
            radius -= ringWidths[index] + 10 // Add spacing between rings
        }
    }
    
    private func drawCircle(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, color: UIColor, lineWidth: CGFloat) {
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        color.setStroke()
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.stroke()
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: self)
        
        // Check if the touch is within any arc
        for (index, arc) in arcs.enumerated() {
            let radius = radiusList[index]
            let center = CGPoint(x: arc.midX, y: arc.midY)
            let distance = sqrt(pow(touchPoint.x - center.x, 2) + pow(touchPoint.y - center.y, 2))
            
            // Check if the touch is within the radius range
            if distance >= radius - ringWidths[index] && distance <= radius {
                showPercentage(percentages[index])
                
                return
            }
        }
    }
    
    private func showPercentage(_ percentage: CGFloat) {
        percentageLabel.text = "\(Int(percentage * 100))%"
        percentageLabel.sizeToFit()
        percentageLabel.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        percentageLabel.alpha = 1
        
        // Animate the label to fade out after 2 seconds
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseOut) {
            self.percentageLabel.alpha = 0
        }
    }
}

// MARK: - Legend View
class LegendView: UIView {
    var colors: [UIColor] = []
    var titles: [String] = []
    
    private var stackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        addSubview(stackView)
    }
    
    func setupLegend(colors: [UIColor], titles: [String]) {
        self.colors = colors
        self.titles = titles
        
        // Clear existing legend items
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new legend items
        for (index, color) in colors.enumerated() {
            let legendItem = UIView()
            legendItem.translatesAutoresizingMaskIntoConstraints = false
            
            let colorView = UIView()
            colorView.backgroundColor = color
            colorView.layer.cornerRadius = 5
            colorView.translatesAutoresizingMaskIntoConstraints = false
            
            let titleLabel = UILabel()
            titleLabel.text = titles[index]
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            legendItem.addSubview(colorView)
            legendItem.addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                colorView.leadingAnchor.constraint(equalTo: legendItem.leadingAnchor),
                colorView.centerYAnchor.constraint(equalTo: legendItem.centerYAnchor),
                colorView.widthAnchor.constraint(equalToConstant: 10),
                colorView.heightAnchor.constraint(equalToConstant: 10),
                
                titleLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 8),
                titleLabel.trailingAnchor.constraint(equalTo: legendItem.trailingAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: legendItem.centerYAnchor)
            ])
            
            stackView.addArrangedSubview(legendItem)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = bounds
    }
}

// MARK: - Parent View to Combine Graph and Legend
class GoalsPieChartContainerView: UIView {
    private var pieChartView: GoalsPieChartView!
    private var legendView: LegendView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Initialize the pie chart view
        pieChartView = GoalsPieChartView()
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pieChartView)
        
        // Initialize the legend view
        legendView = LegendView()
        legendView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(legendView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            pieChartView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pieChartView.topAnchor.constraint(equalTo: topAnchor),
            pieChartView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pieChartView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7), // 70% width for the graph
            
            legendView.trailingAnchor.constraint(equalTo: trailingAnchor),
            legendView.topAnchor.constraint(equalTo: topAnchor),
            legendView.bottomAnchor.constraint(equalTo: bottomAnchor),
            legendView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3) // 30% width for the legend
        ])
        
        // Set up the legend with colors and titles
        legendView.setupLegend(colors: pieChartView.colors, titles: ["1 Pointers", "2 Pointers", "3 Pointers"])
    }
}

// Extension for UIColor to initialize with hex values
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
