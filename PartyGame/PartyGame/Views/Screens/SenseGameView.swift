//
//  SenseGameView.swift
//  PartyGame
//
//  Created by GitHub Copilot on 2026/02/15.
//

import SwiftUI

struct SenseGameView: View {
    @ObservedObject var appViewModel: AppViewModel
    @StateObject private var viewModel = SenseGameViewModel()
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.12, blue: 0.18).edgesIgnoringSafeArea(.all)
            
            switch viewModel.gameState {
            case .setup:
                SenseGameSetupView(viewModel: viewModel, appViewModel: appViewModel)
            case .selectPlayerCount:
                SenseGamePlayerCountView(viewModel: viewModel)
            case .inputNames:
                SenseGameInputNamesView(viewModel: viewModel)
            case .playing:
                SenseGamePlayingView(viewModel: viewModel)
            case .gameOver:
                SenseGameOverView(viewModel: viewModel, appViewModel: appViewModel)
            }
        }
    }
}

// MARK: - Setup View
struct SenseGameSetupView: View {
    @ObservedObject var viewModel: SenseGameViewModel
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button(action: {
                    appViewModel.selectedGame = nil
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                }
                Spacer()
                Text("感覚ゲーム")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("【ルール】\n各プレイヤーには異なる面積、色の図形が割り当てられます。\nお題に該当する人が自分のエリアをタップしよう！\n間違えた人、時間切れの人がOUT！")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    // Member Input Button
                    Button(action: {
                        viewModel.gameState = .selectPlayerCount
                    }) {
                        HStack {
                            Image(systemName: "person.3.fill")
                            Text(viewModel.players.isEmpty ? "メンバーを入力" : "メンバーを編集")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    
                    if viewModel.canStartGame() {
                        Text("現在の参加者: \(viewModel.selectedPlayerCount)人")
                            .foregroundColor(.gray)
                        // 参加メンバー名を表示
                        Text(viewModel.playerNames.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    
                    // Start Button
                    Button(action: {
                        viewModel.startGame()
                    }) {
                        Text("スタート")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canStartGame() ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.canStartGame())
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Player Count Selection View
struct SenseGamePlayerCountView: View {
    @ObservedObject var viewModel: SenseGameViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            HStack {
                Button(action: {
                    viewModel.gameState = .setup
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
            
            Text("人数を選択")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 20) {
                ForEach(2...4, id: \.self) { count in
                    Button(action: {
                        viewModel.selectPlayerCount(count)
                    }) {
                        Text("\(count)人")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(maxWidth: 300)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Input Names View
struct SenseGameInputNamesView: View {
    @ObservedObject var viewModel: SenseGameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // プレイヤーグリッド（名前入力）
                createInputGrid(geometry: geometry)
                
                // 完了按钮（中央）
                VStack {
                    Spacer()
                    Button(action: {
                        viewModel.completeNameInput()
                    }) {
                        Text("完了")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(viewModel.canStartGame() ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .disabled(!viewModel.canStartGame())
                    
                    Spacer()
                }
                
                // 戻るボタン (左上)
                VStack {
                    HStack {
                        Button(action: {
                            viewModel.gameState = .selectPlayerCount
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private func createInputGrid(geometry: GeometryProxy) -> some View {
        let playerCount = viewModel.selectedPlayerCount
        
        if playerCount == 2 {
            VStack(spacing: 0) {
                inputArea(index: 0, geometry: geometry, height: geometry.size.height / 2, isTop: true, color: Color.red.opacity(0.2))
                inputArea(index: 1, geometry: geometry, height: geometry.size.height / 2, isTop: false, color: Color.blue.opacity(0.2))
            }
        } else if playerCount == 3 {
            // 3人の場合は、CPUを含めて4分割レイアウト（2x2）
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    cpuArea(geometry: geometry, height: geometry.size.height / 2, isTop: true)
                    inputArea(index: 0, geometry: geometry, height: geometry.size.height / 2, isTop: true, color: Color.blue.opacity(0.2))
                }
                HStack(spacing: 0) {
                    inputArea(index: 1, geometry: geometry, height: geometry.size.height / 2, isTop: false, color: Color.green.opacity(0.2))
                    inputArea(index: 2, geometry: geometry, height: geometry.size.height / 2, isTop: false, color: Color.orange.opacity(0.2))
                }
            }
        } else if playerCount == 4 {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    inputArea(index: 0, geometry: geometry, height: geometry.size.height / 2, isTop: true, color: Color.red.opacity(0.2))
                    inputArea(index: 1, geometry: geometry, height: geometry.size.height / 2, isTop: true, color: Color.blue.opacity(0.2))
                }
                HStack(spacing: 0) {
                    inputArea(index: 2, geometry: geometry, height: geometry.size.height / 2, isTop: false, color: Color.green.opacity(0.2))
                    inputArea(index: 3, geometry: geometry, height: geometry.size.height / 2, isTop: false, color: Color.orange.opacity(0.2))
                }
            }
        }
    }
    
    @ViewBuilder
    private func cpuArea(geometry: GeometryProxy, height: CGFloat, isTop: Bool) -> some View {
        ZStack {
            Color.gray.opacity(0.3)
            
            Text("CPU")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .rotationEffect(.degrees(isTop ? 180 : 0))
        }
        .frame(height: height)
        .frame(width: geometry.size.width / 2) // Ensure width is half
        .border(Color.white, width: 2)
    }
    
    @ViewBuilder
    private func inputArea(index: Int, geometry: GeometryProxy, height: CGFloat, isTop: Bool, color: Color) -> some View {
        ZStack {
            color
            
            TextField("名前を入力", text: $viewModel.playerNames[index])
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 200)
                .rotationEffect(.degrees(isTop ? 180 : 0))
        }
        .frame(height: height)
        // For 2 players, width is full. For others, width is half.
        // We can let HStack handle width or be explicit.
        // But for consistent grid in 3/4 players we need half width conceptually.
        // In 2 player mode, it's VStack only, so full width.
        // In 3/4 player mode, it's inside HStack.
        // If I don't set width, it defaults to flexible.
        .border(Color.white, width: 2)
    }
}

// MARK: - Playing View
struct SenseGamePlayingView: View {
    @ObservedObject var viewModel: SenseGameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Player areas
                createPlayerGrid(geometry: geometry)
                
                // Challenge text overlay
                if let challenge = viewModel.currentChallenge {
                    VStack(spacing: 40) {
                        // 上部（反転）
                        HStack(spacing: 20) {
                            if viewModel.showChallenge {
                                Text("\(viewModel.countdown)")
                                    .font(.system(size: 60))
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                    .rotationEffect(.degrees(180))
                                    .frame(width: 80)
                            }
                            
                            Text(challenge.description)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(15)
                                .rotationEffect(.degrees(180))
                        }
                        
                        // 下部（通常）
                        HStack(spacing: 20) {
                            Text(challenge.description)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(15)
                            
                            if viewModel.showChallenge {
                                Text("\(viewModel.countdown)")
                                    .font(.system(size: 60))
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                    .frame(width: 80)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func createPlayerGrid(geometry: GeometryProxy) -> some View {
        let playerCount = viewModel.playerAreas.count
        
        if playerCount == 2 {
            VStack(spacing: 0) {
                playerButton(viewModel.playerAreas[0], geometry: geometry, height: geometry.size.height / 2, isTop: true)
                playerButton(viewModel.playerAreas[1], geometry: geometry, height: geometry.size.height / 2, isTop: false)
            }
        } else if playerCount == 3 {
            VStack(spacing: 0) {
                playerButton(viewModel.playerAreas[0], geometry: geometry, height: geometry.size.height / 2, isTop: true)
                HStack(spacing: 0) {
                    playerButton(viewModel.playerAreas[1], geometry: geometry, height: geometry.size.height / 2, isTop: false)
                    playerButton(viewModel.playerAreas[2], geometry: geometry, height: geometry.size.height / 2, isTop: false)
                }
            }
        } else if playerCount == 4 {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    playerButton(viewModel.playerAreas[0], geometry: geometry, height: geometry.size.height / 2, isTop: true)
                    playerButton(viewModel.playerAreas[1], geometry: geometry, height: geometry.size.height / 2, isTop: true)
                }
                HStack(spacing: 0) {
                    playerButton(viewModel.playerAreas[2], geometry: geometry, height: geometry.size.height / 2, isTop: false)
                    playerButton(viewModel.playerAreas[3], geometry: geometry, height: geometry.size.height / 2, isTop: false)
                }
            }
        }
    }
    
    @ViewBuilder
    private func playerButton(_ playerArea: PlayerArea, geometry: GeometryProxy, height: CGFloat, isTop: Bool) -> some View {
        Button(action: {
            viewModel.playerTapped(playerArea: playerArea)
        }) {
            GeometryReader { buttonGeometry in
                ZStack {
                    Color.white
                    
                    // ベースサイズ（画面幅/高さの60%）
                    let availableWidth = buttonGeometry.size.width * 0.8
                    let availableHeight = buttonGeometry.size.height * 0.8
                    let baseSize = min(availableWidth, availableHeight)
                    
                    // 図形を描画（scaleEffectで面積比を反映）
                    SenseGameShape(path: playerArea.shapePath)
                        .fill(playerArea.color)
                        .scaleEffect(playerArea.scale)
                        .frame(width: baseSize, height: baseSize)
                        .position(x: buttonGeometry.size.width / 2, y: buttonGeometry.size.height / 2)
                    
                    // メンバー名（外側・画面端、透明なグレー）
                    VStack {
                        if isTop {
                            Text(playerArea.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color.gray.opacity(0.4))
                                .rotationEffect(.degrees(180))
                                .padding(.top, 10)
                            Spacer()
                        } else {
                            Spacer()
                            Text(playerArea.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color.gray.opacity(0.4))
                                .padding(.bottom, 10)
                        }
                    }
                }
            }
        }
        .frame(height: height)
        .border(Color.gray, width: 2)
    }
}

// MARK: - Game Over View
struct SenseGameOverView: View {
    @ObservedObject var viewModel: SenseGameViewModel
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("OUT")
                .font(.system(size: 100))
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            if let outPlayer = viewModel.outPlayer {
                Text(outPlayer)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.resetGame()
                }) {
                    Text("ゲームを続ける")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    appViewModel.backToGameSelection()
                }) {
                    Text("別のゲームを選択")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        // Background color is handled by parent ZStack, so we remove this or set clear
        .background(Color.clear)
    }
}

#Preview {
    SenseGameView(appViewModel: AppViewModel())
}
