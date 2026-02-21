//
//  WordWolfView.swift
//  PartyGame
//
//  Created by GitHub Copilot on 2026/02/03.
//

import SwiftUI

struct WordWolfView: View {
    @StateObject private var viewModel = WordWolfViewModel()
    @State private var showingMemberInput = false
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.95, green: 0.95, blue: 0.97).edgesIgnoringSafeArea(.all)
            
            switch viewModel.gameState {
            case .setup:
                WordWolfSetupView(viewModel: viewModel, appViewModel: appViewModel, showingMemberInput: $showingMemberInput)
            case .inputMembers:
                // Should not happen as main state if using sheet/modal
                EmptyView()
            case .checkingRole: 
                WordWolfRoleCheckView(viewModel: viewModel)
            case .playing:
                WordWolfGameView(viewModel: viewModel)
            case .result:
                WordWolfResultView(viewModel: viewModel, appViewModel: appViewModel)
            }
        }
        .sheet(isPresented: $showingMemberInput) {
            WordWolfMemberInputView(viewModel: viewModel, settingsManager: appViewModel.settingsManager)
        }
    }
}

// MARK: - Setup View
struct WordWolfSetupView: View {
    @ObservedObject var viewModel: WordWolfViewModel
    @ObservedObject var appViewModel: AppViewModel
    @Binding var showingMemberInput: Bool
    
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
                Text("ワードウルフ")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal)
            
            Text("【ルール】\nみんなと違うお題を与えられた人（ワードウルフ）を探し出そう！\n話し合いでお題の違いに気づいても、\n悟られないように注意！")
                .multilineTextAlignment(.center)
                .font(.body)
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(10)
                .padding(.horizontal)
            
            Spacer()
            
            // Member Input Button
            Button(action: {
                showingMemberInput = true
            }) {
                HStack {
                    Image(systemName: "person.3.fill")
                    Text("メンバーを入力")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            if !viewModel.players.isEmpty {
                Text("現在の参加者: \(viewModel.players.count)人")
                    .foregroundColor(.gray)
            }
            
            // Time Limit
            HStack {
                Text("制限時間")
                Spacer()
                Picker("Time", selection: $viewModel.timeLimit) {
                    Text("3分").tag(180)
                    Text("5分").tag(300)
                    Text("10分").tag(600)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            .padding(.horizontal, 40)
            
            // Wolf Count
            HStack {
                Text("人狼の数")
                Spacer()
                Stepper("\(viewModel.wolfCount)人", value: $viewModel.wolfCount, in: 1...max(1, viewModel.players.count / 2))
                    .frame(width: 150)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Start Button
            Button(action: {
                // 履歴に保存
                let memberNames = viewModel.players.map { $0.name }
                appViewModel.settingsManager.saveMemberHistory(gameId: SettingsManager.sharedMemberHistoryId, members: memberNames)
                
                // プレイ回数をインクリメント
                appViewModel.settingsManager.incrementPlayCount(for: GameType.wordWolf.id)
                
                viewModel.prepareGame()
            }) {
                Text("スタート")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.players.count >= 2 ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(viewModel.players.count < 2)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Member Input View
struct WordWolfMemberInputView: View {
    @ObservedObject var viewModel: WordWolfViewModel
    @ObservedObject var settingsManager: SettingsManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingHistory = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.players) { player in
                        HStack {
                            Text(player.name)
                            Spacer()
                        }
                    }
                    .onDelete(perform: viewModel.removeMember)
                }
                
                VStack {
                    HStack {
                        TextField("メンバー名を入力", text: $viewModel.newMemberName, onCommit: {
                            viewModel.addMember()
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            viewModel.addMember()
                        }) {
                            Text("追加")
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .padding(.bottom) // Adjust for keyboard?
            }
            .navigationTitle("メンバー入力")
            .navigationBarItems(
                leading: Button(action: {
                    showingHistory = true
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("履歴")
                },
                trailing: Button("完了") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showingHistory) {
                MemberHistoryView(settingsManager: settingsManager, gameId: SettingsManager.sharedMemberHistoryId) { selectedMembers in
                    // 既存メンバーをクリアして履歴から反映
                    viewModel.clearAllMembers()
                    for name in selectedMembers {
                        viewModel.newMemberName = name
                        viewModel.addMember()
                    }
                }
            }
        }
    }
}

// MARK: - Role Check View
struct WordWolfRoleCheckView: View {
    @ObservedObject var viewModel: WordWolfViewModel
    @State private var isTopicVisible = false
    
    var currentPlayer: WordWolfPlayer {
        viewModel.players[viewModel.currentCheckingPlayerIndex]
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("\(currentPlayer.name) さんの番です")
                .font(.title)
                .fontWeight(.bold)
            
            Text("他の人に見られないように\nお題を確認してください")
                .multilineTextAlignment(.center)
                .padding()
            
            if isTopicVisible {
                Spacer()
                VStack(spacing: 20) {
                    Text("あなたのお題は")
                        .font(.headline)
                    Text(currentPlayer.topic)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                Spacer()
                
                Button(action: {
                    isTopicVisible = false
                    viewModel.confirmCheckOk()
                }) {
                    Text("確認OK")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            } else {
                Spacer()
                Button(action: {
                    isTopicVisible = true
                }) {
                    Text("お題を確認")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
            
            Spacer().frame(height: 50)
        }
        .padding()
        .transition(.opacity)
    }
}

// MARK: - Game View
struct WordWolfGameView: View {
    @ObservedObject var viewModel: WordWolfViewModel
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // Timer
            Text(timeString(time: viewModel.remainingTime))
                .font(.system(size: 80, weight: .bold, design: .monospaced))
                .foregroundColor(viewModel.remainingTime < 30 ? .red : .primary)
            
            Spacer()
            
            // Facilitation Text
            if !viewModel.facilitationText.isEmpty {
                VStack(spacing: 10) {
                    Text("話題のヒント")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(viewModel.facilitationText)
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
                        .transition(.scale)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Result Button
            Button(action: {
                viewModel.showResult()
            }) {
                Text("結果を表示")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Result View
struct WordWolfResultView: View {
    @ObservedObject var viewModel: WordWolfViewModel
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text("結果発表")
                .font(.largeTitle)
                .fontWeight(.black)
                .padding()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Show Topics
                    HStack(spacing: 20) {
                        VStack {
                            Text("市民のお題")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(viewModel.currentTopic?.citizen ?? "")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        VStack {
                            Text("人狼のお題")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(viewModel.currentTopic?.wolf ?? "")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    
                    // Show Players
                    ForEach(viewModel.players) { player in
                        HStack {
                            Text(player.name)
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            if player.isWolf {
                                Text("人狼")
                                    .font(.headline)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            } else {
                                Text("市民")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            
            VStack(spacing: 15) {
                Button(action: {
                    // プレイ回数をインクリメント
                    appViewModel.settingsManager.incrementPlayCount(for: GameType.wordWolf.id)
                    
                    viewModel.playAgain()
                }) {
                    Text("ゲームを続ける")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    // Close Result modal first then navigate back?
                    // Or just set appModel selection to nil to go home.
                    viewModel.resetToSetup()
                    appViewModel.selectedGame = nil
                }) {
                    Text("別のゲームを選択")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.white)
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.99).edgesIgnoringSafeArea(.all))
    }
}
