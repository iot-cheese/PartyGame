//
//  WordWolfViewModel.swift
//  PartyGame
//
//  Created by GitHub Copilot on 2026/02/03.
//

import Foundation
import SwiftUI
import AudioToolbox

enum WordWolfGameState {
    case setup
    case inputMembers
    case checkingRole
    case playing
    case result
}

struct WordWolfPlayer: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var isWolf: Bool = false
    var topic: String = ""
}

class WordWolfViewModel: ObservableObject {
    @Published var gameState: WordWolfGameState = .setup
    @Published var players: [WordWolfPlayer] = []
    @Published var timeLimit: Int = 180 // Default 3 minutes
    @Published var wolfCount: Int = 1
    
    @Published var currentCheckingPlayerIndex: Int = 0
    @Published var remainingTime: Int = 0
    @Published var facilitationText: String = ""
    @Published var currentTopic: WordWolfTopic?
    
    // Timer for game countdown
    private var gameTimer: Timer?
    // Timer for facilitation text
    private var facilitationTimer: Timer?
    
    // Persist used topics
    private let usedTopicsKey = "wordWolfUsedTopicIndices"
    
    var usedTopicIndices: Set<Int> {
        get {
            if let data = UserDefaults.standard.data(forKey: usedTopicsKey),
               let indices = try? JSONDecoder().decode(Set<Int>.self, from: data) {
                return indices
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: usedTopicsKey)
            }
        }
    }
    
    // User Input
    @Published var newMemberName: String = ""
    
    func addMember() {
        let trimmed = newMemberName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        players.append(WordWolfPlayer(name: trimmed))
        newMemberName = ""
    }
    
    func removeMember(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
        // Adjust wolf count if needed
        if wolfCount >= players.count && players.count > 0 {
            wolfCount = max(1, players.count / 2) // Simple logic, can remain larger but usually wolves < citizens
        } else if players.count == 0 {
            wolfCount = 1
        }
    }
    
    func deleteMember(player: WordWolfPlayer) {
        if let index = players.firstIndex(of: player) {
            players.remove(at: index)
        }
    }
    
    func prepareGame() {
        guard !players.isEmpty else { return }
        
        // Select topic
        var availableIndices = Set(0..<wordWolfTopics.count).subtracting(usedTopicIndices)
        if availableIndices.isEmpty {
            // Reset if all topics used
            usedTopicIndices = []
            availableIndices = Set(0..<wordWolfTopics.count)
        }
        
        let topicIndex = availableIndices.randomElement() ?? 0
        usedTopicIndices.insert(topicIndex)
        let topic = wordWolfTopics[topicIndex]
        currentTopic = topic
        
        // Assign roles
        // Randomly shuffle players indices to assign wolves
        var indices = Array(0..<players.count)
        indices.shuffle()
        
        // Reset players
        for i in 0..<players.count {
            players[i].isWolf = false
            players[i].topic = topic.citizen
        }
        
        // Determine citizen/wolf assignment for topic
        // Wait, usually the logic is: majority gets topic A, minority gets topic B.
        // We can randomize which is citizen topic and which is wolf topic to make the topic data reusable in reverse way?
        // Actually the data structure `WordWolfTopic` has `citizen` and `wolf`.
        // So just assign them.
        
        // Assign wolves
        // Ensure wolfCount is valid. It should be less than total players.
        let actualWolfCount = min(wolfCount, max(1, players.count - 1))
        
        for i in 0..<actualWolfCount {
            let playerIndex = indices[i]
            players[playerIndex].isWolf = true
            players[playerIndex].topic = topic.wolf
        }
        
        currentCheckingPlayerIndex = 0
        gameState = .checkingRole
    }
    
    func confirmCheckOk() {
        if currentCheckingPlayerIndex < players.count - 1 {
            currentCheckingPlayerIndex += 1
            playSound(named: "check")
        } else {
            // All checked
            startGameSession()
        }
    }
    
    private func startGameSession() {
        remainingTime = timeLimit
        gameState = .playing
        facilitationText = ""
        playSound(named: "start")
        
        startTimers()
    }
    
    private func startTimers() {
        gameTimer?.invalidate()
        facilitationTimer?.invalidate()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.gameTimer?.invalidate()
                self.facilitationTimer?.invalidate()
                // Time up
                self.playSound(named: "timeup")
            }
        }
        
        // Facilitation text frequently
        // User requested "more frequent". Previous was 90s.
        // Let's set it to every 30-45 seconds. Let's say 30 seconds.
        let interval: TimeInterval = 30
        facilitationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.updateFacilitationText()
        }
    }
    
    private func updateFacilitationText() {
        // Logic for text based on remaining time
        // Total time = timeLimit
        // Elapsed = timeLimit - remainingTime
        // Phase: Early (First half), Late (Second half)
        
        let isEarly = Double(remainingTime) > Double(timeLimit) / 2.0
        
        // Add more phrases or keep existing
        let earlyPhrases = [
            "このお題についてどう思う？",
            "このお題、好き？嫌い？",
            "これ、家にある？",
            "最近これを見た？",
            "これに関する思い出はある？",
            "これのイメージは明るい？暗い？",
            "これを買うならいくら出す？",
            "これ、コンビニで買える？"
        ]
        
        let latePhrases = [
            "これの色は何色？",
            "これの大きさはどれくらい？",
            "これを最後にいつ見た？",
            "これの値段は高い？安い？",
            "これは食べられる？",
            "これはどこで買える？",
            "これは子供が好き？",
            "これは重い？",
            "これの形は？",
            "これの素材は？"
        ]
        
        if isEarly {
            facilitationText = earlyPhrases.randomElement() ?? ""
        } else {
            facilitationText = latePhrases.randomElement() ?? ""
        }
        playSound(named: "facilitate")
    }
    
    func stopGame() {
        gameTimer?.invalidate()
        facilitationTimer?.invalidate()
    }
    
    func showResult() {
        stopGame()
        gameState = .result
        playSound(named: "result")
    }
    
    func resetToSetup() {
        stopGame()
        gameState = .setup
        // ready for new game
    }
    
    func playAgain() {
        stopGame()
        // Keep players, new topic
        prepareGame()
    }
    
    // MARK: - Sound Effects
    private func playSound(named soundName: String) {
        guard UserDefaults.standard.bool(forKey: "soundEnabled") else { return }
        switch soundName {
        case "start":
            AudioServicesPlaySystemSound(1005) // Alarm? Or 1103 (Begin video record)
        case "check":
            AudioServicesPlaySystemSound(1104) // Tink
        case "facilitate":
            AudioServicesPlaySystemSound(1003) // Received Message
        case "result":
            AudioServicesPlaySystemSound(1000) // Mail received / standard notification
        case "timeup":
            AudioServicesPlaySystemSound(1005) // Alarm
        default:
            break
        }
    }
}
