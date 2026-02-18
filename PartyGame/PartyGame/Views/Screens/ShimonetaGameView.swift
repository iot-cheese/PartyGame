//
//  ShimonetaGameView.swift
//  PartyGame
//
//  Created by GitHub Copilot on 2026/02/05.
//

import SwiftUI

struct ShimonetaGameView: View {
    @ObservedObject var appViewModel: AppViewModel
    @StateObject private var viewModel = ShimonetaViewModel()
    @State private var showingMemberInput = false
    @State private var cpuStateText = "選択しています..."
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.12, green: 0.12, blue: 0.18)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header (Back button handled by NavigationView usually due to navigationBarItems)
                // But request says "Back button (top left) - Title".
                // If we are in NavigationView, we get a back button.
                // But we can customize title.
                
                switch viewModel.gameState {
                case .setup:
                    setupView
                case .roleAnnouncement:
                    roleAnnouncementView
                case .turnIntro:
                    turnIntroView
                case .turnSelection:
                    turnSelectionView
                case .resultStandby:
                    resultStandbyView
                case .resultReveal, .outcome:
                    resultView
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("下ネタを作るな")
        .sheet(isPresented: $showingMemberInput) {
            ShimonetaMemberInputView(viewModel: viewModel, settingsManager: appViewModel.settingsManager, isPresented: $showingMemberInput)
        }
    }
    
    // MARK: - Role Announcement View
    var roleAnnouncementView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("役割")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                Text("挑戦者")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                ForEach(viewModel.activeMembers, id: \.self) { member in
                    Text(member)
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            
            VStack(spacing: 15) {
                Text("お客さん")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                ForEach(viewModel.targetMembers, id: \.self) { member in
                    Text(member)
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)

            Spacer()
            
            Button(action: {
                viewModel.startTurns()
            }) {
                Text("ゲーム開始")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Setup View
    var setupView: some View {
        VStack(spacing: 30) {
            HStack {
                Button(action: {
                    appViewModel.backToGameSelection()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            // Title (Already in nav bar but maybe big one too?)
            Text("下ネタを作るな")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
            
            Text("【ルール】\n下ネタワードを避けて言葉を作れ！\nお客さんは下ネタがきらい...")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
            
            Button(action: {
                showingMemberInput = true
            }) {
                Text("メンバーを入力")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            
            Button(action: {
                if viewModel.members.count >= 2 {
                    // 履歴保存
                    appViewModel.settingsManager.saveMemberHistory(gameId: SettingsManager.sharedMemberHistoryId, members: viewModel.members)
                    
                    // プレイ回数をインクリメント
                    appViewModel.settingsManager.incrementPlayCount(for: GameType.shimoneta.id)
                    
                    viewModel.startGame()
                }
            }) {
                Text("スタート")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.members.count >= 2 ? Color.green : Color.gray)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .disabled(viewModel.members.count < 2)
            
            Spacer()
        }
    }
    
    // MARK: - Turn Intro View
    var turnIntroView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            let currentPlayer = viewModel.activeMembers[viewModel.currentTurnIndex]
            
            if currentPlayer == "CPU" {
                Text("CPUのターン")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text(viewModel.cpuStateText)
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .onAppear {
                        viewModel.playCpuTurn()
                    }
            } else {
                Text("\(currentPlayer)さんの番です")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("他のメンバーに見えないようにしてね")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Button(action: {
                    viewModel.gameState = .turnSelection
                }) {
                    Text("OK")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(40)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Turn Selection View
    var turnSelectionView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("どちらかを選択してね")
                .font(.title)
                .foregroundColor(.white)
            
            let choices = viewModel.choicesForCurrentTurn()
            
            HStack(spacing: 30) {
                ForEach(choices, id: \.self) { char in
                    Button(action: {
                        viewModel.selectChar(char)
                    }) {
                        Text(char)
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 140, height: 140)
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Result Standby View
    var resultStandbyView: some View {
        VStack {
            Spacer()
            
            Button(action: {
                viewModel.startResultReveal()
            }) {
                Text("結果発表")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Result View
    var resultView: some View {
        ShimonetaResultView(viewModel: viewModel, appViewModel: appViewModel)
    }
}

struct ShimonetaMemberInputView: View {
    @ObservedObject var viewModel: ShimonetaViewModel
    @ObservedObject var settingsManager: SettingsManager
    @Binding var isPresented: Bool
    @State private var newName: String = ""
    @FocusState private var isFocused: Bool
    @State private var showingHistory = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.members, id: \.self) { member in
                        Text(member)
                    }
                    .onDelete(perform: viewModel.removeMember)
                }
                
                HStack {
                    TextField("名前を入力", text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isFocused)
                        .onSubmit {
                            addMember()
                        }
                    
                    Button(action: {
                        addMember()
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
            .navigationTitle("メンバー入力")
            .navigationBarItems(
                leading: Button(action: {
                    showingHistory = true
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("履歴")
                },
                trailing: Button("完了") {
                    isPresented = false
                }
            )
            .sheet(isPresented: $showingHistory) {
                 MemberHistoryView(settingsManager: settingsManager, gameId: SettingsManager.sharedMemberHistoryId) { selectedMembers in
                     viewModel.members = selectedMembers
                 }
            }
        }
    }
    
    private func addMember() {
        viewModel.addMember(name: newName)
        newName = ""
        isFocused = true
    }
}

struct ShimonetaResultView: View {
    @ObservedObject var viewModel: ShimonetaViewModel
    @ObservedObject var appViewModel: AppViewModel
    @State private var revealedCount = 0
    @State private var showOutcome = false
    @State private var revealOrder: [Int] = [0, 1, 2]
    
    var body: some View {
        VStack(spacing: 30) {
            
            // Top Status Display (SAFE / OUT for the word)
            if showOutcome {
                let outcome = viewModel.getOutcome()
                Text(outcome == .forbiddenMatch ? "OUT" : "SAFE")
                    .font(.system(size: 80, weight: .heavy))
                    .foregroundColor(outcome == .forbiddenMatch ? .red : .green)
                    .transition(.scale.combined(with: .opacity))
                    .padding(.top, 40)
            } else {
                Spacer().frame(height: 120) // Spacer to keep layout stable before outcome
            }
            
            HStack(spacing: 20) {
                ForEach(0..<3) { index in
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                        
                        if isRevealed(index) {
                             Text(char(at: index))
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.black)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                             Image(systemName: "questionmark")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            Spacer()
            
            if showOutcome {
                let outcome = viewModel.getOutcome()
                
                VStack(spacing: 15) {
                    if outcome == .forbiddenMatch {
                        // Forbidden Match -> Active Members OUT
                        Spacer()
                        Text("最低...")
                            .foregroundColor(.white)
                            .font(.title3)
                        Spacer()
                        ZStack(alignment: .top) {
                             // Background box
                             RoundedRectangle(cornerRadius: 16)
                                 .stroke(Color.red, lineWidth: 4)
                                 .background(Color.black.opacity(0.3).cornerRadius(16))
                                 .frame(maxWidth: .infinity)
                                 .frame(height: 150)
                             
                             // OUT label on top edge
                             Text("失格")
                                 .font(.title)
                                 .fontWeight(.heavy)
                                 .foregroundColor(.white)
                                 .padding(.horizontal, 20)
                                 .padding(.vertical, 5)
                                 .background(Color.red)
                                 .cornerRadius(8)
                                 .offset(y: -20)
                                 
                             // Names inside
                             VStack {
                                 Spacer()
                                 Text(viewModel.getActualActiveMembers().filter{$0 != "CPU"}.joined(separator: "\n"))
                                     .font(.title)
                                     .fontWeight(.bold)
                                     .foregroundColor(.white)
                                     .multilineTextAlignment(.center)
                                 Spacer()
                             }
                             .frame(height: 150)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)

                    } else {
                        // Not Forbidden -> Target OUT
                        // 二人プレイ時のお客さんは表示しない場合がある
                        if viewModel.shouldShowTargetMembersInResult() {
                            ZStack(alignment: .top) {
                                 // Background box
                                 RoundedRectangle(cornerRadius: 16)
                                     .stroke(Color.red, lineWidth: 4)
                                     .background(Color.black.opacity(0.3).cornerRadius(16))
                                     .frame(maxWidth: .infinity)
                                     .frame(height: 150)
                                 
                                 // OUT label on top edge
                                 Text("失格")
                                     .font(.title)
                                     .fontWeight(.heavy)
                                     .foregroundColor(.white)
                                     .padding(.horizontal, 20)
                                     .padding(.vertical, 5)
                                     .background(Color.red)
                                     .cornerRadius(8)
                                     .offset(y: -20)
                                 
                                 // Names inside
                                 VStack {
                                     Spacer()
                                     Text(viewModel.targetMembers.joined(separator: "\n"))
                                         .font(.title)
                                         .fontWeight(.bold)
                                         .foregroundColor(.white)
                                         .multilineTextAlignment(.center)
                                     Spacer()
                                 }
                                 .frame(height: 150)
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                        }
                    }
                }
                .transition(.opacity)
                .padding(.bottom, 20)
                
                HStack(spacing: 20) {
                    Button(action: {
                        // プレイ回数をインクリメント
                        appViewModel.settingsManager.incrementPlayCount(for: GameType.shimoneta.id)
                        
                        viewModel.startGame()
                        resetState()
                    }) {
                        Text("つづける")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        appViewModel.backToGameSelection()
                    }) {
                        Text("別のゲーム")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .onAppear {
            calculateRevealOrder()
            startRevealSequence()
        }
    }
    
    func resetState() {
        revealedCount = 0
        showOutcome = false
        calculateRevealOrder()
        startRevealSequence()
    }
    
    func startRevealSequence() {
        // Stop any pending items? Not easily done with asyncAfter unless we use DispatchWorkItem but for simplicity we assume view isn't thrashed.
        revealedCount = 0
        showOutcome = false
        
        // 1st char
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard viewModel.gameState == .resultReveal else { return }
            withAnimation(.spring()) { revealedCount = 1 }
            viewModel.playSound(named: "drumroll")
            
            // 2nd char
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                guard viewModel.gameState == .resultReveal else { return }
                withAnimation(.spring()) { revealedCount = 2 }
                viewModel.playSound(named: "drumroll")
                
                // 3rd char - Delayed ("溜めて")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    guard viewModel.gameState == .resultReveal else { return }
                    withAnimation(.spring()) { revealedCount = 3 }
                    viewModel.playSound(named: "drumroll")
                    
                    // Show Outcome
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if !showOutcome && viewModel.gameState == .resultReveal {
                            withAnimation {
                                showOutcome = true
                                viewModel.gameState = .outcome
                                
                                let outcome = viewModel.getOutcome()
                                if outcome == .forbiddenMatch {
                                    viewModel.playSound(named: "out")
                                } else {
                                    viewModel.playSound(named: "safe")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func calculateRevealOrder() {
        let outcome = viewModel.getOutcome()
        var indices = [0, 1, 2]
        
        if outcome == .forbiddenMismatch {
            // SAFE case: Prefer displaying chars from the word that has more matches first
            let words = viewModel.activeForbiddenWords
            if words.count >= 2 {
                let wordA = Array(words[0])
                let wordB = Array(words[1])
                let selected = viewModel.selectedChars
                
                var matchesA: Set<Int> = []
                var matchesB: Set<Int> = []
                
                for i in 0..<3 {
                    if i < selected.count && i < wordA.count && i < wordB.count {
                        let charString = selected[i]
                        if String(wordA[i]) == charString { matchesA.insert(i) }
                        if String(wordB[i]) == charString { matchesB.insert(i) }
                    }
                }
                
                if matchesA.count > matchesB.count {
                    let firstGroup = Array(matchesA).shuffled()
                    let remaining = indices.filter { !matchesA.contains($0) }.shuffled()
                    revealOrder = firstGroup + remaining
                } else if matchesB.count > matchesA.count {
                    let firstGroup = Array(matchesB).shuffled()
                    let remaining = indices.filter { !matchesB.contains($0) }.shuffled()
                    revealOrder = firstGroup + remaining
                } else {
                    revealOrder = indices.shuffled()
                }
            } else {
                revealOrder = indices.shuffled()
            }
        } else {
            // OUT case: Random order
            revealOrder = indices.shuffled()
        }
    }

    func isRevealed(_ index: Int) -> Bool {
        return revealOrder.prefix(revealedCount).contains(index)
    }
    
    func char(at index: Int) -> String {
        return viewModel.displayChar(at: index)
    }
}
