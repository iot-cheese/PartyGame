//
//  TomodachiGameViewModel.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/09.
//

import SwiftUI
import AVFoundation

class TomodachiGameViewModel: ObservableObject {
    enum GameState {
        case idle
        case showingTarget
        case playing
        case finished
    }

    @Published var gameState: GameState = .idle
    @Published var fingerPosition: CGPoint = .zero
    @Published var fingerSize: CGFloat = 50.0
    @Published var gameResult: GameResult?
    @Published var showResultDialog = false
    @Published var message: String = ""
    @Published var currentImageName: String = "friend_finger"
    @Published var randomTargetSize: CGFloat = 200.0
    @Published var lastTapPosition: CGPoint? = nil
    
    // Animation
    private var gameLoopTimer: Timer?
    private var countdownTimer: Timer?
    private var vector: CGPoint = CGPoint(x: 1, y: 1)
    private var screenSize: CGSize = .zero
    
    // Game constants
    // Internal access for View to use in result visualization
    let sizeMargin: CGFloat = 10.0
    let positionMargin: CGFloat = 20.0
    private let topSafeMargin: CGFloat = 120.0
    
    // Logic flags
    private var successOpportunityTimer: Timer?
    private var gameDurationTimer: Timer?
    private var hasTriggeredSuccessWindow = false
    
    // Speech
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    func setScreenSize(_ size: CGSize) {
        if self.screenSize == .zero && size != .zero {
            self.screenSize = size
            fingerPosition = CGPoint(x: size.width / 2, y: size.height / 2)
        } else {
             self.screenSize = size
        }
    }
    
    func startGame() {
        reset()
        
        // Randomize target size
        randomTargetSize = CGFloat.random(in: 150...300)
        
        // Show "Remember this size"
        gameState = .showingTarget
        message = "このサイズを覚えてね"
        fingerSize = randomTargetSize
        currentImageName = "friend_finger"
        
        if screenSize != .zero {
            fingerPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 + 50)
        }
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.beginActiveGame()
        }
    }
    
    private func beginActiveGame() {
        gameState = .playing
        message = "タイミングよく指を合わせよう！"
        fingerSize = 50.0
        
        let angle = Double.random(in: 0...(2 * .pi))
        let speed = 2.0
        vector = CGPoint(x: cos(angle) * speed, y: sin(angle) * speed)
        
        gameLoopTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
        
        gameDurationTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
            self?.finishGame(result: .failure)
        }
    }
    
    private func updateGame() {
        guard gameState == .playing else { return }
        
        var newX = fingerPosition.x + vector.x
        var newY = fingerPosition.y + vector.y
        
        let padding: CGFloat = 20
        let effectiveWidth = screenSize.width > 0 ? screenSize.width : 400
        let effectiveHeight = screenSize.height > 0 ? screenSize.height : 800

        if newX < padding || newX > effectiveWidth - padding {
            vector.x *= -1
            newX = fingerPosition.x + vector.x
        }
        // Use topSafeMargin for Y bounce
        if newY < topSafeMargin || newY > effectiveHeight - padding {
            vector.y *= -1
            newY = fingerPosition.y + vector.y
        }
        
        fingerPosition = CGPoint(x: newX, y: newY)
        
        // Update Size (Faster)
        fingerSize += 0.8
        
        checkSuccessWindow()
    }
    
    private func checkSuccessWindow() {
        let sizeDiff = abs(fingerSize - randomTargetSize)
        
        if sizeDiff <= sizeMargin {
            // In the zone! Start the invisible timer if not started
            if !hasTriggeredSuccessWindow {
                hasTriggeredSuccessWindow = true
                successOpportunityTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                    if self?.gameState == .playing {
                        self?.finishGame(result: .failure)
                    }
                }
            }
        }
    }
    
    func handleTap(at point: CGPoint) {
        guard gameState == .playing else { return }
        
        lastTapPosition = point
        
        let distance = sqrt(pow(point.x - fingerPosition.x, 2) + pow(point.y - fingerPosition.y, 2))
        let sizeDiff = abs(fingerSize - randomTargetSize)
        
        let isPositionOk = distance <= positionMargin
        let isSizeOk = sizeDiff <= sizeMargin
        
        if isPositionOk && isSizeOk {
            finishGame(result: .success)
        } else {
             finishGame(result: .failure)
        }
    }
    
    private func finishGame(result: GameResult) {
        guard gameState == .playing else { return }
        
        gameState = .finished
        stopTimers()
        
        gameResult = result
        if result == .success {
            currentImageName = "friend_finger_success"
            message = "ともだち"
            speak("ともだち")
            
            // Wait 2 seconds for modal (CHANGED FROM 3.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                 self.showResultDialog = true
            }
        } else {
            message = "他人"
            speak("他人")
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.showResultDialog = true
            }
        }
    }
    
    func reset() {
        stopTimers()
        gameState = .idle
        gameResult = nil
        showResultDialog = false
        message = ""
        currentImageName = "friend_finger"
        lastTapPosition = nil
        hasTriggeredSuccessWindow = false
        
        if screenSize != .zero {
            fingerPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        }
    }
    
    private func stopTimers() {
        gameLoopTimer?.invalidate()
        gameLoopTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        successOpportunityTimer?.invalidate()
        successOpportunityTimer = nil
        gameDurationTimer?.invalidate()
        gameDurationTimer = nil
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        speechSynthesizer.speak(utterance)
    }
}
