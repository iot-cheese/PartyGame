//
//  ShimonetaViewModel.swift
//  PartyGame
//
//  Created by GitHub Copilot on 2026/02/05.
//

import SwiftUI
import AudioToolbox

class ShimonetaViewModel: ObservableObject {
    @Published var members: [String] = []
    @Published var activeMembers: [String] = []
    @Published var targetMembers: [String] = []
    
    @Published var gameState: GameState = .setup
    @Published var currentTurnIndex: Int = 0
    @Published var selectedChars: [String] = []
    
    // For result animation
    @Published var displayedChars: [String] = ["?", "?", "?"]
    @Published var isResultRevealed: Bool = false
    
    let forbiddenWords = ["ちんこ", "ちんぽ", "ちんげ", "あなる", "うんこ", "まんげ", "ペニス", "おなら", "にょう", "うんち", "あわび", "ぼっき", "バナナ"]
    let hiddenWords = ["ちんこ", "ちんぽ", "ちんげ", "あなる", "まんげ", "ペニス", "ぼっき"]
    let unavailableWords = ["まんこ"]
    private let savedMembersKey = "shimonetaMembers"
    
    @Published var activeForbiddenWords: [String] = []
    
    // CPU State
    @Published var cpuStateText: String = ""
    
    enum GameState {
        case setup
        case roleAnnouncement
        case turnIntro // "Other members look away"
        case turnSelection // "Choose char"
        case resultStandby // "Show Results" button
        case resultReveal // Revealing chars animation
        case outcome // Safe/Out
    }
    
    init() {
        if let savedMembers = UserDefaults.standard.stringArray(forKey: savedMembersKey) {
            members = savedMembers
        }
    }
    
    func addMember(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            members.append(trimmed)
            saveMembers()
        }
    }
    
    func removeMember(at offsets: IndexSet) {
        members.remove(atOffsets: offsets)
        saveMembers()
    }
    
    private func saveMembers() {
        UserDefaults.standard.set(members, forKey: savedMembersKey)
    }
    
    func startGame() {
        guard members.count >= 2 else { return }
        
        activeMembers = []
        targetMembers = []
        selectedChars = []
        activeForbiddenWords = []
        displayedChars = ["?", "?", "?"]
        isResultRevealed = false
        currentTurnIndex = 0
        
        var availableMembers = members.shuffled()
        
        if members.count == 2 {
            // 2 players: + CPU
            // Select target from the 2 humans
            let target = availableMembers.randomElement()!
            targetMembers = [target]
            
            activeMembers = availableMembers
            activeMembers.append("CPU")
            activeMembers.shuffle()
        } else if members.count == 3 {
             activeMembers = availableMembers
             targetMembers = [availableMembers.randomElement()!]
        } else {
            // > 3
            // First 3 active
            activeMembers = Array(availableMembers.prefix(3))
            // Rest target
            targetMembers = Array(availableMembers.suffix(from: 3))
        }
        
        selectActiveForbiddenWords()
        
        gameState = .roleAnnouncement
    }
    
    private func selectActiveForbiddenWords() {
        // Try to find a pair that doesn't form an unavailable word
        for _ in 0..<50 {
            let candidates = Array(forbiddenWords.shuffled().prefix(2))
            if candidates.count < 2 { break }
            
            if !canFormUnavailableWord(candidates[0], candidates[1]) {
                activeForbiddenWords = candidates
                return
            }
        }
        // Fallback if no safe pair found (unlikely)
        activeForbiddenWords = Array(forbiddenWords.shuffled().prefix(2))
    }
    
    private func canFormUnavailableWord(_ w1: String, _ w2: String) -> Bool {
        let c1 = Array(w1)
        let c2 = Array(w2)
        guard c1.count >= 3, c2.count >= 3 else { return false }
        
        // Check all 8 combinations
        for i in 0...1 {
            for j in 0...1 {
                for k in 0...1 {
                    let char1 = i == 0 ? c1[0] : c2[0]
                    let char2 = j == 0 ? c1[1] : c2[1]
                    let char3 = k == 0 ? c1[2] : c2[2]
                    let formed = String([char1, char2, char3])
                    if unavailableWords.contains(formed) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func startTurns() {
        processTurnStart()
    }
    
    func processTurnStart() {
        let currentPlayer = activeMembers[currentTurnIndex]
        if currentPlayer == "CPU" {
            // Auto play for CPU after a short delay or immediately
            // For UI flow, we might want to show "CPU is choosing..."
            gameState = .turnIntro
            // We can trigger auto-advance in the View onAppear
        } else {
            gameState = .turnIntro
        }
    }
    
    func choicesForCurrentTurn() -> [String] {
        guard currentTurnIndex < 3 else { return [] }
        
        // Use activeForbiddenWords if set, otherwise fallback (e.g. debugging)
        let sourceWords = !activeForbiddenWords.isEmpty ? activeForbiddenWords : Array(forbiddenWords.prefix(2))
        
        let index = currentTurnIndex
        let chars = sourceWords.map { word -> String in
            let charIndex = word.index(word.startIndex, offsetBy: index)
            return String(word[charIndex])
        }
        return chars.shuffled() // Shuffle left/right position
    }
    
    func playCpuTurn() {
        // Reset state text
        cpuStateText = "選択しています..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.cpuStateText = "選択しました"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let choices = self.choicesForCurrentTurn()
                if let choice = choices.randomElement() {
                    self.selectChar(choice)
                }
            }
        }
    }
    
    func selectChar(_ char: String) {
        selectedChars.append(char)
        playSound(named: "select")
        nextTurn()
    }
    
    private func nextTurn() {
        if currentTurnIndex < 2 {
            currentTurnIndex += 1
            processTurnStart()
        } else {
            gameState = .resultStandby
        }
    }
    
    func startResultReveal() {
        gameState = .resultReveal
        // Logic will be handled by View using timer/animation,
        // then eventually setting displayedChars and checking outcome.
    }
    
    func getOutcome() -> Outcome {
        let finalWord = selectedChars.joined()
        let isForbidden = forbiddenWords.contains(finalWord)
        
        // Rules:
        // ForbiddenWord created: Active Players OUT, Target SAFE
        // ForbiddenWord NOT created: Active Players SAFE, Target OUT
        // Wait, spec says:
        // "禁止文字の場合(If Forbidden) ... members OUT"
        // "禁止文字でない場合(If Not Forbidden) ... Target OUT"
        
        if isForbidden {
            return .forbiddenMatch // Active Members OUT
        } else {
            return .forbiddenMismatch // Target OUT
        }
    }
    
    func shouldHideMiddleChar() -> Bool {
        let finalWord = selectedChars.joined()
        return hiddenWords.contains(finalWord)
    }
    
    func displayChar(at index: Int) -> String {
        guard index < selectedChars.count else { return "?" }
        
        // If the word is a hidden word and this is the middle character (index 1), show ◯
        if shouldHideMiddleChar() && index == 1 {
            return "◯"
        }
        
        return selectedChars[index]
    }
    
    func shouldShowTargetMembersInResult() -> Bool {
        // 二人プレイ時、挑戦者がOUTの場合（forbiddenMatch）はお客さんを表示しない
        if members.count == 2 {
            let outcome = getOutcome()
            return outcome != .forbiddenMatch
        }
        // 二人プレイ以外は常に表示
        return true
    }
    
    func getActualActiveMembers() -> [String] {
        // お客さん（targetMembers）を除いた、実際の挑戦者のみを返す
        return activeMembers.filter { member in
            member == "CPU" || !targetMembers.contains(member)
        }
    }
    
    enum Outcome {
        case forbiddenMatch
        case forbiddenMismatch
    }
    
    func playSound(named name: String) {
        guard UserDefaults.standard.bool(forKey: "soundEnabled") else { return }
        
        var soundID: SystemSoundID = 0
        switch name {
        case "start":
            soundID = 1004 // Sent Message (Swoosh) - Stylish Start
        case "select":
            soundID = 1104 // Tock - Crisp Select
        case "drumroll":
            soundID = 1104 // Tock - Used for drum roll effect
        case "safe":
            soundID = 1001 // Mail Sent - Smooth Safe
        case "out":
            soundID = 1304 // Tweet - Distinct Out (or could use 1053 for harsh failure)
        default:
            return
        }
        AudioServicesPlaySystemSound(soundID)
    }
}
