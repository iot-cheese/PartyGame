//
//  PitchGuessViewModel.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/02.
//

import Foundation
import Combine
import AVFoundation
import AudioToolbox

class PitchGuessViewModel: ObservableObject {
    @Published var gameState: GameState = .ready
    @Published var countdownNumber: Int = 3
    @Published var currentNote: MusicalNote?
    @Published var showAnswerModal: Bool = false
    @Published var isPlayingSound: Bool = false
    
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    
    func startGame() {
        gameState = .countdown
        countdownNumber = 3
        startCountdown()
    }
    
    private func startCountdown() {
        playSystemSound(named: "countdown")
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.countdownNumber > 1 {
                self.countdownNumber -= 1
                self.playSystemSound(named: "countdown")
            } else {
                self.timer?.invalidate()
                self.playRandomNote()
            }
        }
    }
    
    private func playRandomNote() {
        currentNote = MusicalNote.allCases.randomElement()
        gameState = .waitingForAnswer
        
        if let note = currentNote {
            playTone(frequency: note.frequency, duration: 1.0)
        }
    }
    
    func playAgainSound() {
        // 同じ音を再度再生
        gameState = .countdown
        countdownNumber = 3
        
        playSystemSound(named: "countdown")
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.countdownNumber > 1 {
                self.countdownNumber -= 1
                self.playSystemSound(named: "countdown")
            } else {
                self.timer?.invalidate()
                self.gameState = .waitingForAnswer
                
                // 同じ音を再生
                if let note = self.currentNote {
                    self.playTone(frequency: note.frequency, duration: 1.0)
                }
            }
        }
    }
    
    private func playTone(frequency: Double, duration: Double) {
        isPlayingSound = true
        
        // 既存のオーディオエンジンを停止
        stopAudio()
        
        // AVAudioEngineを使用して音を生成
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        
        // 固定フォーマット: ステレオ、48kHz（iOSのデフォルト）
        let sampleRate = 48000.0
        let channels: AVAudioChannelCount = 2
        
        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: channels
        ) else {
            isPlayingSound = false
            return
        }
        
        let length = Int(sampleRate * duration)
        
        // バッファを作成
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(length)
        ) else {
            isPlayingSound = false
            return
        }
        
        buffer.frameLength = AVAudioFrameCount(length)
        
        // サイン波を生成（全チャンネルに同じデータを書き込む）
        guard let channelData = buffer.floatChannelData else {
            isPlayingSound = false
            return
        }
        
        for channel in 0..<Int(channels) {
            let data = UnsafeMutableBufferPointer(start: channelData[channel], count: length)
            
            for frame in 0..<length {
                let value = sin(2.0 * .pi * frequency * Double(frame) / sampleRate)
                // エンベロープ（フェードアウト）を適用
                let fadeOutStart = length - 10000
                let envelope: Double
                if frame < fadeOutStart {
                    envelope = 1.0
                } else {
                    envelope = Double(length - frame) / 10000.0
                }
                data[frame] = Float(value * envelope * 0.3)
            }
        }
        
        // ノードをエンジンに接続（同じフォーマットを使用）
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
            player.scheduleBuffer(buffer) { [weak self] in
                DispatchQueue.main.async {
                    self?.isPlayingSound = false
                }
            }
            player.play()
            
            // エンジンとプレイヤーを保持
            self.audioEngine = engine
            self.playerNode = player
        } catch {
            print("オーディオエンジンの起動に失敗: \(error)")
            isPlayingSound = false
        }
    }
    
    func showAnswer() {
        gameState = .showingAnswer
        showAnswerModal = true
    }
    
    func reset() {
        gameState = .ready
        currentNote = nil
        showAnswerModal = false
        countdownNumber = 3
        timer?.invalidate()
        timer = nil
        stopAudio()
    }
    
    func playAgain() {
        showAnswerModal = false
        gameState = .countdown
        countdownNumber = 3
        startCountdown()
    }
    
    private func stopAudio() {
        playerNode?.stop()
        audioEngine?.stop()
        audioPlayer?.stop()
        audioEngine = nil
        playerNode = nil
        isPlayingSound = false
    }
    
    deinit {
        timer?.invalidate()
        stopAudio()
    }
    
    // MARK: - Sound Effects
    private func playSystemSound(named soundName: String) {
        switch soundName {
        case "countdown":
            AudioServicesPlaySystemSound(1103)
        default:
            break
        }
    }
}
