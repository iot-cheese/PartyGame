//
//  GameManager.swift
//  PartyGame
//
//  Manages available games
//

import Foundation
import SwiftUI

/// Singleton manager for all party games
class GameManager: ObservableObject {
    static let shared = GameManager()
    
    @Published var games: [PartyGameModel] = []
    
    private init() {
        registerGames()
    }
    
    /// Register all available games
    private func registerGames() {
        // Truth or Dare Game
        games.append(PartyGameModel(
            name: "真実か挑戦か",
            description: "クラシックなパーティーゲーム。真実の質問か挑戦を選ぼう！",
            iconName: "questionmark.circle.fill"
        ) {
            AnyView(TruthOrDareView())
        })
        
        // Random Number Generator
        games.append(PartyGameModel(
            name: "ランダム選択",
            description: "ランダムに数字を選んで順番や当選者を決めよう！",
            iconName: "dice.fill"
        ) {
            AnyView(RandomNumberView())
        })
        
        // Team Divider
        games.append(PartyGameModel(
            name: "チーム分け",
            description: "参加者を自動的にランダムなチームに分けます！",
            iconName: "person.3.fill"
        ) {
            AnyView(TeamDividerView())
        })
    }
    
    /// Add a new game to the manager
    func addGame(_ game: PartyGameModel) {
        games.append(game)
    }
}
