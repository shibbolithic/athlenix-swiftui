//
//private func fetchTeamPerformanceData(teamID: UUID) {
//    Task {
//        do {
//            let response = try await supabase
//                .from("GameLog")
//                .select("*")
//                .eq("teamID", value: teamID.uuidString)
//                .execute()
//
//            let gameLogs = try JSONDecoder().decode([GameLogtable].self, from: response.data)
//            var playerScoresDict: [UUID: Int] = [:]
//
//            gameLogs.forEach {
//                playerScoresDict[$0.playerID, default: 0] += ($0.points2 * 2 + $0.points3 * 3 + $0.freeThrows)
//            }
//
//            let playerIDs = Array(playerScoresDict.keys.map { $0.uuidString })
//            let usersResponse = try await supabase
//                .from("User")
//                .select("userID, profilePicture")
//                .in("userID", values: playerIDs)
//                .execute()
//
//            let users = try JSONDecoder().decode([userphotos].self, from: usersResponse.data)
//
//            playerScores = playerIDs.compactMap { id in
//                guard let uuid = UUID(uuidString: id) else { return nil }
//                return CGFloat(playerScoresDict[uuid] ?? 0)
//            }
//
//            playerImages = users.compactMap { UIImage(named: $0.profilePicture) }
//            setNeedsDisplay()
//
//        } catch {
//            print("Error fetching team performance data: \(error)")
//        }
//    }
//}
