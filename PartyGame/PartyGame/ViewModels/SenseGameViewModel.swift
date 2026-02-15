//
//  SenseGameViewModel.swift
//  PartyGame
//
//  Created by GitHub Copilot on 2026/02/15.
//

import Foundation
import SwiftUI

enum SenseGameState {
    case setup
    case selectPlayerCount
    case inputNames
    case playing
    case gameOver
}

enum GameMode: CaseIterable {
    case area
    case color
    
    var allChallenges: [ChallengeType] {
        switch self {
        case .area:
            return [.largestArea, .smallestArea, .secondLargestArea, .secondSmallestArea]
        case .color:
            return [.brightestColor, .darkestColor, .closestToRed, .closestToBlue, .closestToGreen, .closestToYellow]
        }
    }
}

enum ChallengeType {
    // 面積
    case largestArea
    case smallestArea
    case secondLargestArea
    case secondSmallestArea
    
    // 色
    case brightestColor
    case darkestColor
    case closestToRed
    case closestToBlue
    case closestToGreen
    case closestToYellow
    
    var description: String {
        switch self {
        case .largestArea: return "1番面積が大きい人"
        case .smallestArea: return "1番面積が小さい人"
        case .secondLargestArea: return "2番目に面積が大きい人"
        case .secondSmallestArea: return "2番目に面積が小さい人"
        case .brightestColor: return "1番明るい色の人"
        case .darkestColor: return "1番暗い色の人"
        case .closestToRed: return "1番赤色に近い人"
        case .closestToBlue: return "1番青色に近い人"
        case .closestToGreen: return "1番緑色に近い人"
        case .closestToYellow: return "1番黄色に近い人"
        }
    }
}

struct PlayerArea: Identifiable {
    let id = UUID()
    var name: String
    var area: CGFloat
    var color: Color
    var text: String
    var fontSize: CGFloat
    var shapePath: Path
    var scale: CGFloat
}

struct SenseGamePlayer: Identifiable, Equatable {
    let id = UUID()
    var name: String
}

class SenseGameViewModel: ObservableObject {
    @Published var gameState: SenseGameState = .setup
    @Published var players: [SenseGamePlayer] = []
    @Published var newMemberName: String = ""
    
    @Published var selectedPlayerCount: Int = 0
    @Published var playerNames: [String] = []
    
    @Published var playerAreas: [PlayerArea] = []
    @Published var currentChallenge: ChallengeType?
    @Published var countdown: Int = 5
    @Published var showChallenge: Bool = false
    @Published var outPlayer: String? = nil
    
    private var timer: Timer?
    
    // Member persistence keys
    private let savedMembersKey2 = "senseGameMembers2"
    private let savedMembersKey3 = "senseGameMembers3" // Stores 3 human names
    private let savedMembersKey4 = "senseGameMembers4"
    
    // 日本語のランダムテキスト
    private let randomTexts = [
        "あいうえお", "かきくけこ", "さしすせそ", "たちつてと", "なにぬねの",
        "はひふへほ", "まみむめも", "やゆよ", "らりるれろ", "わをん",
        "がぎぐげご", "ざじずぜぞ", "だぢづでど", "ばびぶべぼ", "ぱぴぷぺぽ",
        "あいう", "かきく", "さしす", "たちつ", "なにぬ",
        "あ", "か", "さ", "た", "な", "は", "ま", "や", "ら", "わ"
    ]
    
    init() {
        // Initialize with empty state, load specific members when count is selected
    }
    
    // MARK: - Member Management
    
    func saveMembers() {
        let names = playerNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        switch selectedPlayerCount {
        case 2:
            UserDefaults.standard.set(names, forKey: savedMembersKey2)
        case 3:
            UserDefaults.standard.set(names, forKey: savedMembersKey3)
        case 4:
            UserDefaults.standard.set(names, forKey: savedMembersKey4)
        default:
            break
        }
    }
    
    func loadMembers(for count: Int) {
        var loadedNames: [String] = []
        
        switch count {
        case 2:
            loadedNames = UserDefaults.standard.stringArray(forKey: savedMembersKey2) ?? []
        case 3:
            loadedNames = UserDefaults.standard.stringArray(forKey: savedMembersKey3) ?? []
        case 4:
            loadedNames = UserDefaults.standard.stringArray(forKey: savedMembersKey4) ?? []
        default:
            break
        }
        
        // Ensure the array has the correct size, filling with empty strings if needed
        playerNames = loadedNames
        while playerNames.count < count {
            playerNames.append("")
        }
        // Trim if too many (shouldn't happen with correct logic but good for safety)
        if playerNames.count > count {
            playerNames = Array(playerNames.prefix(count))
        }
    }
    
    func selectPlayerCount(_ count: Int) {
        selectedPlayerCount = count
        loadMembers(for: count)
        gameState = .inputNames
    }
    
    func canStartGame() -> Bool {
        if gameState == .inputNames {
            return selectedPlayerCount > 0 && playerNames.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }
        return selectedPlayerCount >= 2 && selectedPlayerCount <= 4
    }
    
    func completeNameInput() {
        guard canStartGame() else { return }
        saveMembers()
        
        players = playerNames.map { SenseGamePlayer(name: $0) }
        
        // For 3 players, add a CPU player to make it 4
        if selectedPlayerCount == 3 {
            players.insert(SenseGamePlayer(name: "CPU"), at: 0)
        }
        
        gameState = .setup
    }
    
    // MARK: - Game Flow
    
    func startGame() {
        // For 3 players, we have 4 items in players array (3 humans + 1 CPU)
        if selectedPlayerCount == 3 {
            guard players.count == 4 else { return }
        } else {
            guard players.count == selectedPlayerCount else { return }
        }
        
        gameState = .playing
        setupNewRound()
    }
    
    func setupNewRound() {
        // ランダムなゲームモードとチャレンジを選択
        let mode = GameMode.allCases.randomElement()!
        currentChallenge = mode.allChallenges.randomElement()!
        
        // プレイヤーエリアを生成
        playerAreas = generatePlayerAreas()
        
        // 3秒待ってからカウントダウン開始
        showChallenge = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showChallenge = true
            self.startCountdown()
        }
    }
    
    func generatePlayerAreas() -> [PlayerArea] {
        var areas: [PlayerArea] = []
        
        for player in players {
            // 面積（近い値）
            // Increase base area size significantly
            let baseArea: CGFloat = 150 + CGFloat.random(in: 0...100)
            
            // ランダムな色
            let hue = Double.random(in: 0...1)
            let saturation = Double.random(in: 0.5...1.0)
            let brightness = Double.random(in: 0.3...0.9)
            let color = Color(hue: hue, saturation: saturation, brightness: brightness)
            
            // ランダムなテキストとサイズ
            let text = randomTexts.randomElement()!
            let fontSize: CGFloat = CGFloat.random(in: 20...60)
            
            // ランダムな不規則図形を生成
            let (shapePath, scale) = generateRandomShape(targetArea: baseArea)
            
            areas.append(PlayerArea(
                name: player.name,
                area: baseArea,
                color: color,
                text: text,
                fontSize: fontSize,
                shapePath: shapePath,
                scale: scale
            ))
        }
        
        return areas
    }
    
    // ランダムな不規則図形を生成（0.0〜1.0正規化座標）
    func generateRandomShape(targetArea: CGFloat = 100.0) -> (Path, CGFloat) {
        var path = Path()
        
        let center = CGPoint(x: 0.5, y: 0.5)
        let pointCount = Int.random(in: 5...8) // 角の数
        
        // 各角の位置をランダムに生成（半径0.3〜0.5の範囲）
        var points: [CGPoint] = []
        for i in 0..<pointCount {
            let angle = (2.0 * .pi / CGFloat(pointCount)) * CGFloat(i)
            let randomRadius = CGFloat.random(in: 0.3...0.5)
            let x = center.x + cos(angle) * randomRadius
            let y = center.y + sin(angle) * randomRadius
            points.append(CGPoint(x: x, y: y))
        }
        
        // Pathを作成
        if let firstPoint = points.first {
            path.move(to: firstPoint)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
        
        // スケールを計算（targetAreaに基づく、基準面積100 -> 150 to make shapes larger)
        // We adjusted baseArea, but we also want to make them visually larger on screen
        // by adjusting the scale calculation or the base divisor
        let scale = sqrt(targetArea / 200.0) // Adjusted to prevent overflow with 0.8 baseSize
        
        return (path, scale)
    }
    
    func startCountdown() {
        countdown = 5
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                self.timer?.invalidate()
                self.handleTimeout()
            }
        }
    }
    
    func playerTapped(playerArea: PlayerArea) {
        timer?.invalidate()
        
        guard let challenge = currentChallenge else { return }
        let correctPlayer = findCorrectPlayer(for: challenge)
        
        if playerArea.name == correctPlayer {
            // 正解、次のラウンドへ
            setupNewRound()
        } else {
            // 不正解、ゲームオーバー
            outPlayer = playerArea.name
            gameState = .gameOver
        }
    }
    
    func handleTimeout() {
        guard let challenge = currentChallenge else { return }
        let correctPlayer = findCorrectPlayer(for: challenge)
        outPlayer = correctPlayer
        gameState = .gameOver
    }
    
    func findCorrectPlayer(for challenge: ChallengeType) -> String {
        switch challenge {
        case .largestArea:
            return playerAreas.max(by: { $0.area < $1.area })?.name ?? ""
        case .smallestArea:
            return playerAreas.min(by: { $0.area < $1.area })?.name ?? ""
        case .secondLargestArea:
            let sorted = playerAreas.sorted(by: { $0.area > $1.area })
            return sorted.count > 1 ? sorted[1].name : sorted[0].name
        case .secondSmallestArea:
            let sorted = playerAreas.sorted(by: { $0.area < $1.area })
            return sorted.count > 1 ? sorted[1].name : sorted[0].name
            
        case .brightestColor:
            return playerAreas.max(by: { getBrightness($0.color) < getBrightness($1.color) })?.name ?? ""
        case .darkestColor:
            return playerAreas.min(by: { getBrightness($0.color) < getBrightness($1.color) })?.name ?? ""
        case .closestToRed:
            return playerAreas.min(by: { colorDistance($0.color, to: .red) < colorDistance($1.color, to: .red) })?.name ?? ""
        case .closestToBlue:
            return playerAreas.min(by: { colorDistance($0.color, to: .blue) < colorDistance($1.color, to: .blue) })?.name ?? ""
        case .closestToGreen:
            return playerAreas.min(by: { colorDistance($0.color, to: .green) < colorDistance($1.color, to: .green) })?.name ?? ""
        case .closestToYellow:
            return playerAreas.min(by: { colorDistance($0.color, to: .yellow) < colorDistance($1.color, to: .yellow) })?.name ?? ""
        }
    }
    
    func getBrightness(_ color: Color) -> Double {
        let uiColor = UIColor(color)
        var brightness: CGFloat = 0
        uiColor.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        return Double(brightness)
    }
    
    func colorDistance(_ color1: Color, to color2: Color) -> Double {
        let ui1 = UIColor(color1)
        let ui2 = UIColor(color2)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0
        
        ui1.getRed(&r1, green: &g1, blue: &b1, alpha: nil)
        ui2.getRed(&r2, green: &g2, blue: &b2, alpha: nil)
        
        return sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2))
    }
    
    func resetGame() {
        gameState = .setup
        outPlayer = nil
        timer?.invalidate()
    }
}

struct SenseGameShape: Shape {
    let path: Path
    
    func path(in rect: CGRect) -> Path {
        var scaledPath = path
        // 0.0-1.0の座標系をrectに合わせてスケーリング
        let transform = CGAffineTransform(scaleX: rect.width, y: rect.height)
        scaledPath = scaledPath.applying(transform)
        return scaledPath
    }
}
