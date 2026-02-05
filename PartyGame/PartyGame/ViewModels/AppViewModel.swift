//
//  AppViewModel.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import Foundation
import Combine

class AppViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var showSettings: Bool = false
    @Published var selectedGame: GameType? = nil
    @Published var lastSelectedGameId: String? = nil
    
    let settingsManager = SettingsManager()
    
    init() {
        // アプリ起動時の読み込み処理をシミュレート
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            self.isLoading = false
        }
    }
    
    func selectGame(_ game: GameType) {
        selectedGame = game
        lastSelectedGameId = game.id
    }
    
    func backToGameSelection() {
        selectedGame = nil
    }
}
