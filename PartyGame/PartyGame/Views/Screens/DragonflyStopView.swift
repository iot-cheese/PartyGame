//
//  DragonflyStopView.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/11.
//

import SwiftUI

struct DragonflyStopView: View {
    @StateObject private var viewModel = DragonflyStopViewModel()
    @ObservedObject var appViewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 背景（草原）
            Color.green.opacity(0.4)
                .ignoresSafeArea()
            
            // UI Components
            VStack {
                // Header (Back button & Title)
                if !viewModel.isPlaying && viewModel.gameResult == nil && !viewModel.showSuccessAnimation {
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
                    .padding(.top, 44)
                    .padding(.horizontal)
                } else {
                    Spacer().frame(height: 80) // Spacer for top area
                }
                
                if !viewModel.isPlaying && viewModel.gameResult == nil && !viewModel.showSuccessAnimation {
                    // Start Screen Content
                    Spacer()
                    
                    VStack(spacing: 30) {
                        Text("トンボよ止まれ")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Image(systemName: "circles.hexagonpath.fill") // Placeholder for illustration
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .clipShape(Circle())
                        
                        Button {
                            viewModel.startGame()
                        } label: {
                            Text("スタート")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 70)
                                .background(Color.orange)
                                .cornerRadius(35)
                                .shadow(radius: 5)
                        }
                    }
                    
                    Spacer()
                } else {
                    // Game Content
                    VStack {
                        if let challenge = viewModel.challengeType {
                            Text(challenge.text)
                                .font(.system(size: 40, weight: .heavy))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(20)
                                .shadow(radius: 10)
                                .padding(.top, 50)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Text("一定の速度でまん丸の円を描いてね！")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(15)
                        }
                        
                        Spacer()
                    }
                }
            }
            
            // Dragonfly Layer
            // If playing, showing success animation, or failure result (animation)
            if viewModel.isPlaying || viewModel.showSuccessAnimation || viewModel.gameResult == .failure {
                GeometryReader { geo in
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    let startPos = CGPoint(x: geo.size.width + 150, y: -150) // Top-Right offscreen
                    
                    let progress = CGFloat(viewModel.dragonflyProgress / 5.0)
                    let effectiveProgress = (viewModel.showSuccessAnimation || viewModel.gameResult == .success) ? 1.0 : min(max(progress, 0), 1)
                    
                    let currentX = startPos.x + (center.x - startPos.x) * effectiveProgress
                    let currentY = startPos.y + (center.y - startPos.y) * effectiveProgress
                    
                    let scale = 0.2 + (0.8 * effectiveProgress)
                    
                    // On failure (timeout), dragonfly leaves
                    // On success, dragonfly moves down
                    let offsetY = (viewModel.gameResult == .failure) ? -600.0 : (viewModel.showSuccessAnimation ? 150.0 : 0.0)
                    
                    Group {
                         if viewModel.showSuccessAnimation {
                             Image("dragonfly_image_success")
                                 .resizable()
                                 .scaledToFit()
                         } else {
                             Image("dragonfly_image")
                                 .resizable()
                                 .scaledToFit()
                                 // Fallback if asset missing
                                 .overlay(
                                     Image(systemName: "airplane")
                                         .resizable()
                                         .scaledToFit()
                                         .opacity(0.0) // Hidden, strict check difficult in SwiftUI without explicit check
                                 )
                         }
                    }
                    .frame(width: 200, height: 200)
                    .scaleEffect(viewModel.showSuccessAnimation ? 3.0 : scale)
                    .position(x: currentX, y: currentY)
                    .offset(y: offsetY)
                    .animation(.easeInOut(duration: 1.0), value: offsetY)
                    .animation(.linear(duration: 0.1), value: scale)
                    .animation(.linear(duration: 0.1), value: currentX)
                    .animation(.linear(duration: 0.1), value: currentY)
                }
            }
            
            // Gesture Layer for Drawing
            if viewModel.isPlaying {
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                viewModel.isTouching = true
                                viewModel.updateFinger(location: value.location)
                            }
                            .onEnded { _ in
                                viewModel.isTouching = false
                            }
                    )
                
                // Finger Illustration
                if viewModel.isTouching {
                    Image(systemName: "hand.point.up.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                        .position(viewModel.fingerLocation)
                        .offset(x: 10, y: 30) // Offset to look like pointing
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showResultDialog) {
            GameResultDialog(
                result: viewModel.gameResult ?? .failure,
                elapsedTime: nil,
                customMessage: viewModel.gameResult == .success ? "トンボが止まった！" : "逃げちゃった...",
                onContinue: {
                    viewModel.reset()
                },
                onBackToSelection: {
                    appViewModel.backToGameSelection()
                }
            )
        }
    }
}

#Preview {
    DragonflyStopView(appViewModel: AppViewModel())
}
