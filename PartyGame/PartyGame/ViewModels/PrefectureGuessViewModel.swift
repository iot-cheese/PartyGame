//
//  PrefectureGuessViewModel.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/01.
//

import Foundation
import Combine
import AudioToolbox

enum GameState {
    case ready
    case countdown
    case showing
    case waitingForAnswer
    case showingAnswer
}

class PrefectureGuessViewModel: ObservableObject {
    @Published var gameState: GameState = .ready
    @Published var countdownNumber: Int = 3
    @Published var currentPrefecture: Prefecture?
    @Published var showAnswerModal: Bool = false
    
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
                self.showRandomPrefecture()
            }
        }
    }
    
    private func showRandomPrefecture() {
        gameState = .showing
        currentPrefecture = Prefecture.all.randomElement()
        playSound(named: "start")
        
        // 1秒後に非表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.gameState = .waitingForAnswer
        }
    }
    
    func showAnswer() {
        gameState = .showingAnswer
        showAnswerModal = true
    }
    
    func reset() {
        gameState = .ready
        currentPrefecture = nil
        showAnswerModal = false
        countdownNumber = 3
        timer?.invalidate()
        timer = nil
    }
    
    func playAgain() {
        showAnswerModal = false
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
        case "start":
            AudioServicesPlaySystemSound(1054) // jbl_begin.caf
        default:
            break
        }
    }
}
