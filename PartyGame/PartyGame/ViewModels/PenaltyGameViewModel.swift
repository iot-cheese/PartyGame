//
//  PenaltyGameViewModel.swift
//  PartyGame
//
//  Created by GitHub Copilot on 2026/02/03.
//

import Foundation
import SwiftUI
import AudioToolbox
import AVFoundation

enum PenaltyGameState {
    case setup
    case inputMembers
    case tapToStart
    case revealing
    case result
    case itemGet
}

struct PenaltyPlayer: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var curseStrength: Int = 0
    var itemStrength: Int? = nil
}

class PenaltyGameViewModel: ObservableObject {
    @Published var gameState: PenaltyGameState = .setup
    @Published var players: [PenaltyPlayer] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var penaltyText: String = ""
    @Published var isSafe: Bool = true
    
    // New logic properties
    @Published var consecutiveSafeCount: Int = 0
    @Published var isFlashing: Bool = false
    
    // Item Logic
    @Published var gainedItemStrength: Int? = nil
    @Published var showItemSelector: Bool = false
    
    // Persistence
    private let playersKey = "penaltyGamePlayers"
    
    // User Input
    @Published var newMemberName: String = ""
    
    init() {
        loadPlayers()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    private func loadPlayers() {
        if let data = UserDefaults.standard.data(forKey: playersKey),
           let savedPlayers = try? JSONDecoder().decode([PenaltyPlayer].self, from: data) {
            self.players = savedPlayers
        }
    }
    
    private func savePlayers() {
        if let data = try? JSONEncoder().encode(players) {
            UserDefaults.standard.set(data, forKey: playersKey)
        }
    }
    
    func addMember() {
        let trimmed = newMemberName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        players.append(PenaltyPlayer(name: trimmed))
        newMemberName = ""
        savePlayers()
    }
    
    func removeMember(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
        savePlayers()
    }
    
    func moveMember(from source: IndexSet, to destination: Int) {
        players.move(fromOffsets: source, toOffset: destination)
        savePlayers()
    }
    
    func startGame() {
        guard !players.isEmpty else { return }
        
        // Reset dynamic data
        for i in 0..<players.count {
            players[i].curseStrength = 0
            players[i].itemStrength = nil
        }
        
        consecutiveSafeCount = 0
        // First player is random
        currentPlayerIndex = Int.random(in: 0..<players.count)
        gameState = .tapToStart
    }
    
    func tapScreen() {
        guard gameState == .tapToStart else { return }
        
        gameState = .revealing
        
        // Suspense effect
        playSound(named: "drumroll")
        
        // Delay for determination
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.determineResult()
            
            if self.penaltyText.contains("めっちゃアウト") {
                // Flash effect
                self.triggerFlashEffect {
                    self.showResult(withSound: "thunder")
                }
            } else {
                self.showResult(withSound: self.isSafe ? "safe" : "out")
            }
        }
    }
    
    private func triggerFlashEffect(completion: @escaping () -> Void) {
        let flashDuration = 0.1
        self.isFlashing = true
        playSound(named: "flash")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration) {
            self.isFlashing = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration) {
                self.isFlashing = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration) {
                    self.isFlashing = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration) {
                        completion()
                    }
                }
            }
        }
    }
    
    private func showResult(withSound sound: String) {
        self.gameState = .result
        self.playSound(named: sound)
    }
    
    func checkNextTurn() {
        let currentPlayer = players[currentPlayerIndex]
        let exactMemberOut = penaltyText == "\(currentPlayer.name) アウト"

        if exactMemberOut {
            // Drop rate 50%
            let itemRoll = Double.random(in: 0..<100)
            if itemRoll < 50 {
                 let strengths = [30, 50, 70]
                 let strength = strengths.randomElement() ?? 30
                 players[currentPlayerIndex].itemStrength = strength
                 gainedItemStrength = strength
                 gameState = .itemGet
                 playSound(named: "item_get")
                 return
            }
        }
        proceedToNextPlayer()
    }
    
    func confirmItemGet() {
        gainedItemStrength = nil
        proceedToNextPlayer()
    }
    
    private func proceedToNextPlayer() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        gameState = .tapToStart
        penaltyText = ""
    }
    
    func useItem(targetPlayerId: UUID) {
        guard let itemStrength = players[currentPlayerIndex].itemStrength else { return }
        
        if let targetIndex = players.firstIndex(where: { $0.id == targetPlayerId }) {
            players[targetIndex].curseStrength += itemStrength
            players[currentPlayerIndex].itemStrength = nil // Consume item
            playSound(named: "curse")
        }
    }
    
    func nextTurn() {
        proceedToNextPlayer()
    }
    
    func resetGame() {
        gameState = .setup
        penaltyText = ""
        consecutiveSafeCount = 0
        for i in 0..<players.count {
            players[i].curseStrength = 0
            players[i].itemStrength = nil
        }
    }
    
    private func determineResult() {
        // Force everyone out if safe count reaches 8
        if consecutiveSafeCount >= 8 {
            isSafe = false
            penaltyText = "全員アウト\n(セーフ続きすぎ！)"
            consecutiveSafeCount = 0
            return
        }

        let roll = Double.random(in: 0..<100)
        let currentPlayer = players[currentPlayerIndex]
        let currentName = currentPlayer.name
        
        let curse = Double(currentPlayer.curseStrength)
        let safeThreshold = max(0, 70.0 - curse)
        
        // Consume curse
        if currentPlayer.curseStrength > 0 {
             players[currentPlayerIndex].curseStrength = 0
        }
        
        if roll < safeThreshold {
            isSafe = true
            penaltyText = "セーフ"
            consecutiveSafeCount += 1
        } else if roll < 90.0 {
            // Member Out (70..<90)
            isSafe = false
            penaltyText = "\(currentName) アウト"
            consecutiveSafeCount = 0
        } else if roll < 97.0 {
            // Special Out (90..<97)
            isSafe = false
            let specialOuts = [
                "全員アウト",
                "\(currentName)以外アウト",
                "右の人アウト",
                "左の人アウト",
                "前の人アウト",
                "\(currentName)と右の人アウト",
                "\(currentName)と左の人アウト",
                "\(currentName)と前の人アウト",
                "左右の人アウト"
            ]
            penaltyText = specialOuts.randomElement() ?? "全員アウト"
            consecutiveSafeCount = 0
        } else if roll < 99.0 {
            // Random Other (97..<99)
            isSafe = false
            let others = players.filter { $0.id != currentPlayer.id }
            if let target = others.randomElement() {
                penaltyText = "\(target.name) アウト"
            } else {
                penaltyText = "\(currentName) アウト"
            }
            consecutiveSafeCount = 0
        } else {
            // Super Out (99..<100)
            isSafe = false
            penaltyText = "\(currentName) めっちゃアウト"
            consecutiveSafeCount = 0
        }
    }
    
    private func playSound(named soundName: String) {
        // Ensure sounds obey silent mode
        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }

        switch soundName {
        case "drumroll":
            AudioServicesPlaySystemSound(1057) // PIN Code
        case "safe":
            AudioServicesPlaySystemSound(1001) // Mail Sent
        case "out":
            AudioServicesPlaySystemSound(1005) // Alarm - ORIGINAL
        case "thunder":
            AudioServicesPlaySystemSound(1304) // Alert
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        case "item_get":
            AudioServicesPlaySystemSound(1322) // Tri-tone - ORIGINAL
        case "curse":
             AudioServicesPlaySystemSound(1109) // Shake - ORIGINAL
        case "flash":
             break
        default:
            break
        }
    }
}
