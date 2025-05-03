//
//  team.swift
//  AkshitasAthlinix
//
//  Created by admin65 on 13/12/24.
//

import Foundation

// MARK:  Team Data
var teams: [Teams] = [
    Teams(teamID: "1", teamName: "Red Warriors", teamMotto: "Victory Awaits", teamLogo: "team1", createdBy: "6", dateCreated: Date()),
    Teams(teamID: "2", teamName: "Blue Sharks", teamMotto: "Unstoppable Force", teamLogo: "team2", createdBy: "7", dateCreated: Date()),
    Teams(teamID: "3", teamName: "Golden Eagles", teamMotto: "Fly High", teamLogo: "team3", createdBy: "6", dateCreated: Date()),
    Teams(teamID: "4", teamName: "Silver Lions", teamMotto: "Roar Loud", teamLogo: "team4", createdBy: "7", dateCreated: Date()),
    Teams(teamID: "5", teamName: "Green Panthers", teamMotto: "Speed and Power", teamLogo: "team5", createdBy: "6", dateCreated: Date())
]

// MARK: Team Membership Data

var teamMemberships: [TeamMembership] = [
    // Red Warriors (5 athletes, 1 coach)
    TeamMembership(membershipID: "1", teamID: "1", userID: "1", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "2", teamID: "1", userID: "2", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "3", teamID: "1", userID: "3", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "4", teamID: "1", userID: "4", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "5", teamID: "1", userID: "5", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "6", teamID: "1", userID: "6", roleInTeam: "Coach", dateJoined: Date()),
    
    // Blue Sharks (5 athletes, 1 coach)
    TeamMembership(membershipID: "7", teamID: "2", userID: "1", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "8", teamID: "2", userID: "2", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "9", teamID: "2", userID: "3", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "10", teamID: "2", userID: "4", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "11", teamID: "2", userID: "5", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "12", teamID: "2", userID: "7", roleInTeam: "Coach", dateJoined: Date()),
    
    // Golden Eagles (5 athletes, 1 coach)
    TeamMembership(membershipID: "13", teamID: "3", userID: "1", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "14", teamID: "3", userID: "2", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "15", teamID: "3", userID: "3", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "16", teamID: "3", userID: "4", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "17", teamID: "3", userID: "5", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "18", teamID: "3", userID: "6", roleInTeam: "Coach", dateJoined: Date()),
    
    // Silver Lions (5 athletes, 1 coach)
    TeamMembership(membershipID: "19", teamID: "4", userID: "1", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "20", teamID: "4", userID: "2", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "21", teamID: "4", userID: "3", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "22", teamID: "4", userID: "4", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "23", teamID: "4", userID: "5", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "24", teamID: "4", userID: "7", roleInTeam: "Coach", dateJoined: Date()),
    
    // Green Panthers (5 athletes, 1 coach)
    TeamMembership(membershipID: "25", teamID: "5", userID: "1", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "26", teamID: "5", userID: "2", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "27", teamID: "5", userID: "3", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "28", teamID: "5", userID: "4", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "29", teamID: "5", userID: "5", roleInTeam: "Player", dateJoined: Date()),
    TeamMembership(membershipID: "30", teamID: "5", userID: "6", roleInTeam: "Coach", dateJoined: Date())
]
