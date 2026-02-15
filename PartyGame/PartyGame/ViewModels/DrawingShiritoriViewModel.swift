//
//  DrawingShiritoriViewModel.swift
//  PartyGame
//
//  Created by GitHub Copilot on 2026/02/15.
//

import Foundation
import SwiftUI

enum DrawingShiritoriGameState {
    case setup
    case inputMembers
    case showingStart  // 最初の文字とメンバー順番を表示
    case showingPrevious  // 前の人の絵を表示
    case playing
    case summary
    case result
}

enum TimeLimit {
    case unlimited
    case fifteen
    case thirty
    case sixty
    
    var seconds: Int? {
        switch self {
        case .unlimited: return nil
        case .fifteen: return 15
        case .thirty: return 30
        case .sixty: return 60
        }
    }
    
    var displayText: String {
        switch self {
        case .unlimited: return "無制限"
        case .fifteen: return "15秒"
        case .thirty: return "30秒"
        case .sixty: return "1分"
        }
    }
}

struct DrawingEntry: Identifiable, Equatable {
    let id = UUID()
    var playerName: String
    var drawing: UIImage?
    var word: String
    var isCorrect: Bool? = nil // nil = not checked yet
}

struct DrawingShiritoriPlayer: Identifiable, Equatable {
    let id = UUID()
    var name: String
}

class DrawingShiritoriViewModel: ObservableObject {
    @Published var gameState: DrawingShiritoriGameState = .setup
    @Published var players: [DrawingShiritoriPlayer] = []
    @Published var turnCount: Int = 3
    @Published var timeLimit: TimeLimit = .thirty
    
    // Member persistence
    @Published var newMemberName: String = ""
    private let savedMembersKey = "drawingShiritoriMembers"
    
    // Game state
    @Published var startingCharacter: String = ""
    @Published var drawings: [DrawingEntry] = []
    @Published var currentTurnIndex: Int = 0
    @Published var currentDrawing: UIImage? = nil
    @Published var currentWord: String = ""
    @Published var remainingTime: Int = 0
    @Published var showingNameInput: Bool = false
    
    private var gameTimer: Timer?
    private var shuffledPlayers: [DrawingShiritoriPlayer] = []
    
    // Japanese hiragana characters for starting character (「を」と「ん」は除外)
    private let hiraganaCharacters = [
        "あ", "い", "う", "え", "お",
        "か", "き", "く", "け", "こ",
        "さ", "し", "す", "せ", "そ",
        "た", "ち", "つ", "て", "と",
        "な", "に", "ぬ", "ね", "の",
        "は", "ひ", "ふ", "へ", "ほ",
        "ま", "み", "む", "め", "も",
        "や", "ゆ", "よ",
        "ら", "り", "る", "れ", "ろ",
        "わ"
    ]
    
    init() {
        if let savedMembers = UserDefaults.standard.stringArray(forKey: savedMembersKey) {
            self.players = savedMembers.map { DrawingShiritoriPlayer(name: $0) }
        }
    }
    
    // MARK: - Member Management
    
    func addMember() {
        let trimmed = newMemberName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            players.append(DrawingShiritoriPlayer(name: trimmed))
            newMemberName = ""
            saveMembers()
        }
    }
    
    func removeMember(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
        saveMembers()
    }
    
    func clearAllMembers() {
        players.removeAll()
        saveMembers()
    }
    
    func saveMembers() {
        let names = players.map { $0.name }
        UserDefaults.standard.set(names, forKey: savedMembersKey)
    }
    
    // MARK: - Game Flow
    
    func startGame() {
        guard !players.isEmpty else { return }
        
        // Shuffle players
        shuffledPlayers = players.shuffled()
        
        // Select random starting character
        startingCharacter = hiraganaCharacters.randomElement() ?? "あ"
        
        // Initialize drawings array
        drawings = []
        currentTurnIndex = 0
        
        // Show start screen first
        gameState = .showingStart
    }
    
    func startPlaying() {
        gameState = .playing
        startTurn()
    }
    
    func startTurn() {
        let totalTurns = shuffledPlayers.count * turnCount
        
        guard currentTurnIndex < totalTurns else {
            // Game finished
            endGame()
            return
        }
        
        currentDrawing = nil
        currentWord = ""
        showingNameInput = false
        
        // 2ターン目以降は前の絵を表示
        if currentTurnIndex > 0 {
            gameState = .showingPrevious
        } else {
            startDrawing()
        }
    }
    
    func startDrawing() {
        gameState = .playing
        
        // Start timer if time limit is set
        if let seconds = timeLimit.seconds {
            remainingTime = seconds
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.timerTick()
            }
        }
    }
    
    func timerTick() {
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            // Time's up, force name input
            gameTimer?.invalidate()
            showingNameInput = true
        }
    }
    
    func completeDrawing() {
        gameTimer?.invalidate()
        showingNameInput = true
    }
    
    func submitWord() {
        let playerIndex = currentTurnIndex % shuffledPlayers.count
        let player = shuffledPlayers[playerIndex]
        
        let entry = DrawingEntry(
            playerName: player.name,
            drawing: currentDrawing,
            word: currentWord.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        drawings.append(entry)
        
        currentTurnIndex += 1
        startTurn()
    }
    
    // 入力された文字がひらがな・カタカナのみかチェック
    func isValidInput(_ text: String) -> Bool {
        let hiraganaKatakanaPattern = "^[ぁ-んァ-ヶー]+$"
        let regex = try? NSRegularExpression(pattern: hiraganaKatakanaPattern)
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex?.firstMatch(in: text, range: range) != nil
    }
    
    // 最初の人は指定の文字で始まるかチェック
    func isValidStartingWord(_ text: String) -> Bool {
        guard !text.isEmpty else { return false }
        if currentTurnIndex == 0 {
            let firstChar = String(text.prefix(1))
            return firstChar == startingCharacter
        }
        return true
    }
    
    // 入力が有効かチェック
    func canSubmitWord() -> Bool {
        let trimmed = currentWord.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && isValidInput(trimmed) && isValidStartingWord(trimmed)
    }
    
    func endGame() {
        gameTimer?.invalidate()
        checkShiritori()
        gameState = .summary
    }
    
    func checkShiritori() {
        guard !drawings.isEmpty else { return }
        
        // First entry should start with the starting character
        if let firstEntry = drawings.first {
            let firstChar = firstEntry.word.prefix(1)
            drawings[0].isCorrect = (firstChar == startingCharacter)
        }
        
        // Check each subsequent entry
        for i in 1..<drawings.count {
            let previousWord = drawings[i - 1].word
            let currentWord = drawings[i].word
            
            guard !previousWord.isEmpty, !currentWord.isEmpty else {
                drawings[i].isCorrect = false
                continue
            }
            
            // Get last character of previous word
            let lastChar = String(previousWord.last!)
            
            // Get first character of current word
            let firstChar = String(currentWord.first!)
            
            // Check if they match
            drawings[i].isCorrect = (lastChar == firstChar)
        }
    }
    
    func showResult() {
        gameState = .result
    }
    
    func resetGame() {
        gameTimer?.invalidate()
        gameState = .setup
        drawings = []
        currentTurnIndex = 0
        currentDrawing = nil
        currentWord = ""
        startingCharacter = ""
        remainingTime = 0
        showingNameInput = false
    }
    
    var isGameSuccessful: Bool {
        return drawings.allSatisfy { $0.isCorrect == true }
    }
    
    var currentPlayer: DrawingShiritoriPlayer? {
        let totalTurns = shuffledPlayers.count * turnCount
        guard currentTurnIndex < totalTurns, !shuffledPlayers.isEmpty else { return nil }
        let playerIndex = currentTurnIndex % shuffledPlayers.count
        return shuffledPlayers[playerIndex]
    }
    
    var previousDrawing: UIImage? {
        return drawings.last?.drawing
    }
    
    var currentTurnNumber: String {
        let totalTurns = shuffledPlayers.count * turnCount
        return "\(currentTurnIndex + 1) / \(totalTurns)"
    }
    
    var playerOrder: [String] {
        return shuffledPlayers.map { $0.name }
    }
    
    var expectedStartingCharacter: String {
        if drawings.isEmpty {
            return startingCharacter
        } else if let lastWord = drawings.last?.word, !lastWord.isEmpty {
            return String(lastWord.last!)
        } else {
            return "?"
        }
    }
}
