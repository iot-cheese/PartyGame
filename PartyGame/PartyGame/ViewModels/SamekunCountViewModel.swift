//
//  SamekunCountViewModel.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/09.
//

import Foundation
import Combine

class SamekunCountViewModel: ObservableObject {
    enum GameState {
        case ready
        case playing
        case finished // Time up, waiting for user to click "See Answer"
        case showingResult // Showing the modal
    }
    
    struct SharkInstance: Identifiable {
        let id = UUID()
        let duration: Double // Time to cross the screen
        let shouldGoUp: Bool // Vertical movement flag
        let isDummy: Bool // If true, it is a dummy shark (no count, separate image)
    }

    @Published var gameState: GameState = .ready
    @Published var timeRemaining: Double = 15.0
    @Published var currentSharks: [SharkInstance] = []
    @Published var totalSharkCount: Int = 0
    @Published var showResultModal: Bool = false
    @Published var spriteIndex: Int = 1
    
    private var gameTimer: Timer?
    private var spawnTimer: Timer?
    private var spriteTimer: Timer?
    private let gameDuration: Double = 15.0
    
    // Limits for special sharks
    // private var specialSharkCount: Int = 0 // Removed
    // private var maxSpecialSharks: Int = 0 // Removed
    private var sharkQueue: [SharkInstance] = [] // Queue for sharks to spawn
    
    func startGame() {
        resetGame()
        gameState = .playing
        
        prepareSharkQueue()
        
        // Start Countdown Timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 0.1
            } else {
                self.finishGame()
            }
        }
        
        // Start Sprite Timer
        spriteTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.spriteIndex = (self.spriteIndex == 1) ? 2 : 1
        }
        
        // Start Spawning Logic
        scheduleNextSpawn()
    }
    
    func resetGame() {
        gameState = .ready
        timeRemaining = gameDuration
        currentSharks = []
        totalSharkCount = 0
        sharkQueue = []
        showResultModal = false
        spriteIndex = 1
        
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        spriteTimer?.invalidate()
    }
    
    func showAnswer() {
        gameState = .showingResult
        showResultModal = true
    }
    
    private func finishGame() {
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        spriteTimer?.invalidate()
        
        timeRemaining = 0
        gameState = .finished
    }
    
    private func prepareSharkQueue() {
        sharkQueue = []
        
        // 1. Determine Correct Count (9 to 15)
        let correctCount = Int.random(in: 12...18)
        
        // 2. Determine Dummy Count (2x Correct Count)
        let dummyCount = Int.random(in: 25...30)
        
        // 3. Determine Up Count (0 to 6)
        let upCount = Int.random(in: 2...6)
        
        // Add Correct Sharks (No Up, No Dummy)
        for _ in 0..<correctCount {
            sharkQueue.append(SharkInstance(duration: randomDuration(), shouldGoUp: false, isDummy: false))
        }
        
        // Add Dummy Sharks (No Up, Is Dummy)
        for _ in 0..<dummyCount {
            sharkQueue.append(SharkInstance(duration: randomDuration(), shouldGoUp: false, isDummy: true))
        }
        
        // Add Up Sharks (Is Up, Dummy is random)
        for _ in 0..<upCount {
            let isDummy = Bool.random()
            sharkQueue.append(SharkInstance(duration: randomDuration(), shouldGoUp: true, isDummy: isDummy))
        }
        
        // Shuffle the queue
        sharkQueue.shuffle()
    }
    
    private func randomDuration() -> Double {
        // Randomly assign speed
        if Double.random(in: 0...1) < 0.5 {
            return Double.random(in: 4.0...6.0) // Slow
        } else {
            return Double.random(in: 1.5...3.0) // Fast
        }
    }
    
    private func scheduleNextSpawn() {
        guard gameState == .playing, !sharkQueue.isEmpty else { return }
        
        // Calculate interval to distribute all sharks within a target duration (e.g. 13 seconds)
        // to ensure they all appear before time is up.
        let targetSpawnDuration = 13.0
        let remainingSharks = Double(sharkQueue.count)
        
        // Base interval
        let baseInterval = targetSpawnDuration / (remainingSharks + 5) // +5 as buffer
        
        // Add some randomness
        let nextInterval = max(0.1, baseInterval * Double.random(in: 0.5...1.5))
        
        spawnTimer = Timer.scheduledTimer(withTimeInterval: nextInterval, repeats: false) { [weak self] _ in
            self?.spawnShark()
            self?.scheduleNextSpawn()
        }
    }
    
    private func spawnShark() {
        guard gameState == .playing else { return }
        guard !sharkQueue.isEmpty else { return }
        
        let shark = sharkQueue.removeFirst()
        currentSharks.append(shark)
        
        // Only count sharks that walk through normally AND are not dummies
        if !shark.shouldGoUp && !shark.isDummy {
            totalSharkCount += 1
        }
    }
    
    deinit {
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        spriteTimer?.invalidate()
    }
}
