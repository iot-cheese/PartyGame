//
//  DragonflyStopViewModel.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/11.
//

import Foundation
import Combine
import CoreGraphics

class DragonflyStopViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var gameResult: GameResult? = nil
    @Published var showResultDialog: Bool = false
    
    // 0.0 -> 5.0 (Goal). Represents "Closeness" or "Time held successfully"
    @Published var dragonflyProgress: Double = 0.0
    @Published var totalTimeElapsed: Double = 0.0
    
    @Published var fingerLocation: CGPoint = .zero
    @Published var isTouching: Bool = false
    @Published var showSuccessAnimation: Bool = false
    
    // Challenge Logic
    enum ChallengeType {
        case faster
        
        var text: String {
            switch self {
            case .faster: return "もっとすばやく！"
            }
        }
    }
    @Published var challengeType: ChallengeType? = nil
    private var baselineSpeed: CGFloat = 0.0
    private var challengeTriggerProgress: Double = 2.5
    
    // Audio player logic similar to other view models could be added here
    
    private var points: [(point: CGPoint, time: Date)] = []
    private var timer: Timer?
    private let goalTime: Double = 5.0
    private let timeLimit: Double = 8.0
    
    func startGame() {
        guard !isPlaying else { return }
        reset()
        isPlaying = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateGameLoop()
        }
    }
    
    func stopGame(success: Bool) {
        isPlaying = false
        timer?.invalidate()
        timer = nil
        
        if success {
            showSuccessAnimation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showSuccessAnimation = false
                self.gameResult = .success
                self.showResultDialog = true
            }
        } else {
            gameResult = .failure
            // Wait for animation (1.0s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showResultDialog = true
            }
        }
    }
    
    func reset() {
        isPlaying = false
        gameResult = nil
        showResultDialog = false
        showSuccessAnimation = false
        dragonflyProgress = 0.0
        totalTimeElapsed = 0.0
        points = []
        isTouching = false
        challengeType = nil
        baselineSpeed = 0.0
        challengeTriggerProgress = Double.random(in: 2.5...4.0)
        timer?.invalidate()
        timer = nil
    }
    
    func updateFinger(location: CGPoint) {
        fingerLocation = location
        if isPlaying {
            // Keep only recent points (e.g. last 1 second) for analysis
            points.append((location, Date()))
            points = points.filter { -1.0 * $0.time.timeIntervalSinceNow < 1.0 }
        }
    }
    
    // Logic loop
    private func updateGameLoop() {
        guard isPlaying else { return }
        
        totalTimeElapsed += 0.1
        
        // Check for failure condition (Timeout)
        if totalTimeElapsed >= timeLimit {
            stopGame(success: false)
            return
        }
        
        // Analyze movement
        let analysis = analyzeMovement()
        
        if isTouching && analysis.isCircular {
            var isSpeedCorrect = false
            
            if let challenge = challengeType {
                // Challenge active: check relative to baseline speed
                // Only "faster" challenge exists now
                switch challenge {
                case .faster:
                    // Target: 2.0x speed. Allow > 1.8x (Stricter condition)
                    isSpeedCorrect = analysis.avgSpeed > (baselineSpeed * 1.8)
                }
            } else {
                // Normal mode
                // Relaxed condition: > 30 (was 50).
                isSpeedCorrect = analysis.avgSpeed > 30 && analysis.speedStdDev < (analysis.avgSpeed * 0.5)
                
                // Check if we should trigger challenge
                if dragonflyProgress >= challengeTriggerProgress && isSpeedCorrect {
                    triggerChallenge(currentSpeed: analysis.avgSpeed)
                }
            }
            
            if isSpeedCorrect {
                dragonflyProgress += 0.1
            } else {
                dragonflyProgress = max(0, dragonflyProgress - 0.05)
            }
        } else {
             dragonflyProgress = max(0, dragonflyProgress - 0.05)
        }
        
        // Check for success condition
        if dragonflyProgress >= goalTime {
            stopGame(success: true)
        }
    }
    
    private func triggerChallenge(currentSpeed: CGFloat) {
        baselineSpeed = max(currentSpeed, 60.0)
        challengeType = .faster
    }
    
    private func analyzeMovement() -> (isCircular: Bool, avgSpeed: CGFloat, speedStdDev: CGFloat) {
        // We need enough points to determine
        guard points.count > 10 else { return (false, 0, 0) }
        
        // --- Speed Check ---
        var speeds: [CGFloat] = []
        for i in 0..<(points.count - 1) {
            let p1 = points[i]
            let p2 = points[i+1]
            let dist = sqrt(pow(p2.point.x - p1.point.x, 2) + pow(p2.point.y - p1.point.y, 2))
            let dt = p2.time.timeIntervalSince(p1.time)
            if dt > 0 {
                speeds.append(dist / CGFloat(dt))
            }
        }
        
        guard !speeds.isEmpty else { return (false, 0, 0) }
        
        let avgSpeed = speeds.reduce(0, +) / CGFloat(speeds.count)
        let speedVariance = speeds.map { pow($0 - avgSpeed, 2) }.reduce(0, +) / CGFloat(speeds.count)
        let speedStdDev = sqrt(speedVariance)

        // --- Circularity Check ---
        let pathPoints = points.map { $0.point }
        let sum = pathPoints.reduce(CGPoint.zero) { (CGPoint(x: $0.x + $1.x, y: $0.y + $1.y)) }
        let centroid = CGPoint(x: sum.x / CGFloat(points.count), y: sum.y / CGFloat(points.count))
        
        let distances = pathPoints.map { point -> CGFloat in
            let dx = point.x - centroid.x
            let dy = point.y - centroid.y
            return sqrt(dx*dx + dy*dy)
        }
        
        let avgRadius = distances.reduce(0, +) / CGFloat(distances.count)
        if avgRadius < 20 { return (false, avgSpeed, speedStdDev) } // 半径小さすぎ
        
        let radiusVariance = distances.map { pow($0 - avgRadius, 2) }.reduce(0, +) / CGFloat(distances.count)
        let radiusStdDev = sqrt(radiusVariance)
        
        // Circularity tolerance
        let isCircular = radiusStdDev < (avgRadius * 0.25)
        
        return (isCircular, avgSpeed, speedStdDev)
    }
}
