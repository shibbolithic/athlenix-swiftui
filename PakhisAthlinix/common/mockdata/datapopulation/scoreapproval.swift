//
//  scoreapproval.swift
//  AkshitasAthlinix
//
//  Created by admin65 on 13/12/24.
//

import Foundation

var scoreApprovals: [ScoreApproval] = [
    // Score Approvals
    ScoreApproval(approvalID: "scoreApproval1", gameID: "game1", requestedBy: "1", approvedBy: "6", approvalStatus: .Pending, dateRequested: Date()),
    ScoreApproval(approvalID: "scoreApproval2", gameID: "game2", requestedBy: "2", approvedBy: "7", approvalStatus: .Approved, dateRequested: Date(), dateApproved: Date()),
    ScoreApproval(approvalID: "scoreApproval3", gameID: "game3", requestedBy: "3", approvedBy: "6", approvalStatus: .Rejected, dateRequested: Date(), dateApproved: Date()),
    ScoreApproval(approvalID: "scoreApproval4", gameID: "game4", requestedBy: "4", approvedBy: "7", approvalStatus: .Pending, dateRequested: Date())
]
