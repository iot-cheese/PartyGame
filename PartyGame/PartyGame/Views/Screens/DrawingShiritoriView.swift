//
//  DrawingShiritoriView.swift
//  PartyGame
//
//  Created by GitHub Copilot on 2026/02/15.
//

import SwiftUI

struct DrawingShiritoriView: View {
    @StateObject private var viewModel = DrawingShiritoriViewModel()
    @State private var showingMemberInput = false
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.97).edgesIgnoringSafeArea(.all)
            
            switch viewModel.gameState {
            case .setup:
                DrawingShiritoriSetupView(viewModel: viewModel, appViewModel: appViewModel, showingMemberInput: $showingMemberInput)
            case .inputMembers:
                EmptyView()
            case .showingStart:
                DrawingShiritoriStartView(viewModel: viewModel)
            case .showingPrevious:
                DrawingShiritoriPreviousView(viewModel: viewModel)
            case .playing:
                DrawingShiritoriPlayingView(viewModel: viewModel)
            case .summary:
                DrawingShiritoriSummaryView(viewModel: viewModel)
            case .result:
                DrawingShiritoriResultView(viewModel: viewModel, appViewModel: appViewModel)
            }
        }
        .sheet(isPresented: $showingMemberInput) {
            DrawingShiritoriMemberInputView(viewModel: viewModel, settingsManager: appViewModel.settingsManager)
        }
    }
}

// MARK: - Setup View
struct DrawingShiritoriSetupView: View {
    @ObservedObject var viewModel: DrawingShiritoriViewModel
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
                Text("お絵描きしりとり")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("【ルール】\n最初に表示される文字から始まる絵を描いてしりとりを繋げよう！\n各プレイヤーは絵を描いた後、何を描いたか名前を入力します。\n最後に全ての絵を確認して、しりとりが成立していれば成功！")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
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
                    
                    // Turn Count
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ターン数")
                            .font(.headline)
                        Picker("Turn Count", selection: $viewModel.turnCount) {
                            ForEach(1...5, id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal, 40)
                    
                    // Time Limit
                    VStack(alignment: .leading, spacing: 8) {
                        Text("制限時間")
                            .font(.headline)
                        Picker("Time Limit", selection: $viewModel.timeLimit) {
                            Text("無制限").tag(TimeLimit.unlimited)
                            Text("15秒").tag(TimeLimit.fifteen)
                            Text("30秒").tag(TimeLimit.thirty)
                            Text("1分").tag(TimeLimit.sixty)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal, 40)
                    
                    // Start Button
                    Button(action: {
                        // 履歴保存
                        let memberNames = viewModel.players.map { $0.name }
                        appViewModel.settingsManager.saveMemberHistory(gameId: SettingsManager.sharedMemberHistoryId, members: memberNames)
                        
                        // プレイ回数をインクリメント
                        appViewModel.settingsManager.incrementPlayCount(for: GameType.drawingShiritori.id)
                        
                        viewModel.startGame()
                    }) {
                        Text("スタート")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.players.count >= 1 ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.players.count < 1)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Start View (最初の文字とメンバー順番表示)
struct DrawingShiritoriStartView: View {
    @ObservedObject var viewModel: DrawingShiritoriViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("お絵描きしりとり")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Spacer()
            
            VStack(spacing: 20) {
                Text("最初の文字")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text(viewModel.startingCharacter)
                    .font(.system(size: 100))
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 200, height: 200)
                    )
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("メンバーの順番")
                    .font(.title3)
                    .fontWeight(.bold)
                
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.playerOrder.enumerated()), id: \.offset) { index, playerName in
                        HStack {
                            Text("\(index + 1).")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .frame(width: 30, alignment: .trailing)
                            
                            Text(playerName)
                                .font(.headline)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 60)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(15)
                .padding(.horizontal, 30)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.startPlaying()
            }) {
                Text("始める")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: 300)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.bottom, 40)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
    }
}

// MARK: - Previous Drawing View (前の人の絵を表示)
struct DrawingShiritoriPreviousView: View {
    @ObservedObject var viewModel: DrawingShiritoriViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            if let player = viewModel.currentPlayer {
                Text("\(player.name)の番")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            Text(viewModel.currentTurnNumber)
                .font(.title3)
                .foregroundColor(.gray)
            
            Spacer()
            
            if let previousDrawing = viewModel.previousDrawing {
                VStack(spacing: 15) {
                    Text("前の人が描いた絵")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Image(uiImage: previousDrawing)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 300)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
            }
            
            Spacer()
            
            Button(action: {
                viewModel.startDrawing()
            }) {
                Text("絵を描く")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: 300)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.bottom, 40)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
    }
}

// MARK: - Member Input View
struct DrawingShiritoriMemberInputView: View {
    @ObservedObject var viewModel: DrawingShiritoriViewModel
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

// MARK: - Playing View
struct DrawingShiritoriPlayingView: View {
    @ObservedObject var viewModel: DrawingShiritoriViewModel
    @State private var canvasView = DrawingCanvasView(drawing: .constant(nil))
    
    var body: some View {
        GeometryReader { geometry in
            if viewModel.showingNameInput {
                // Name Input Screen
                VStack(spacing: 30) {
                    Text("描いたものの名前を入力")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let drawing = viewModel.currentDrawing {
                        Image(uiImage: drawing)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    
                    VStack(spacing: 10) {
                        TextField("名前を入力（ひらがな・カタカナ）", text: $viewModel.currentWord)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 40)
                            .font(.title3)
                        
                        // バリデーションメッセージ
                        if !viewModel.currentWord.isEmpty {
                            if !viewModel.isValidInput(viewModel.currentWord) {
                                Text("ひらがな・カタカナで入力してください")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else if viewModel.currentTurnIndex == 0 && !viewModel.isValidStartingWord(viewModel.currentWord) {
                                Text("「\(viewModel.startingCharacter)」で始まる言葉を入力してください")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Button(action: {
                        if viewModel.canSubmitWord() {
                            viewModel.submitWord()
                        }
                    }) {
                        Text("OK")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(width: 200)
                            .padding()
                            .background(viewModel.canSubmitWord() ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.canSubmitWord())
                    
                    Spacer()
                }
                .padding()
                .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            } else {
                // Drawing Screen
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        if let player = viewModel.currentPlayer {
                            Text("\(player.name)の番")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        Text(viewModel.currentTurnNumber)
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        if viewModel.timeLimit.seconds != nil {
                            Text("\(viewModel.remainingTime)秒")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(viewModel.remainingTime <= 5 ? .red : .black)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            viewModel.completeDrawing()
                        }) {
                            Text("完了")
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    
                    // Canvas
                    DrawingCanvasView(drawing: $viewModel.currentDrawing)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Summary View
struct DrawingShiritoriSummaryView: View {
    @ObservedObject var viewModel: DrawingShiritoriViewModel
    @State private var selectedDrawing: UIImage? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("全員終了！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("描いた絵を確認しよう")
                    .font(.title3)
                
                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    VStack(spacing: 10) {
                        createDrawingGrid()
                    }
                    .frame(minWidth: UIScreen.main.bounds.width - 40)
                    .padding()
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.showResult()
                }) {
                    Text("結果を見る")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: 300)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.bottom, 40)
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            
            // 拡大表示オーバーレイ
            if let drawing = selectedDrawing {
                Color.black.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        selectedDrawing = nil
                    }
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            selectedDrawing = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    
                    Image(uiImage: drawing)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9, maxHeight: UIScreen.main.bounds.height * 0.7)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                    
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    private func createDrawingGrid() -> some View {
        let itemsPerRow = 3
        let totalItems = viewModel.drawings.count + 1 // +1 for starting character
        let totalRows = Int(ceil(Double(totalItems) / Double(itemsPerRow)))
        
        VStack(spacing: 3) {
            ForEach(0..<totalRows, id: \.self) { rowIndex in
                // 偶数行は左から右、奇数行は右から左
                let isLeftToRight = rowIndex % 2 == 0
                
                // 各行のアイテム
                HStack(spacing: 5) {
                    ForEach(0..<itemsPerRow, id: \.self) { colIndex in
                        let displayColIndex = isLeftToRight ? colIndex : (itemsPerRow - 1 - colIndex)
                        let itemIndex = rowIndex * itemsPerRow + displayColIndex
                        
                        if itemIndex < totalItems {
                            VStack(spacing: 2) {
                                if itemIndex == 0 {
                                    // Starting character
                                    VStack(spacing: 2) {
                                        Text(viewModel.startingCharacter)
                                            .font(.system(size: 40))
                                            .fontWeight(.bold)
                                            .frame(width: 100, height: 100)
                                            .background(Color.yellow.opacity(0.3))
                                            .cornerRadius(8)
                                        Text("スタート")
                                            .font(.system(size: 10))
                                            .fontWeight(.bold)
                                            .frame(height: 12)
                                    }
                                } else {
                                    let entry = viewModel.drawings[itemIndex - 1]
                                    
                                    if let drawing = entry.drawing {
                                        Image(uiImage: drawing)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                            .shadow(radius: 1)
                                            .onTapGesture {
                                                selectedDrawing = drawing
                                            }
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                    }
                                    
                                    VStack(spacing: 1) {
                                        Text(String(repeating: "?", count: max(1, entry.word.count)))
                                            .font(.system(size: 12))
                                            .fontWeight(.bold)
                                        
                                        Text(entry.playerName)
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                    }
                                    .frame(height: 26)
                                }
                            }
                            .frame(width: 100)
                            
                            // 横矢印
                            if colIndex < itemsPerRow - 1 {
                                let nextItemIndex = rowIndex * itemsPerRow + (isLeftToRight ? displayColIndex + 1 : displayColIndex - 1)
                                
                                if nextItemIndex < totalItems {
                                    VStack(spacing: 2) {
                                        Image(systemName: isLeftToRight ? "arrow.right" : "arrow.left")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .frame(width: 20, height: 100)
                                        Spacer()
                                            .frame(height: itemIndex == 0 ? 12 : 26)
                                    }
                                } else {
                                    Spacer()
                                        .frame(width: 20)
                                }
                            }
                        } else {
                            // 空のスペース（下の段を上の段の端に揃える）
                            if isLeftToRight {
                                Spacer()
                                    .frame(width: 100)
                            } else {
                                VStack(spacing: 2) {
                                    Spacer()
                                        .frame(width: 100, height: 100)
                                    Spacer()
                                        .frame(height: 26)
                                }
                                .frame(width: 100)
                            }
                            
                            if colIndex < itemsPerRow - 1 {
                                Spacer()
                                    .frame(width: 20)
                            }
                        }
                    }
                }
                
                // 下矢印（次の行がある場合）
                if rowIndex < totalRows - 1 {
                    let firstItemInNextRow = (rowIndex + 1) * itemsPerRow
                    
                    if firstItemInNextRow < totalItems {
                        HStack(spacing: 5) {
                            ForEach(0..<itemsPerRow, id: \.self) { colIndex in
                                // 行の最後のアイテムの位置に矢印を配置
                                // 左から右の行：右端（colIndex == itemsPerRow - 1）
                                // 右から左の行：左端（colIndex == 0）
                                if (isLeftToRight && colIndex == itemsPerRow - 1) || (!isLeftToRight && colIndex == 0) {
                                    Image(systemName: "arrow.down")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .frame(width: 100, height: 15)
                                } else {
                                    Spacer()
                                        .frame(width: 100, height: 15)
                                }
                                
                                if colIndex < itemsPerRow - 1 {
                                    Spacer()
                                        .frame(width: 20)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Result View
struct DrawingShiritoriResultView: View {
    @ObservedObject var viewModel: DrawingShiritoriViewModel
    @ObservedObject var appViewModel: AppViewModel
    @State private var selectedDrawing: UIImage? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Success/Failure indicator
            if viewModel.isGameSuccessful {
                Text("成功！🎉")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding()
            } else {
                Text("失敗...")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding()
            }
            
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                VStack(spacing: 10) {
                    createResultGrid()
                }
                .frame(minWidth: UIScreen.main.bounds.width - 40)
                .padding()
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    // プレイ回数をインクリメント
                    appViewModel.settingsManager.incrementPlayCount(for: GameType.drawingShiritori.id)
                    
                    viewModel.resetGame()
                }) {
                    Text("ゲームを続ける")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    appViewModel.backToGameSelection()
                }) {
                    Text("別のゲームを選択")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        
        // 拡大表示オーバーレイ
        if let drawing = selectedDrawing {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    selectedDrawing = nil
                }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        selectedDrawing = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                Image(uiImage: drawing)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9, maxHeight: UIScreen.main.bounds.height * 0.7)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                
                Spacer()
            }
        }
    }
    }
    
    @ViewBuilder
    private func createResultGrid() -> some View {
        let itemsPerRow = 3
        let totalItems = viewModel.drawings.count + 1 // +1 for starting character
        let totalRows = Int(ceil(Double(totalItems) / Double(itemsPerRow)))
        
        VStack(spacing: 3) {
            ForEach(0..<totalRows, id: \.self) { rowIndex in
                // 偶数行は左から右、奇数行は右から左
                let isLeftToRight = rowIndex % 2 == 0
                
                // 各行のアイテム
                HStack(spacing: 5) {
                    ForEach(0..<itemsPerRow, id: \.self) { colIndex in
                        let displayColIndex = isLeftToRight ? colIndex : (itemsPerRow - 1 - colIndex)
                        let itemIndex = rowIndex * itemsPerRow + displayColIndex
                        
                        if itemIndex < totalItems {
                            VStack(spacing: 2) {
                                if itemIndex == 0 {
                                    // Starting character
                                    VStack(spacing: 2) {
                                        Text(viewModel.startingCharacter)
                                            .font(.system(size: 40))
                                            .fontWeight(.bold)
                                            .frame(width: 100, height: 100)
                                            .background(Color.yellow.opacity(0.3))
                                            .cornerRadius(8)
                                        Text("スタート")
                                            .font(.system(size: 10))
                                            .fontWeight(.bold)
                                            .frame(height: 12)
                                    }
                                } else {
                                    let entry = viewModel.drawings[itemIndex - 1]
                                    
                                    if let drawing = entry.drawing {
                                        Image(uiImage: drawing)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                            .shadow(radius: 1)
                                            .onTapGesture {
                                                selectedDrawing = drawing
                                            }
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                    }
                                    
                                    VStack(spacing: 1) {
                                        // 名称と○×を横並びで表示
                                        HStack(spacing: 3) {
                                            if let isCorrect = entry.isCorrect {
                                                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(isCorrect ? .green : .red)
                                            }
                                            
                                            Text(entry.word.isEmpty ? "未入力" : entry.word)
                                                .font(.system(size: 12))
                                                .fontWeight(.bold)
                                                .foregroundColor(entry.word.isEmpty ? .red : .black)
                                        }
                                        
                                        Text(entry.playerName)
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                    }
                                    .frame(height: 26)
                                }
                            }
                            .frame(width: 100)
                            
                            // 横矢印
                            if colIndex < itemsPerRow - 1 {
                                let nextItemIndex = rowIndex * itemsPerRow + (isLeftToRight ? displayColIndex + 1 : displayColIndex - 1)
                                
                                if nextItemIndex < totalItems {
                                    VStack(spacing: 2) {
                                        Image(systemName: isLeftToRight ? "arrow.right" : "arrow.left")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .frame(width: 20, height: 100)
                                        Spacer()
                                            .frame(height: itemIndex == 0 ? 12 : 26)
                                    }
                                } else {
                                    Spacer()
                                        .frame(width: 20)
                                }
                            }
                        } else {
                            // 空のスペース（下の段を上の段の端に揃える）
                            if isLeftToRight {
                                Spacer()
                                    .frame(width: 100)
                            } else {
                                VStack(spacing: 2) {
                                    Spacer()
                                        .frame(width: 100, height: 100)
                                    Spacer()
                                        .frame(height: 26)
                                }
                                .frame(width: 100)
                            }
                            
                            if colIndex < itemsPerRow - 1 {
                                Spacer()
                                    .frame(width: 20)
                            }
                        }
                    }
                }
                
                // 下矢印（次の行がある場合）
                if rowIndex < totalRows - 1 {
                    let firstItemInNextRow = (rowIndex + 1) * itemsPerRow
                    
                    if firstItemInNextRow < totalItems {
                        HStack(spacing: 5) {
                            ForEach(0..<itemsPerRow, id: \.self) { colIndex in
                                // 行の最後のアイテムの位置に矢印を配置
                                // 左から右の行：右端（colIndex == itemsPerRow - 1）
                                // 右から左の行：左端（colIndex == 0）
                                if (isLeftToRight && colIndex == itemsPerRow - 1) || (!isLeftToRight && colIndex == 0) {
                                    Image(systemName: "arrow.down")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .frame(width: 100, height: 15)
                                } else {
                                    Spacer()
                                        .frame(width: 100, height: 15)
                                }
                                
                                if colIndex < itemsPerRow - 1 {
                                    Spacer()
                                        .frame(width: 20)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DrawingShiritoriView(appViewModel: AppViewModel())
}
