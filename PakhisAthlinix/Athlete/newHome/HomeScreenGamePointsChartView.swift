import SwiftUI
import Charts

// SwiftUI View for the Chart
struct HomeScreenGamePointsChartView: View {
    @State private var gameLogs: [GameLogtable] = []
    @State private var games: [GameTable] = []
    @State private var isLoading = true

    var monthlyData: [(month: String, totalPoints: Int)] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        var pointsByMonth: [String: Int] = [:]

        for log in gameLogs {
            if let game = games.first(where: { $0.gameID == log.gameID }),
               let date = dateFormatter.date(from: game.dateOfGame) {
                let month = DateFormatter().shortMonthSymbols[Calendar.current.component(.month, from: date) - 1]
                pointsByMonth[month, default: 0] += log.totalPoints
            }
        }

        // Explicitly map to ensure named tuples
        return pointsByMonth.sorted { $0.key < $1.key }
            .map { (month: $0.key, totalPoints: $0.value) }
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                Chart {
                    ForEach(monthlyData, id: \.month) { data in
                        LineMark(
                            x: .value("Month", data.month),
                            y: .value("Points", data.totalPoints)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.orange)
                        
                        if let lastData = monthlyData.last, data == lastData {
                            PointMark(
                                x: .value("Month", data.month),
                                y: .value("Points", data.totalPoints)
                            )
                            .symbol(Circle()) // This keeps it as a valid ChartSymbolShape
                            .foregroundStyle(.orange)
                            .annotation(position: .top, alignment: .center) {
                                VStack {
                                    Rectangle()
                                        .frame(width: 1, height: 30)
                                        .foregroundStyle(.orange)
                                    Circle()
                                        .frame(width: 12, height: 12)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }

                    }
                }
                .chartXAxis {
                    AxisMarks(values: monthlyData.map { $0.month }) { value in
                        AxisValueLabel()
                            .foregroundStyle(.gray)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 250)
            }
        }
        .task {
            await fetchSessionUserAndData()
        }
    }

    private func fetchSessionUserAndData() async {
        do {
            guard let userID = await SessionManager.shared.getSessionUser() else {
                print("Error: No session user is set")
                isLoading = false
                return
            }
            
            let gameLogsResponse = try await supabase
                .from("GameLog")
                .select("*")
                .eq("playerID", value: userID.uuidString)
                .execute()
            gameLogs = try JSONDecoder().decode([GameLogtable].self, from: gameLogsResponse.data)

            let gamesResponse = try await supabase
                .from("Game")
                .select("*")
                .execute()
            games = try JSONDecoder().decode([GameTable].self, from: gamesResponse.data)

            isLoading = false
        } catch {
            print("Error fetching data: \(error)")
            isLoading = false
        }
    }
}

// UIViewControllerRepresentable to embed in Storyboard
//class GraphViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let hostingController = UIHostingController(rootView: HomeScreenGamePointsChartView())
//        addChild(hostingController)
//        hostingController.view.frame = view.bounds
//        view.addSubview(hostingController.view)
//        hostingController.didMove(toParent: self)
//    }
//}
