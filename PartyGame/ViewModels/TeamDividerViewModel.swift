//
//  TeamDividerViewModel.swift
//  PartyGame
//
//  ViewModel for Team Divider
//

import Foundation

class TeamDividerViewModel: ObservableObject {
    @Published var playerNames: String = ""
    @Published var numberOfTeams: Int = 2
    @Published var teams: [[String]] = []
    @Published var hasGenerated: Bool = false
    
    func divideIntoTeams() {
        let players = playerNames
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard !players.isEmpty, numberOfTeams > 0 else {
            teams = []
            hasGenerated = false
            return
        }
        
        var shuffledPlayers = players.shuffled()
        var dividedTeams: [[String]] = Array(repeating: [], count: numberOfTeams)
        
        var teamIndex = 0
        while !shuffledPlayers.isEmpty {
            dividedTeams[teamIndex].append(shuffledPlayers.removeFirst())
            teamIndex = (teamIndex + 1) % numberOfTeams
        }
        
        teams = dividedTeams
        hasGenerated = true
    }
    
    func reset() {
        teams = []
        hasGenerated = false
    }
}
