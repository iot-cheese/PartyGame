//
//  GrandparentGuessViewModel.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/02.
//

import Foundation
import Combine
import AudioToolbox

class GrandparentGuessViewModel: ObservableObject {
    @Published var gameState: GameState = .ready
    @Published var countdownNumber: Int = 3
    @Published var currentImage: GrandparentImage?
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
                self.showRandomImage()
            }
        }
    }
    
    private func showRandomImage() {
        print("🎲 利用可能な画像数: \(GrandparentImage.all.count)")
        currentImage = GrandparentImage.all.randomElement()
        print("🖼️ 選択された画像: \(currentImage?.imageName ?? "nil")")
        gameState = .waitingForAnswer
        playSound(named: "start")
    }
    
    func showAnswer() {
        gameState = .showingAnswer
        showAnswerModal = true
    }
    
    func reset() {
        gameState = .ready
        currentImage = nil
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
