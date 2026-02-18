//
//  PitchGuessView.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/02.
//

import SwiftUI

struct PitchGuessView: View {
    @StateObject private var viewModel = PitchGuessViewModel()
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.purple.opacity(0.1)
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
                    
                    Text("音階当て")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // 音符またはピアノのイラスト
                    Image(systemName: "music.note")
                        .font(.system(size: 120))
                        .foregroundColor(.purple)
                    
                    Text("流れた音階を当てよう！")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Button {
                        // プレイ回数をインクリメント
                        appViewModel.settingsManager.incrementPlayCount(for: GameType.pitchGuess.id)
                        
                        viewModel.startGame()
                    } label: {
                        Text("スタート")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(Color.purple)
                            .cornerRadius(30)
                    }
                    
                    Spacer()
                }
                // カウントダウン
                else if viewModel.gameState == .countdown {
                    Spacer()
                    
                    Text("\(viewModel.countdownNumber)")
                        .font(.system(size: 120, weight: .bold))
                        .foregroundColor(.purple)
                        .transition(.scale)
                    
                    Spacer()
                }
                // 音再生中と答えを見るボタン
                else if viewModel.gameState == .waitingForAnswer {
                    Spacer()
                    
                    VStack(spacing: 40) {
                        // 音符のアニメーション
                        Image(systemName: viewModel.isPlayingSound ? "speaker.wave.3.fill" : "speaker.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.purple)
                            .symbolEffect(.pulse, isActive: viewModel.isPlayingSound)
                        
                        if viewModel.isPlayingSound {
                            Text("♪ 音を聴いてください ♪")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                        } else {
                            Text("この音は何の音階？")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            VStack(spacing: 15) {
                                Button {
                                    viewModel.playAgainSound()
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("もう一度聴く")
                                    }
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.purple)
                                    .frame(width: 200, height: 50)
                                    .background(Color.purple.opacity(0.1))
                                    .cornerRadius(25)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.purple, lineWidth: 2)
                                    )
                                }
                                
                                Button {
                                    viewModel.showAnswer()
                                } label: {
                                    Text("答えを見る")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 200, height: 60)
                                        .background(Color.blue)
                                        .cornerRadius(30)
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
        .navigationTitle("音階当て")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $viewModel.showAnswerModal) {
            PitchAnswerDialog(
                note: viewModel.currentNote,
                onContinue: {
                    // プレイ回数をインクリメント
                    appViewModel.settingsManager.incrementPlayCount(for: GameType.pitchGuess.id)
                    viewModel.playAgain()
                },
                onBackToSelection: {
                    appViewModel.backToGameSelection()
                }
            )
        }
    }
}

struct PitchAnswerDialog: View {
    @Environment(\.dismiss) var dismiss
    let note: MusicalNote?
    let onContinue: () -> Void
    let onBackToSelection: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Text("正解は...")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                if let note = note {
                    VStack(spacing: 20) {
                        Text(note.rawValue)
                            .font(.system(size: 56, weight: .bold))
                            .foregroundColor(.purple)
                        
                        Image(systemName: "music.note")
                            .font(.system(size: 80))
                            .foregroundColor(.purple)
                        
                        Text("\(String(format: "%.2f", note.frequency)) Hz")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                
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
            .navigationTitle("答え")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
        }
    }
}

#Preview {
    NavigationView {
        PitchGuessView(appViewModel: AppViewModel())
    }
}
