//
//  AnalyticsService.swift
//  swiftCharts
//
//  Created by admin65 on 04/05/25.
//


import Supabase
import Foundation

class AnalyticsService {
    static let shared = AnalyticsService()
    
    init() {
    }
    
    func fetchPlayerGameLogs(playerID: UUID) async throws -> [GameLogtable] {
        let response: [GameLogtable] = try await supabase.database
            .from("GameLog")
            .select()
            .eq("playerID", value: playerID)
            .order("gameDate", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    func fetchGameDetails(gameID: UUID) async throws -> GameTable? {
        do {
            let response: GameTable = try await supabase.database
                .from("Game")
                .select()
                .eq("gameID", value: gameID)
                .single()
                .execute()
                .value
            
            return response
        } catch {
            print("Game not found: \(error)")
            return nil
        }
    }
}
