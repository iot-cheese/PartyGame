//
//  SecretQuestionView.swift
//  PartyGame
//
//  Created by github_copilot on 2026/02/15.
//

import SwiftUI

struct SecretQuestionView: View {
    @StateObject private var viewModel = SecretQuestionViewModel()
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.1, green: 0.1, blue: 0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header
                if viewModel.currentPhase == .entry {
                    HStack {
                        Button(action: {
                            appViewModel.backToGameSelection()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                        }
                        Spacer()
                    }
                } else if viewModel.currentPhase == .lobby {
                    HStack {
                         Button(action: {
                             viewModel.quitLobby()
                        }) {
                            Text("戻る")
                                .font(.caption)
                                .padding(8)
                                .background(Color.red.opacity(0.7))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding()
                } else {
                    // Game phases: No back button on top left
                    Spacer().frame(height: 50)
                }
                
                switch viewModel.currentPhase {
                case .entry:
                    entryView
                case .lobby:
                    lobbyView
                case .questionInput:
                    questionInputView
                case .answering:
                    answeringView
                case .results:
                    resultsView
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var entryView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bonjour")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
            
            Text("秘密の質問")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
             Text("※このゲームは参加者全員が\nアプリをインストールする必要があります")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text("匿名で際どい質問を投げかけよう！\n誰がYesと答えたかはわからないよ🤫")
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("合言葉 (ルームコード)")
                    .foregroundColor(.white)
                TextField("合言葉を入力 (例: apple)", text: $viewModel.roomCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
            }
            .padding(.horizontal, 40)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                viewModel.createRoom()
            }) {
                Text("ルーム作成")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Button(action: {
                viewModel.joinRoom()
            }) {
                Text("ルームに入る")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var lobbyView: some View {
        VStack(spacing: 20) {
            Text("待機中...")
                .font(.title)
                .foregroundColor(.white)
            
            Text("合言葉: \(viewModel.roomCode)")
                .font(.headline)
                .foregroundColor(.gray)
            
            Divider().background(Color.white)
            
            if viewModel.isHost {
                VStack(spacing: 8) {
                    Text("質問を考える時間")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    Picker("質問を考える時間", selection: $viewModel.selectedQuestionTime) {
                         Text("15秒").tag(15)
                         Text("30秒").tag(30)
                         Text("60秒").tag(60)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal, 40)
                }
            }
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.connectedPeers, id: \.self) { peer in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.green)
                            Text(peer.displayName)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Show self too
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.blue)
                        Text("\(viewModel.userName) (あなた)")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
            
            if viewModel.isHost {
                Button(action: {
                    // プレイ回数をインクリメント
                    appViewModel.settingsManager.incrementPlayCount(for: GameType.secretQuestion.id)
                    
                    viewModel.startGame()
                }) {
                    Text("ゲーム開始")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .disabled(viewModel.connectedPeers.isEmpty) // Maybe discourage solo play?
                .opacity(viewModel.connectedPeers.isEmpty ? 0.6 : 1.0)
            } else {
                Text("ホストがゲームを開始するのを待っています...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var questionInputView: some View {
        VStack(spacing: 30) {
            Text("質問を考えよう！")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("\(viewModel.timeLeft)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(viewModel.timeLeft <= 5 ? .red : .white)
            
            if !viewModel.hasSubmittedQuestion {
                TextField("質問を入力 (例: 朝食はパン派？)", text: $viewModel.myQuestionText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button(action: {
                    viewModel.submitQuestion()
                }) {
                    Text("決定")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    Text("送信完了！")
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    Text("他の人の質問を待っています...")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var answeringView: some View {
        VStack(spacing: 30) {
            Text("質問")
                .font(.headline)
                .foregroundColor(.gray)
            
            if let question = viewModel.currentQuestion {
                Text(question.text)
                    .font(.largeTitle) // Big text
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(minHeight: 150)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
            }
            
            Text("\(viewModel.timeLeft)")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundColor(viewModel.timeLeft <= 3 ? .red : .yellow)
            
            if viewModel.isMyQuestion {
                AnyView(
                    Text("あなたが送った質問です\n（回答はスキップされます）")
                        .font(.title3)
                        .foregroundColor(.blue.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding()
                )
            } else if !viewModel.hasAnsweredCurrent {
                HStack(spacing: 20) {
                    Button(action: {
                        viewModel.submitAnswer(answer: true)
                    }) {
                        Text("はい")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(Color.pink)
                            .cornerRadius(15)
                    }
                    
                    Button(action: {
                        viewModel.submitAnswer(answer: false)
                    }) {
                        Text("いいえ")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal)
            } else {
                Text("回答しました")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    private var resultsView: some View {
        VStack {
            Text("結果発表")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
            
            ScrollView {
                VStack(spacing: 15) {
                    if viewModel.questions.isEmpty {
                         Text("あなたが送った質問はありません")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.questions) { question in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(question.text)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Text("はい: \(question.yesCount)")
                                        .fontWeight(.bold)
                                        .foregroundColor(.pink)
                                    Spacer()
                                    Text("いいえ: \(question.noCount)")
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            
            Button(action: {
                viewModel.returnToLobby()
            }) {
                Text("部屋に戻る")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(12)
            }
            .padding()
        }
    }
}

// #Preview {
//    SecretQuestionView(appViewModel: AppViewModel())
// }
