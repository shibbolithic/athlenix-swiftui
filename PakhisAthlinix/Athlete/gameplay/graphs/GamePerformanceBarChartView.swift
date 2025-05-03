//
//  GamePerformanceBarChartView.swift
//  GamePlay
//
//  Created by admin65 on 19/11/24.
//
import UIKit

class GamePerformanceBarChartView: UIView {
   
    //MARK: Data properties
    var months: [String] = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    var data: [[CGFloat]] = []
    let colors: [UIColor] = [
        UIColor(red: 150/255, green: 45/255, blue: 255/255, alpha: 1.0), // #962DFF
        UIColor(red: 74/255, green: 58/255, blue: 255/255, alpha: 1.0),  // #4A3AFF
        UIColor(red: 224/255, green: 198/255, blue: 253/255, alpha: 1.0), // #E0C6FD
        UIColor(red: 147/255, green: 170/255, blue: 253/255, alpha: 1.0)  // #93AAFD
    ]
    
    
    
    //MARK:  Tap handling
    private var barFrames: [(CGRect, CGFloat)] = [] // Stores the frames of bars and their data values
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizer()
        self.data = [[CGFloat]](repeating: [CGFloat](repeating: 0, count: 12), count: 4)
            // Fetch data asynchronously
            fetchData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestureRecognizer()
        self.data = [[CGFloat]](repeating: [CGFloat](repeating: 0, count: 12), count: 4)
            
            // Fetch data asynchronously
            fetchData() // Aggregate data
        
    }
    //MARK: fetchData
    private func fetchData() {
        Task {
            do {
                let aggregatedData = try await aggregateGameData()
                DispatchQueue.main.async {
                    self.data = aggregatedData
                    self.setNeedsDisplay() // Redraw the view
                }
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
    
    
    //MARK: Function to aggregate data for the chart based on the game logs
    func aggregateGameData() async throws -> [[CGFloat]] {
        var aggregatedData = [[CGFloat]](repeating: [CGFloat](repeating: 0, count: 12), count: 4)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
              throw NSError(domain: "SessionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No session user is set"])
          }

        // Fetch game logs for the logged-in user
        let gameLogsResponse = try await supabase.from("GameLog").select("*").eq("playerID", value: sessionUserID).execute()
        let gameLogs = try decoder.decode([GameLogtable].self, from: gameLogsResponse.data)

        // Extract game IDs from the user's game logs
        let userGameIDs = Set(gameLogs.map { $0.gameID })

        // Fetch games associated with the user's logs
        let gamesResponse = try await supabase
            .from("Game")
            .select("*")
            .in("gameID", values: Array(userGameIDs)).execute()
        let games = try decoder.decode([GameTable].self, from: gamesResponse.data)

        // Configure a custom DateFormatter for "YYYY-MM-DD"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Assuming UTC

        // Iterate through game logs and aggregate stats for each month
        for log in gameLogs {
            // Find the associated game by matching game ID or other identifying property
            if let game = games.first(where: { $0.gameID == log.gameID }) {
                // Convert dateOfGame from String to Date
                guard let gameDate = dateFormatter.date(from: game.dateOfGame) else {
                    print("Invalid date format for game: \(game.dateOfGame)")
                    continue
                }

                let calendar = Calendar.current
                let month = calendar.component(.month, from: gameDate) - 1 // Month 1 is January, 0-indexed for the array

                // Ensure the month is within the valid range (0 to 11)
                if month >= 0 && month < 12 {
                    aggregatedData[0][month] += CGFloat(log.points2)    // 2-pointers
                    aggregatedData[1][month] += CGFloat(log.points3)    // 3-pointers
                    aggregatedData[2][month] += CGFloat(log.rebounds)   // Rebounds
                    aggregatedData[3][month] += CGFloat(log.freeThrows) // Free Throws
                } else {
                    print("Invalid month: \(month) for game date: \(gameDate)")
                }
            }
        }
        print(aggregatedData)
        return aggregatedData
    }
    
    
    //MARK: gesture
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
   // MARK: Draw Func
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Dimensions
        let chartWidth = rect.width - 30 // Reserve space for vertical grid labels
        let chartHeight = rect.height - 40 // Reserve space for bottom labels
        let barWidth: CGFloat = chartWidth / (CGFloat(months.count) * 5)
        let maxDataValue: CGFloat = 50.0 // Maximum value for scaling
        let gridLineCount = 6
        barFrames.removeAll() // Reset bar frames
        
        // Draw Grid Lines
        context.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(1)
        
        for i in 0...gridLineCount {
            let y = CGFloat(i) * (chartHeight / CGFloat(gridLineCount))
            context.move(to: CGPoint(x: 30, y: y))
            context.addLine(to: CGPoint(x: chartWidth + 30, y: y))
            
            // Add grid labels
            let gridValue = Int(maxDataValue - (CGFloat(i) * (maxDataValue / CGFloat(gridLineCount))))
            let label = UILabel()
            label.text = "\(gridValue)"
            label.font = UIFont.systemFont(ofSize: 10)
            label.textColor = .darkGray
            label.textAlignment = .right
            label.frame = CGRect(x: 0, y: y - 10, width: 25, height: 20)
            addSubview(label)
        }
        context.strokePath()
        
        // Draw Bars
        for (monthIndex, _) in months.enumerated() {
            let xOffset: CGFloat = 30 + CGFloat(monthIndex) * barWidth * 5 + barWidth
            
            for (dataTypeIndex, dataValues) in data.enumerated() {
                let value = dataValues[monthIndex]
                let barHeight = (value / maxDataValue) * chartHeight
                
                let barX = xOffset + CGFloat(dataTypeIndex) * barWidth
                let barY = chartHeight - barHeight
                let barFrame = CGRect(x: barX, y: barY, width: barWidth, height: barHeight)
                
                // Store bar frame and value for interaction
                barFrames.append((barFrame, value))
                
                // Draw the bar
                colors[dataTypeIndex].setFill()
                context.fill(barFrame)
            }
        }
        
        // Add Month Labels
        for (index, month) in months.enumerated() {
            let xOffset: CGFloat = 30 + CGFloat(index) * barWidth * 5 + barWidth * 2.5
            let label = UILabel()
            label.text = month
            label.font = UIFont.systemFont(ofSize: 10)
            label.textColor = .darkGray
            label.textAlignment = .center
            label.frame = CGRect(x: xOffset - 15, y: chartHeight + 5, width: 30, height: 20)
            addSubview(label)
        }
    }
    //MARK: handle tap
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self)
        
        // Check if the tap is within any bar frame
        for (barFrame, value) in barFrames {
            if barFrame.contains(tapLocation) {
                showDataPoint(value: value, at: barFrame)
                break
            }
        }
    }
    
    //MARK:  Show Data Point
    private func showDataPoint(value: CGFloat, at barFrame: CGRect) {
        let dataLabel = UILabel()
        dataLabel.text = "\(Int(value))"
        dataLabel.font = UIFont.boldSystemFont(ofSize: 12)
        dataLabel.textColor = .white
        dataLabel.backgroundColor = .black
        dataLabel.textAlignment = .center
        dataLabel.layer.cornerRadius = 5
        dataLabel.clipsToBounds = true
        
        // Position the label above the bar
        let labelWidth: CGFloat = 40
        let labelHeight: CGFloat = 20
        let labelX = barFrame.midX - labelWidth / 2
        let labelY = barFrame.minY - labelHeight - 5
        dataLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        
        self.addSubview(dataLabel)
        
        // Remove the label after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dataLabel.removeFromSuperview()
        }
    }
}
