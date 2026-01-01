//
//  FiveSecondStopViewModel.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import Foundation
import Combine
import AVFoundation
import AudioToolbox

class FiveSecondStopViewModel: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var elapsedTime: Double = 0.0
    @Published var gameResult: GameResult? = nil
    @Published var showResultDialog: Bool = false
    @Published var shouldHideTimer: Bool = false
    
    private var timer: Timer?
    private let targetTime: Double = 5.0
    private let tolerance: Double = 0.20
    private var audioPlayer: AVAudioPlayer?
    
    func startTimer() {
        guard !isRunning else { return }
        
        isRunning = true
        elapsedTime = 0.0
        gameResult = nil
        shouldHideTimer = false
        
        playSound(named: "start")
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 0.01
            
            // 2秒を超えたらタイマーを隠す
            if self.elapsedTime >= 2.0 {
                self.shouldHideTimer = true
            }
        }
    }
    
    func stopTimer() {
        guard isRunning else { return }
        
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        // 5秒±0.20秒以内なら成功
        let difference = abs(elapsedTime - targetTime)
        gameResult = difference <= tolerance ? .success : .failure
        
        // 結果に応じてサウンドを再生
        if gameResult == .success {
            playSound(named: "success")
        } else {
            playSound(named: "failure")
        }
        
        showResultDialog = true
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        elapsedTime = 0.0
        gameResult = nil
        showResultDialog = false
        shouldHideTimer = false
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Sound Effects
    private func playSound(named soundName: String) {
        // システムサウンドを使用
        switch soundName {
        case "start":
            AudioServicesPlaySystemSound(1103) // begin_record.caf
        case "success":
            AudioServicesPlaySystemSound(1054) // jbl_begin.caf
        case "failure":
            AudioServicesPlaySystemSound(1053) // jbl_cancel.caf
        default:
            break
        }
    }
}
