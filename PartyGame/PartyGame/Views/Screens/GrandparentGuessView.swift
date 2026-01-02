//
//  GrandparentGuessView.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/02.
//

import SwiftUI

struct GrandparentGuessView: View {
    @StateObject private var viewModel = GrandparentGuessViewModel()
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.orange.opacity(0.1)
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
                    
                    Text("おじいちゃんorおばあちゃん")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // おじいちゃんとおばあちゃんのイラスト
                    HStack(spacing: 30) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        Image(systemName: "person.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.pink)
                    }
                    
                    Text("おじいちゃん？おばあちゃん？\nどっちかな？")
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
                            .background(Color.orange)
                            .cornerRadius(30)
                    }
                    
                    Spacer()
                }
                // カウントダウン
                else if viewModel.gameState == .countdown {
                    Spacer()
                    
                    Text("\(viewModel.countdownNumber)")
                        .font(.system(size: 120, weight: .bold))
                        .foregroundColor(.orange)
                        .transition(.scale)
                    
                    Spacer()
                }
                // 画像表示と答えを見るボタン
                else if viewModel.gameState == .waitingForAnswer {
                    Spacer()
                    
                    if let image = viewModel.currentImage {
                        VStack(spacing: 30) {
                            Text("おじいちゃん？おばあちゃん？")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            // 画像表示
                            Image(image.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 300)
                                .cornerRadius(20)
                            
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
                    } else {
                        Text("画像が見つかりませんでした")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                }
            }
            .padding()
        }
        .animation(.easeInOut, value: viewModel.gameState)
        .animation(.easeInOut, value: viewModel.countdownNumber)
        .navigationTitle("おじいちゃんorおばあちゃん")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showAnswerModal) {
            GrandparentAnswerDialog(
                image: viewModel.currentImage,
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

struct GrandparentAnswerDialog: View {
    @Environment(\.dismiss) var dismiss
    let image: GrandparentImage?
    let onContinue: () -> Void
    let onBackToSelection: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Text("正解は...")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                if let image = image {
                    Text(image.type.rawValue)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(image.type == .grandpa ? .blue : .pink)
                    
                    // 画像表示
                    Image(image.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 250)
                        .cornerRadius(20)
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
        GrandparentGuessView(appViewModel: AppViewModel())
    }
}
