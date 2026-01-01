//
//  PrefectureGuessView.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/01.
//

import SwiftUI

struct PrefectureGuessView: View {
    @StateObject private var viewModel = PrefectureGuessViewModel()
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.1)
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
                    
                    Text("都道府県当て")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // 日本地図のイラスト
                    Image(systemName: "map")
                        .font(.system(size: 120))
                        .foregroundColor(.green)
                    
                    Text("一瞬表示される都道府県の形を\n覚えよう！")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Button {
                        viewModel.startGame()
                    } label: {
                        Text("スタート")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(Color.green)
                            .cornerRadius(30)
                    }
                    
                    Spacer()
                }
                // カウントダウン
                else if viewModel.gameState == .countdown {
                    Spacer()
                    
                    Text("\(viewModel.countdownNumber)")
                        .font(.system(size: 120, weight: .bold))
                        .foregroundColor(.green)
                        .transition(.scale)
                    
                    Spacer()
                }
                // 都道府県表示
                else if viewModel.gameState == .showing {
                    Spacer()
                    
                    if let prefecture = viewModel.currentPrefecture {
                        VStack(spacing: 20) {
                            Text("この都道府県は？")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            // プレースホルダー画像（後で実際の画像に置き換え）
                            Image(systemName: "map.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 250, height: 250)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                }
                // 答えを見るボタン表示
                else if viewModel.gameState == .waitingForAnswer {
                    Spacer()
                    
                    Text("覚えましたか？")
                        .font(.title)
                        .fontWeight(.bold)
                    
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
                    
                    Spacer()
                }
            }
            .padding()
        }
        .animation(.easeInOut, value: viewModel.gameState)
        .animation(.easeInOut, value: viewModel.countdownNumber)
        .navigationTitle("都道府県当て")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showAnswerModal) {
            PrefectureAnswerDialog(
                prefecture: viewModel.currentPrefecture,
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

struct PrefectureAnswerDialog: View {
    @Environment(\.dismiss) var dismiss
    let prefecture: Prefecture?
    let onContinue: () -> Void
    let onBackToSelection: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Text("正解は...")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                if let prefecture = prefecture {
                    Text(prefecture.name)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.green)
                    
                    // 都道府県の画像（存在する場合）
                    if UIImage(named: prefecture.imageName) != nil {
                        Image(prefecture.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                    } else {
                        // プレースホルダー画像
                        Image(systemName: "map.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .foregroundColor(.green)
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
        }
    }
}

#Preview {
    NavigationView {
        PrefectureGuessView(appViewModel: AppViewModel())
    }
}
