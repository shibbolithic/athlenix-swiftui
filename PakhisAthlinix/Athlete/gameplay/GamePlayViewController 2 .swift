//
//  ViewController.swift
//  GamePlay
//
//  Created by admin65 on 19/11/24.
//

import UIKit
import Charts

class GamePlayViewController2: UIViewController {
    
    let loggedInPlayerID = "2" // Replace with the actual logged-in player ID
    
    
    @IBOutlet weak var totalPointsScoredView: UIView!
    @IBOutlet weak var totalPointsScoredLabel: UILabel!
    
    @IBOutlet weak var gamesPlayedView: UIView!
    @IBOutlet weak var gamesPlayedLabel: UILabel!
    
    @IBOutlet weak var scoringEfficiencyView: UIView!
    @IBOutlet weak var pointsPerGame: UILabel!
    @IBOutlet weak var percentageIncrease: UILabel!
    @IBOutlet weak var scoringEfficiencyLineGraphView: UIView!
    
    
    @IBOutlet weak var reboundsView: UIView!
    @IBOutlet weak var reboundsNumber: UILabel! //number of rebounds
    @IBOutlet weak var reboundsPercentageIncrease: UILabel!
    @IBOutlet weak var reboundsIncreaseLinceGraphView: UIView!
    
    @IBOutlet weak var statisticsView: UIView!
    @IBOutlet weak var assistsToTurnoverLabel: UILabel! //will have ratio in "9:3" format
   
    
    @IBOutlet weak var pointsScoredView: UIView!
    //@IBOutlet weak var pointsScoredBarChartView: UIView!
    @IBOutlet weak var pointsScoredBarChartView: PointsScoredBarChartView! //year wise points scored by a player, in gradient shades of #962DFF.
    
    
    @IBOutlet weak var goalsVsBricksView: UIView!
    
    @IBOutlet weak var goalsPieChartView: GoalsPieChartView!
    
   // @IBOutlet weak var goalsVsBricksPieChartView: UIView! //pie chart having three circles telling, out of the number of goals made, how many where missed, in 2PTFGS, 3PTFGS and Free Throws.
    
    
    @IBOutlet weak var gamePerformanceView: UIView!
    
    @IBOutlet weak var gamePerformanceBarChartView: GamePerformanceBarChartView!
    
    //@IBOutlet weak var gamePerformanceBarChartView: UIView! //bar graph of the number of rebounds, free throws, 2ptg and 3ptfg made in different months of an year in colours:- #962DFF, #4A3AFF, #E0C6FD, #93AAFD
    
    @IBOutlet weak var teamPerformanceView: UIView!
    
    
    @IBOutlet weak var teamPerformanceBarChartView: TeamPerformanceBarGamePlayChartView!
    
    //bar graph of points scored by members of users team.
    
    @IBOutlet weak var teamPerformanceLabel: UILabel!
    
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            //MARK: Style views
              styleOuterCardView(totalPointsScoredView)
              styleOuterCardView(gamesPlayedView)
              styleOuterCardView(scoringEfficiencyView)
              styleOuterCardView(reboundsView)
              styleOuterCardView(statisticsView)
              styleOuterCardView(pointsScoredView)
              styleOuterCardView(goalsVsBricksView)
              styleOuterCardView(gamePerformanceView)
              styleOuterCardView(teamPerformanceView)
            
            
//            if let pieChartView = goalsPieChartView as? GoalsPieChartView {
//                    pieChartView.gameLogs = gameLogs
//                    pieChartView.loadDataFromSupabase()
//                }
            
            Task {
                   await fetchPlayerGameLogs()
               }
        }
    
    //MARK: FETCH PLAYERS
    private func fetchPlayerGameLogs() async {
        guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
            print("Error: No session user is set")
            return
        }

        do {
            // Fetch game logs for the logged-in player
            let response = try await supabase
                .from("GameLog")
                .select("*")
                .eq("playerID", value: sessionUserID.uuidString)
                .execute()
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let playerGameLogs = try decoder.decode([GameLogtable].self, from: response.data)
            
            guard !playerGameLogs.isEmpty else { return }
            
            // MARK: Calculate metrics
            let totalPoints = playerGameLogs.reduce(0) { $0 + ($1.points2 + $1.points3 + $1.freeThrows) }
            //MARK: CODED
            let gamesPlayed = playerGameLogs.count - 1
            let pointsPerGameValue = Double(totalPoints) / Double(gamesPlayed)
            
            let firstGamePoints = playerGameLogs.first.map { $0.points2 + $0.points3 + $0.freeThrows } ?? 0
            let lastGamePoints = playerGameLogs.last.map { $0.points2 + $0.points3 + $0.freeThrows } ?? 0
            let scoringPercentageIncrease = firstGamePoints == 0 ? 0 : (Double(lastGamePoints - firstGamePoints) / Double(firstGamePoints)) * 100
            
            let totalRebounds = playerGameLogs.reduce(0) { $0 + $1.rebounds }
            let avgRebounds = Double(totalRebounds) / Double(gamesPlayed)
            
            let firstGameRebounds = playerGameLogs.first?.rebounds ?? 0
            let lastGameRebounds = playerGameLogs.last?.rebounds ?? 0
            let reboundsPercentageIncrease1 = firstGameRebounds == 0 ? 0 : (Double(lastGameRebounds - firstGameRebounds) / Double(firstGameRebounds)) * 100
            
            let totalAssists = playerGameLogs.reduce(0) { $0 + $1.assists }
            let totalTurnovers = playerGameLogs.reduce(0) { $0 + $1.fouls }
            let assistsToTurnoverRatio = totalTurnovers == 0 ? "N/A" : "\(totalAssists):\(totalTurnovers)"
            
            // MARK: Update UI on the main thread
            DispatchQueue.main.async {
                self.totalPointsScoredLabel.text = "\(totalPoints)"
                self.gamesPlayedLabel.text = "\(gamesPlayed)"
                self.pointsPerGame.text = String(format: "%.1f", pointsPerGameValue)
                self.percentageIncrease.text = String(format: "%.2f%%", scoringPercentageIncrease)
                self.percentageIncrease.textColor = scoringPercentageIncrease < 0 ? .red : .green
                
                self.reboundsNumber.text = String(format: "%.1f", avgRebounds)
                self.reboundsPercentageIncrease.text = String(format: "%.2f%%", reboundsPercentageIncrease1)
                self.reboundsPercentageIncrease.textColor = reboundsPercentageIncrease1 < 0 ? .red : .green
                
                self.assistsToTurnoverLabel.text = assistsToTurnoverRatio
                
                // MARK: Graphs
                let pointsData = playerGameLogs.map { CGFloat($0.points2 + $0.points3 + $0.freeThrows) }
                let reboundsData = playerGameLogs.map { CGFloat($0.rebounds) }
                
                self.drawLineGraph(in: self.scoringEfficiencyLineGraphView, dataPoints: pointsData)
                self.drawLineGraph(in: self.reboundsIncreaseLinceGraphView, dataPoints: reboundsData)
            }
        } catch {
            print("Error fetching player game logs: \(error)")
        }
    }


        //MARK: Styling function remains the same
        func styleOuterCardView(_ view: UIView) {
            view.layer.cornerRadius = 10
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.1
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
        }
        
        //MARK: Graph drawing function remains the same
    func drawLineGraph(in view: UIView, dataPoints: [CGFloat]) {
        // Ensure the graph is clipped within the view bounds
        view.clipsToBounds = true

        // Clear existing layers and subviews
        view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        view.subviews.forEach { $0.removeFromSuperview() }

        guard !dataPoints.isEmpty else { return } // Avoid errors with empty data
        
        let path = UIBezierPath()
        let width = view.bounds.width
        let height = view.bounds.height
        let padding: CGFloat = 10.0 // Padding for the graph
        
        // Normalize data to fit within the view
        let maxDataPoint = dataPoints.max() ?? 1
        let minDataPoint = dataPoints.min() ?? 0
        let range = maxDataPoint - minDataPoint
        let scaleFactor = range > 0 ? (height - 2 * padding) / range : 1.0
        
        // Start the path
        path.move(to: CGPoint(
            x: padding,
            y: height - padding - ((dataPoints[0] - minDataPoint) * scaleFactor)
        ))
        
        for (index, value) in dataPoints.enumerated() {
            let x = CGFloat(index) * (width - 2 * padding) / CGFloat(dataPoints.count - 1) + padding
            let y = height - padding - ((value - minDataPoint) * scaleFactor)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        // Create and style the shape layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.systemRed.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = UIColor.clear.cgColor

        // Add animation
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.5
        shapeLayer.add(animation, forKey: "lineAnimation")

        view.layer.addSublayer(shapeLayer)

        // Add dots at data points
        for (index, value) in dataPoints.enumerated() {
            let x = CGFloat(index) * (width - 2 * padding) / CGFloat(dataPoints.count - 1) + padding
            let y = height - padding - ((value - minDataPoint) * scaleFactor)
            let dot = UIView(frame: CGRect(x: x - 2.5, y: y - 2.5, width: 5, height: 5))
            dot.backgroundColor = UIColor.systemRed
            dot.layer.cornerRadius = 2.5
            view.addSubview(dot)
        }
    }


    //MARK: New scatter plot function
    func drawScatterPlot(in view: UIView, dataPoints: [(CGFloat, CGFloat)]) {
        let width = view.bounds.width
        let height = view.bounds.height
        
        // Determine max values for scaling
        let maxAssists = dataPoints.map { $0.0 }.max() ?? 1
        let maxTurnovers = dataPoints.map { $0.1 }.max() ?? 1
        
        // Add dots for each assist-turnover pair
        for (assists, turnovers) in dataPoints {
            let x = assists / maxAssists * width
            let y = height - (turnovers / maxTurnovers * height) // Invert Y-axis for UI coordinate system
            let dot = UIView(frame: CGRect(x: x - 4, y: y - 4, width: 8, height: 8))
            dot.backgroundColor = UIColor.systemBlue
            dot.layer.cornerRadius = 4
            view.addSubview(dot)
        }
        
        // Add axes
        addAxes(to: view)
    }

    //MARK: Helper function to add axes
    func addAxes(to view: UIView) {
        let width = view.bounds.width
        let height = view.bounds.height
        
        let xAxis = UIView(frame: CGRect(x: 0, y: height - 1, width: width, height: 1))
        xAxis.backgroundColor = .black
        view.addSubview(xAxis)
        
        let yAxis = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: height))
        yAxis.backgroundColor = .black
        view.addSubview(yAxis)
    }
    }

  
