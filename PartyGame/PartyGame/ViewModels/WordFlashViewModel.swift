//
//  WordFlashViewModel.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/02.
//

import Foundation
import Combine
import AudioToolbox

class WordFlashViewModel: ObservableObject {
    @Published var gameState: GameState = .ready
    @Published var countdownNumber: Int = 3
    @Published var currentChallenge: WordChallenge?
    @Published var remainingTime: Int = 0
    @Published var showResultModal: Bool = false
    
    private var timer: Timer?
    
    func startGame() {
        gameState = .countdown
        countdownNumber = 3
        startCountdown()
    }
    
    private func startCountdown() {
        playSound(named: "countdown")
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.countdownNumber > 1 {
                self.countdownNumber -= 1
                self.playSound(named: "countdown")
            } else {
                self.timer?.invalidate()
                self.startChallenge()
            }
        }
    }
    
    private func startChallenge() {
        currentChallenge = WordChallenge.generateRandom()
        
        if let challenge = currentChallenge {
            remainingTime = challenge.timeLimit
            gameState = .waitingForAnswer
            startTimeCountdown()
        }
    }
    
    private func startTimeCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.remainingTime > 1 {
                self.remainingTime -= 1
                
                // 残り3秒以下でカウントダウン音
                if self.remainingTime <= 3 {
                    self.playSound(named: "countdown")
                }
            } else {
                self.timer?.invalidate()
                self.timeUp()
            }
        }
    }
    
    private func timeUp() {
        gameState = .showingAnswer
        playSound(named: "timeup")
        showResultModal = true
    }
    
    func reset() {
        gameState = .ready
        currentChallenge = nil
        remainingTime = 0
        showResultModal = false
        countdownNumber = 3
        timer?.invalidate()
        timer = nil
    }
    
    func playAgain() {
        showResultModal = false
        gameState = .countdown
        countdownNumber = 3
        startCountdown()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Sound Effects
    private func playSound(named soundName: String) {
        switch soundName {
        case "countdown":
            AudioServicesPlaySystemSound(1103) // begin_record.caf
        case "timeup":
            AudioServicesPlaySystemSound(1053) // jbl_cancel.caf
        default:
            break
        }
    }
}
