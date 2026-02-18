//
//  SettingsManager.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import Foundation
import Combine
import StoreKit

class SettingsManager: ObservableObject {
    // 共有メンバー履歴用の共通ID
    static let sharedMemberHistoryId = "shared_members"
    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        }
    }
    
    @Published var playedGames: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(playedGames), forKey: "playedGames")
        }
    }
    
    @Published var hasRequestedReview: Bool {
        didSet {
            UserDefaults.standard.set(hasRequestedReview, forKey: "hasRequestedReview")
        }
    }
    
    @Published var gamePlayCounts: [String: Int] {
        didSet {
            UserDefaults.standard.set(gamePlayCounts, forKey: "gamePlayCounts")
        }
    }
    
    @Published var memberHistory: [String: [[String]]] {
        didSet {
            UserDefaults.standard.set(memberHistory, forKey: "memberHistory")
        }
    }
    
    init() {
        self.soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        
        let savedPlayedGames = UserDefaults.standard.stringArray(forKey: "playedGames") ?? []
        self.playedGames = Set(savedPlayedGames)
        
        self.hasRequestedReview = UserDefaults.standard.bool(forKey: "hasRequestedReview")
        
        self.gamePlayCounts = UserDefaults.standard.dictionary(forKey: "gamePlayCounts") as? [String: Int] ?? [:]
        self.memberHistory = UserDefaults.standard.dictionary(forKey: "memberHistory") as? [String: [[String]]] ?? [:]
        
        // デフォルトでサウンドをONに設定（初回起動時）
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            self.soundEnabled = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    func resetAllGameData() {
        let keysToRemove = [
            "shimonetaMembers",
            "wordWolfMembers",
            "penaltyGamePlayers",
            "wordWolfUsedTopicIndices",
            "drawingShiritoriMembers",
            "senseGameMembers",
            "senseGameMembers2",
            "senseGameMembers3",
            "senseGameMembers4",
            "senseGamePlayerCount",
            "secretQuestionUserName"
        ]
        
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        self.memberHistory = [:]
    }

    func incrementPlayCount(for gameId: String) {
        if let count = gamePlayCounts[gameId] {
            gamePlayCounts[gameId] = count + 1
        } else {
            gamePlayCounts[gameId] = 1
        }
        
        // 15回プレイした時にレビュー依頼を表示
        if gamePlayCounts[gameId] == 15 && !hasRequestedReview {
            requestReview()
        }
    }
    
    private func requestReview() {
        // レビュー依頼は1回のみ
        hasRequestedReview = true
        
        // メインスレッドで実行
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    func saveMemberHistory(gameId: String, members: [String]) {
        guard !members.isEmpty else { return }
        
        var history = memberHistory[gameId] ?? []
        
        // 重複チェック（完全に同じメンバー構成がある場合は追加しない）
        if !history.contains(members) {
            // 先頭に追加
            history.insert(members, at: 0)
            
            // 最大3件まで保持
            if history.count > 3 {
                history = Array(history.prefix(3))
            }
            
            memberHistory[gameId] = history
        }
    }
    
    func deleteHistory(gameId: String, at index: Int) {
        var history = memberHistory[gameId] ?? []
        if history.indices.contains(index) {
            history.remove(at: index)
            memberHistory[gameId] = history
        }
    }
}
