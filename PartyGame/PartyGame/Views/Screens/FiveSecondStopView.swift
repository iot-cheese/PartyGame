//
//  FiveSecondStopView.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import SwiftUI

struct FiveSecondStopView: View {
    @StateObject private var viewModel = FiveSecondStopViewModel()
    @ObservedObject var appViewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // 戻るボタン（左上、スタート前のみ）
                if !viewModel.isRunning && viewModel.gameResult == nil {
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
                } else {
                    Spacer()
                        .frame(height: 44)
                }
                
                Text("5秒ストップ")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("5秒ぴったりでストップしよう！")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // タイマー表示（2秒を超えたら隠す、結果が出たら再表示）
                if viewModel.gameResult != nil {
                    // 結果が出たら秒数を表示
                    Text(String(format: "%.2f秒", viewModel.elapsedTime))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                        .transition(.opacity)
                } else if !viewModel.shouldHideTimer {
                    Text(String(format: "%.2f秒", viewModel.elapsedTime))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(viewModel.isRunning ? .primary : .secondary)
                        .transition(.opacity)
                } else {
                    Text("???")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                        .transition(.opacity)
                }
                
                // 結果表示
                if let result = viewModel.gameResult {
                    VStack(spacing: 10) {
                        Text(result.message)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(result == .success ? .green : .red)
                        
                        let difference = abs(viewModel.elapsedTime - 5.0)
                        Text("誤差: \(String(format: "%.2f", difference))秒")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                // ボタン
                if !viewModel.isRunning && viewModel.gameResult == nil {
                    Button {
                        viewModel.startTimer()
                    } label: {
                        Text("スタート")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(Color.green)
                            .cornerRadius(30)
                    }
                } else if viewModel.isRunning {
                    Button {
                        viewModel.stopTimer()
                    } label: {
                        Text("ストップ！")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(Color.red)
                            .cornerRadius(30)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.shouldHideTimer)
        .navigationTitle("5秒ストップ")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showResultDialog) {
            GameResultDialog(
                result: viewModel.gameResult ?? .failure,
                elapsedTime: viewModel.elapsedTime,
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
    NavigationView {
        FiveSecondStopView(appViewModel: AppViewModel())
    }
}
