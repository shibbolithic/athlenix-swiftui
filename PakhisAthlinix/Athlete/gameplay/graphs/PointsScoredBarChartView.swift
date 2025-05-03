//
//  PointsScoredBarChartView.swift
//  GamePlay
//
//  Created by admin65 on 19/11/24.
//

import UIKit


class PointsScoredBarChartView: UIView {
    
    //MARK: Define years dynamically or hardcode specific years
    let years = ["2024", "2023", "2022", "2021", "2020"]
    var values: [CGFloat] = []
    
    //    var loggedInUserID: String = "1" // Example logged-in user ID
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Task {
            await fetchDataForLoggedInUser()
        }    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Task {
            await fetchDataForLoggedInUser()
        }    }
    //MARK: fetch data
    private func fetchDataForLoggedInUser() async {
        //guard let userID = loggedInUserID else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
            print("Error: No session user is set")
            return
        }
        
        do {
            // Fetch game logs for the logged-in user
            let gameLogsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("playerID", value: sessionUserID.uuidString)
                .execute()
            let gameLogs = try JSONDecoder().decode([GameLogtable].self, from: gameLogsResponse.data)
            
            // Fetch game details for calculating years
            let gamesResponse = try await supabase
                .from("Game")
                .select("*")
                .execute()
            let games = try JSONDecoder().decode([GameTable].self, from: gamesResponse.data)
            
            var yearScores: [String: CGFloat] = years.reduce(into: [:]) { $0[$1] = 0 }
            
            for gameLog in gameLogs {
                if let game = games.first(where: { $0.gameID == gameLog.gameID }),
                   let date = dateFormatter.date(from: game.dateOfGame), // Parse date string to Date
                   let year = Calendar.current.dateComponents([.year], from: date).year {
                    let yearString = String(year)
                    if yearScores[yearString] != nil {
                        yearScores[yearString]! += CGFloat(gameLog.points2 + gameLog.points3 + gameLog.freeThrows)
                        print(gameLog.points2 + gameLog.points3 + gameLog.freeThrows)
                    }
                }
            }
            
            // Update the values array
            values = years.map { yearScores[$0] ?? 0 }
            print(values)
            // Redraw the view with the fetched data
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    //MARK: draw func
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Remove all existing subviews (e.g., UILabels from previous renders)
        self.subviews.forEach { $0.removeFromSuperview() }
        
        // Setup dimensions and styles
        let maxBarHeight: CGFloat = rect.height * 0.6
        let barWidth: CGFloat = rect.width / CGFloat(years.count) * 0.4
        let spacing: CGFloat = (rect.width / CGFloat(years.count)) * 0.6
        let maxValue = values.max() ?? 1
        let originY: CGFloat = rect.height * 0.8
        let baseColor = UIColor.systemPurple.withAlphaComponent(0.5)
        let lineColor = UIColor.systemRed
        
        // Draw grid lines and values
        let gridLineColor = UIColor.lightGray.withAlphaComponent(0.4)
        context.setStrokeColor(gridLineColor.cgColor)
        context.setLineWidth(1)
        
        let numGridLines = 5
        let gridValueSpacing = maxValue / CGFloat(numGridLines)
        let labelFont = UIFont.systemFont(ofSize: 12)
        let labelColor = UIColor.darkGray
        
        for i in 0...numGridLines {
            let y = originY - (CGFloat(i) / CGFloat(numGridLines) * maxBarHeight)
            
            // Draw grid line
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
            
            // Draw value labels for grid
            let gridValue = Int(gridValueSpacing * CGFloat(i))
            let valueLabel = UILabel()
            valueLabel.text = "\(gridValue)"
            valueLabel.font = labelFont
            valueLabel.textColor = labelColor
            valueLabel.sizeToFit()
            valueLabel.frame.origin = CGPoint(x: 4, y: y - valueLabel.frame.height / 2)
            self.addSubview(valueLabel)
        }
        context.strokePath()
        
        let leftMargin: CGFloat = 24
        // Draw bars and dots
        for (index, value) in values.enumerated() {
            let x = leftMargin + CGFloat(index) * (barWidth + spacing)
            let barHeight = (value / maxValue) * maxBarHeight
            let barRect = CGRect(x: x, y: originY - barHeight, width: barWidth, height: barHeight)
            
            context.setFillColor(baseColor.cgColor)
            context.fill(barRect)
            
            // Draw the dot
            let circleCenter = CGPoint(x: barRect.midX, y: barRect.minY)
            let circleRadius: CGFloat = 6
            context.setFillColor(lineColor.cgColor)
            context.addEllipse(in: CGRect(x: circleCenter.x - circleRadius,
                                          y: circleCenter.y - circleRadius,
                                          width: circleRadius * 2,
                                          height: circleRadius * 2))
            context.fillPath()
            
            // Draw year labels below bars
            let yearLabel = UILabel()
            yearLabel.text = years[index]
            yearLabel.font = labelFont
            yearLabel.textColor = labelColor
            yearLabel.textAlignment = .center
            yearLabel.sizeToFit()
            yearLabel.center = CGPoint(x: barRect.midX, y: originY + yearLabel.frame.height)
            self.addSubview(yearLabel)
        }
        
        // Draw connecting line
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(2)
        context.setLineJoin(.round)
        
        context.beginPath()
        for (index, value) in values.enumerated() {
            let x = CGFloat(index) * (barWidth + spacing) + spacing / 2 + barWidth / 2
            let y = originY - (value / maxValue) * maxBarHeight
            if index == 0 {
                context.move(to: CGPoint(x: x, y: y))
            } else {
                context.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context.strokePath()
    }
}
