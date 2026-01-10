//
//  SamekunCountView.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/09.
//

import SwiftUI

struct SamekunCountView: View {
    @StateObject private var viewModel = SamekunCountViewModel()
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 背景色
                Color.blue.opacity(0.1).ignoresSafeArea()
                
                VStack {
                    if viewModel.gameState == .ready {
                        // Start Screen
                        readyView
                    } else {
                        // Game Screen
                        gameView
                    }
                }
                .frame(width: geo.size.height, height: geo.size.width) // 横幅と高さを入れ替え
            }
            .rotationEffect(.degrees(90)) // 90度回転して横画面化
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $viewModel.showResultModal) {
            SamekunResultDialog(
                count: viewModel.totalSharkCount,
                onContinue: {
                    viewModel.resetGame()
                },
                onBackToSelection: {
                    appViewModel.backToGameSelection()
                }
            ).interactiveDismissDisabled()
        }
    }
    
    // MARK: - Subviews
    
    var readyView: some View {
        VStack(spacing: 0) {
            // Back Button
            HStack {
                Button {
                    appViewModel.backToGameSelection()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("戻る")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                }
                Spacer()
            }
            .padding(.horizontal, 200)
            .padding(.top, 30)
            
            Spacer()
            
            // Landscape Layout: Image on left, Title & Button on right
            HStack(spacing: 40) {
                // Start Screen Image
                Image("samekun_count1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                
                VStack(spacing: 20) {
                    Text("サメくんを数えろ")
                        .font(.system(size: 36, weight: .bold)) // Adjusted size
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Button {
                        viewModel.startGame()
                    } label: {
                        Text("スタート")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 240, height: 60)
                            .background(Color.blue)
                            .cornerRadius(30)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            Color.clear.frame(height: 20) // Bottom spacing
        }
    }
    
    var gameView: some View {
        ZStack {
            VStack {
                // Header
                HStack {
                    // Ghost button for balance or empty space
                    Spacer()
                    
                    if viewModel.gameState == .playing {
                        Text("サメくんを数えてね！")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                    }
                    
                    Spacer()
                }
                .frame(height: 50)
                
                // Timer
                if viewModel.gameState == .playing {
                    ProgressView(value: viewModel.timeRemaining, total: 15.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal)
                        .animation(.linear, value: viewModel.timeRemaining)
                }
                
                Spacer()
                
                // Game Area
                GeometryReader { geometry in
                    ZStack {
                        // Background 2 (Bottom layer)
                        Image("samekun_count_background_image2")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaleEffect(x: 1.0, y: 1.0, anchor: .leading)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()

                        // Sharks
                        ForEach(viewModel.currentSharks) { shark in
                            WalkingSharkView(
                                shark: shark,
                                screenWidth: geometry.size.width,
                                screenHeight: geometry.size.height,
                                spriteIndex: viewModel.spriteIndex
                            )
                        }
                        
                        // Background (Image with transparent center)
                        Image("samekun_count_background_image")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaleEffect(x: 1.01, y: 1.0, anchor: .leading)
                            .allowsHitTesting(false)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .zIndex(100)
                    }
                    .clipped() // Ensure sharks don't show outside the area
                }
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal, 0)
                .padding(.vertical, 10)
                
                Spacer()
            }
            
            // "Finished" Overlay
            if viewModel.gameState == .finished {
                VStack(spacing: 20) {
                    Text("終了！")
                        .font(.system(size: 80, weight: .black)) // Larger text
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                    
                    Button {
                        viewModel.showAnswer()
                    } label: {
                        Text("答えを見る")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 240, height: 70)
                            .background(Color.blue)
                            .cornerRadius(35)
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(100) // Ensure it's on top
            }
        }
    }
}

struct WalkingSharkView: View {
    let shark: SamekunCountViewModel.SharkInstance
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let spriteIndex: Int
    
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var dynamicZIndex: Double = 0
    
    var body: some View {
        let imageName = shark.isDummy ? "samekun_dummy" : "samekun_count\(spriteIndex)"
        let initialY = screenHeight * 0.55 // Higher position
        
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(height: 180) // 1.5x (120*1.5=180)
            .position(x: -120, y: initialY) // Initial position
            .offset(x: offsetX, y: offsetY)
            .zIndex(dynamicZIndex)
            .onAppear {
                // Initial zIndex: Dummy (1) or Normal (0)
                dynamicZIndex = shark.isDummy ? 1.0 : 0.0
                
                if shark.shouldGoUp {
                    // Move to right edge, then go up
                    // 1. Move horizontally to near right edge
                    let stopX = screenWidth - 40 // Closer to edge
                    // Calculate offset needed. Start X is -120.
                    let targetOffsetX = stopX - (-120)
                    
                    withAnimation(.linear(duration: shark.duration * 0.7)) {
                        offsetX = targetOffsetX
                    }
                    
                    // 2. Then move vertically UP
                    // "Stop closer to top edge".
                    // Image height 180 -> half 90. Top edge at y=0 -> center at y=90.
                    let targetY = 90.0 // Image touches top edge
                    let targetOffsetY = targetY - initialY
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + (shark.duration * 0.7)) {
                        // Switch zIndex just before going up to appear in front of other sharks
                        dynamicZIndex = 50.0
                        
                        withAnimation(.easeInOut(duration: shark.duration * 0.3)) {
                            offsetY = targetOffsetY
                        }
                    }
                } else {
                    // Normal horizontal pass
                    withAnimation(.linear(duration: shark.duration)) {
                        offsetX = screenWidth + 240 + 120 // Move well off-screen
                    }
                }
            }
    }
}

// Result Modal
struct SamekunResultDialog: View {
    @Environment(\.dismiss) var dismiss
    let count: Int
    let onContinue: () -> Void
    let onBackToSelection: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("正解は...")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("\(count)匹")
                        .font(.system(size: 70, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 12) {
                        HStack {
                            Spacer()
                            
                            Button {
                                dismiss()
                                onContinue()
                            } label: {
                                Text("ゲームを続ける")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 260, height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(15)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                dismiss()
                                onBackToSelection()
                            } label: {
                                Text("別のゲームを選択")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                    .frame(width: 260, height: 50)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(15)
                            }
                            
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
            .frame(width: geo.size.height, height: geo.size.width)
            .rotationEffect(.degrees(90))
            .position(x: geo.size.width/2, y: geo.size.height/2)
        }
        .ignoresSafeArea()
    }
}

