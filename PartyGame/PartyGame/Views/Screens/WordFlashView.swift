//
//  WordFlashView.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/02.
//

import SwiftUI

struct WordFlashView: View {
    @StateObject private var viewModel = WordFlashViewModel()
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.cyan.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // 初期画面
                if viewModel.gameState == .ready {
                    // 戻るボタン
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
                    
                    Text("単語ひらめき")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // イラスト
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.3), radius: 20)
                    
                    Spacer()
                    
                    Button {
                        viewModel.startGame()
                    } label: {
                        Text("スタート")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(Color.cyan)
                            .cornerRadius(30)
                    }
                    
                    // ルール説明
                    VStack(alignment: .leading, spacing: 10) {
                        Text("【ルール】")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text("出題されたひらがな1文字で始まる単語を考えよう")
                            }
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text("指定された文字数の単語を答えてね")
                            }
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text("4文字以内は5秒、5文字以上は10秒の制限時間")
                            }
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text("時間内に単語が思い浮かばなかったら負け！")
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)
                    
                    Spacer()
                }
                // カウントダウン
                else if viewModel.gameState == .countdown {
                    Spacer()
                    
                    Text("\(viewModel.countdownNumber)")
                        .font(.system(size: 120, weight: .bold))
                        .foregroundColor(.cyan)
                        .transition(.scale)
                    
                    Spacer()
                }
                // チャレンジ表示
                else if viewModel.gameState == .waitingForAnswer {
                    Spacer()
                    
                    if let challenge = viewModel.currentChallenge {
                        VStack(spacing: 40) {
                            // 残り時間
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(viewModel.remainingTime) / CGFloat(challenge.timeLimit))
                                    .stroke(
                                        viewModel.remainingTime <= 3 ? Color.red : Color.cyan,
                                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                                    )
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 1.0), value: viewModel.remainingTime)
                                
                                Text("\(viewModel.remainingTime)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(viewModel.remainingTime <= 3 ? .red : .cyan)
                            }
                            
                            VStack(spacing: 20) {
                                // お題
                                VStack(spacing: 10) {
                                    Text("この文字で始まる単語は？")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(challenge.hiragana)
                                        .font(.system(size: 80, weight: .bold))
                                        .foregroundColor(.cyan)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.white)
                                                .shadow(color: .cyan.opacity(0.3), radius: 10)
                                        )
                                }
                                
                                // 文字数
                                VStack(spacing: 5) {
                                    Text("文字数")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(challenge.wordCount)文字")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding()
        }
        .animation(.easeInOut, value: viewModel.gameState)
        .animation(.easeInOut, value: viewModel.countdownNumber)
        .navigationTitle("単語ひらめき")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showResultModal) {
            WordFlashResultDialog(
                onContinue: {
                    viewModel.playAgain()
                },
                onBackToSelection: {
                    appViewModel.backToGameSelection()
                }
            )
        }
    }
}

struct WordFlashResultDialog: View {
    @Environment(\.dismiss) var dismiss
    let onContinue: () -> Void
    let onBackToSelection: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // 終了アイコン
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 100))
                    .foregroundColor(.orange)
                
                Text("時間切れ！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("単語は思いつきましたか？")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
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
            .navigationTitle("終了")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationView {
        WordFlashView(appViewModel: AppViewModel())
    }
}
