//
//  TomodachiGameView.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/09.
//

import SwiftUI

struct TomodachiGameView: View {
    @StateObject private var viewModel = TomodachiGameViewModel()
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Tap Area
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                viewModel.handleTap(at: value.location)
                            }
                    )
                
                // Active Game Elements (Showing Target OR Playing OR Finished loop)
                if viewModel.gameState == .showingTarget || viewModel.gameState == .playing || viewModel.gameState == .finished {
                     
                     // Message at top
                     VStack {
                        Text(viewModel.message)
                            .font(.headline)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                        Spacer()
                     }
                     .padding(.top, 50)
                     .zIndex(10)

                     // Finger Image
                     Image(viewModel.currentImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: viewModel.fingerSize, height: viewModel.fingerSize)
                        .position(viewModel.fingerPosition)
                        .allowsHitTesting(false)
                        // Only animate linear movement if playing to avoid jumps during setup
                        .animation(viewModel.gameState == .playing ? .linear(duration: 0.016) : nil, value: viewModel.fingerPosition)
                }
                
                // Pre-game UI (Idle)
                if viewModel.gameState == .idle {
                    VStack(spacing: 40) {
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
                        
                        Text("ともだちゲーム")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            
                        // Start screen image as requested
                        Image("friend_finger_start")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                        
                        Text("タイミングよく指と指を合わせよう！\n宇宙人と心を通わせるんだ！")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            
                        Button {
                            viewModel.startGame()
                        } label: {
                            Text("スタート")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 200, height: 60)
                                .background(Color.green)
                                .cornerRadius(30)
                        }
                        
                        
                     }
                     .padding()
                }
            }
            .onAppear {
                viewModel.setScreenSize(geometry.size)
            }
            // Fix deprecated onChange
            .onChange(of: geometry.size) { _, newSize in
                 viewModel.setScreenSize(newSize)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showResultDialog) {
            TomodachiResultDialog(
                result: viewModel.gameResult ?? .failure,
                message: viewModel.message,
                tapPosition: viewModel.lastTapPosition,
                centerPosition: viewModel.fingerPosition,
                validRadius: viewModel.positionMargin,
                targetSize: viewModel.randomTargetSize,
                actualSize: viewModel.fingerSize,
                sizeMargin: viewModel.sizeMargin,
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

struct TomodachiResultDialog: View {
    let result: GameResult
    let message: String
    let tapPosition: CGPoint?
    let centerPosition: CGPoint
    let validRadius: CGFloat
    let targetSize: CGFloat
    let actualSize: CGFloat
    let sizeMargin: CGFloat
    let onContinue: () -> Void
    let onBackToSelection: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
             ScrollView {
                 VStack(spacing: 20) {
                     
                     // 結果テキスト
                     Text(message)
                         .font(.largeTitle)
                         .fontWeight(.bold)
                         .padding(.top)
                     
                     if tapPosition == nil {
                         Text("時間切れ！")
                             .font(.title2)
                             .foregroundColor(.red)
                             .fontWeight(.bold)
                     }
                     
                     // 1. 位置判定エリア
                     VStack(alignment: .leading, spacing: 5) {
                         Text("位置のズレ")
                             .font(.headline)
                             .foregroundColor(.secondary)
                             .padding(.leading)
                         
                         ZStack {
                             // 判定円 (成功範囲)
                             Circle()
                                 .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                 .frame(width: validRadius * 2, height: validRadius * 2)
                                 
                             // 中心点（指の中心）
                             Circle()
                                 .fill(Color.gray)
                                 .frame(width: 8, height: 8)
                             
                             // 中心点ラベル
                             Text("中心")
                                 .font(.caption2)
                                 .foregroundColor(.gray)
                                 .offset(y: 15)
                                 
                             // タップ位置
                             if let tap = tapPosition {
                                  let dx = tap.x - centerPosition.x
                                  let dy = tap.y - centerPosition.y
                                  let dist = sqrt(dx*dx + dy*dy)
                                  let isPosSuccess = dist <= validRadius
                                  
                                  Circle()
                                     .fill(isPosSuccess ? Color.green : Color.red)
                                     .frame(width: 20, height: 20)
                                     .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                     .offset(x: dx, y: dy)
                                     
                                  Text(String(format: "%.0fpx", dist))
                                     .font(.caption2)
                                     .foregroundColor(isPosSuccess ? .green : .red)
                                     .offset(x: dx, y: dy + 20)
                             }
                         }
                         .frame(height: 200)
                         .frame(maxWidth: .infinity)
                         .background(Color.gray.opacity(0.05))
                         .cornerRadius(20)
                         .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                         )
                     }
                     .padding(.horizontal)
                     
                     // 2. サイズ判定エリア
                     VStack(alignment: .leading, spacing: 5) {
                         Text("サイズのズレ (目標: \(Int(targetSize))px)")
                             .font(.headline)
                             .foregroundColor(.secondary)
                             .padding(.leading)
                         
                         HStack(spacing: 20) {
                             // サイズ可視化
                             ZStack {
                                 // 目標サイズ (点線)
                                 Circle()
                                     .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                     .foregroundColor(.blue)
                                     .frame(width: targetSize * 0.6, height: targetSize * 0.6)
                                 
                                 // 実際のサイズ
                                 let actualScaled = actualSize * 0.6
                                 let diff = abs(actualSize - targetSize)
                                 let isSizeSuccess = diff <= sizeMargin
                                 
                                 Circle()
                                     .stroke(isSizeSuccess ? Color.green : Color.red, lineWidth: 3)
                                     .frame(width: actualScaled, height: actualScaled)
                                     
                                 if actualSize > 0 {
                                     Text(isSizeSuccess ? "OK" : (actualSize > targetSize ? "大きい" : "小さい"))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(isSizeSuccess ? .green : .red)
                                        .padding(4)
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(5)
                                 }
                             }
                             .frame(width: 180, height: 180)
                             .background(Color.gray.opacity(0.05))
                             .cornerRadius(20)
                             
                             // 数値情報
                             VStack(alignment: .leading, spacing: 10) {
                                 VStack(alignment: .leading) {
                                     Text("あなたの")
                                         .font(.caption)
                                         .foregroundColor(.secondary)
                                     Text("\(Int(actualSize))px")
                                         .font(.title3)
                                         .bold()
                                 }
                                 
                                 VStack(alignment: .leading) {
                                     Text("誤差")
                                         .font(.caption)
                                         .foregroundColor(.secondary)
                                     let diff = actualSize - targetSize
                                     let sign = diff > 0 ? "+" : ""
                                     Text("\(sign)\(Int(diff))px")
                                         .font(.title3)
                                         .bold()
                                         .foregroundColor(abs(diff) <= sizeMargin ? .green : .red)
                                 }
                                 
                                 VStack(alignment: .leading) {
                                     Text("許容範囲")
                                         .font(.caption)
                                         .foregroundColor(.secondary)
                                     Text("±\(Int(sizeMargin))px")
                                         .font(.caption)
                                 }
                             }
                             Spacer()
                         }
                     }
                     .padding(.horizontal)
                     
                     Spacer()
                         .frame(height: 20)
                     
                     // ボタン
                     VStack(spacing: 15) {
                         Button {
                             dismiss()
                             onContinue()
                         } label: {
                             Text("ゲームを続ける")
                                 .font(.title3)
                                 .fontWeight(.semibold)
                                 .foregroundColor(.white)
                                 .frame(maxWidth: .infinity)
                                 .frame(height: 55)
                                 .background(Color.blue)
                                 .cornerRadius(15)
                         }
                         
                         Button {
                             dismiss()
                             onBackToSelection()
                        } label: {
                            Text("別のゲームを選択")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("結果")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
        }
    }
}


#Preview {
    NavigationView {
        TomodachiGameView(appViewModel: AppViewModel())
    }
}
