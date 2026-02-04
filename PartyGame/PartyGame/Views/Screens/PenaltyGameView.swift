//
//  PenaltyGameView.swift
//  PartyGame
//
//  Created by GitHub Copilot on 2026/02/03.
//

import SwiftUI

struct PenaltyGameView: View {
    @ObservedObject var appViewModel: AppViewModel
    @StateObject private var viewModel = PenaltyGameViewModel()
    @State private var showingMemberInput = false
    
    var body: some View {
        ZStack {
            // Dark Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            switch viewModel.gameState {
            case .setup:
                PenaltySetupView(viewModel: viewModel, appViewModel: appViewModel, showingMemberInput: $showingMemberInput)
            case .inputMembers:
                EmptyView()
            case .tapToStart, .revealing:
                PenaltyTapView(viewModel: viewModel)
            case .itemGet:
                PenaltyItemGetView(viewModel: viewModel)
            case .result:
                PenaltyResultView(viewModel: viewModel, appViewModel: appViewModel)
            }
            
            // White Flash Overlay
            if viewModel.isFlashing {
                 Color.white.edgesIgnoringSafeArea(.all)
                     .transition(.opacity)
            }
        }
        .sheet(isPresented: $showingMemberInput) {
            PenaltyMemberInputView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showItemSelector) {
            PenaltyItemSelectorView(viewModel: viewModel)
        }
    }
}

// MARK: - Setup View
struct PenaltySetupView: View {
    @ObservedObject var viewModel: PenaltyGameViewModel
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
                        .foregroundColor(.red) // Suspicious color
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                }
                Spacer()
                Text("罰ゲーム")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Image or Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
                .padding()
            
            Text("恐怖のルーレット...")
                .font(.title2)
                .foregroundColor(.gray)
            
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
                .background(Color.white.opacity(0.15))
                .foregroundColor(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red, lineWidth: 1)
                )
            }
            .padding(.horizontal, 40)
            
            if !viewModel.players.isEmpty {
                Text("現在の参加者: \(viewModel.players.count)人")
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Start Button
            Button(action: {
                viewModel.startGame()
            }) {
                Text("スタート")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.players.count >= 1 ? Color.red : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(viewModel.players.count < 1)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Member Input View
struct PenaltyMemberInputView: View {
    @ObservedObject var viewModel: PenaltyGameViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Custom dark theme for sheet
    init(viewModel: PenaltyGameViewModel) {
        self.viewModel = viewModel
        // Attempt to style list generally, but SwiftUI Lists are tricky to theme completely without introspection or modifiers per row.
        // We will just do standard list but maybe force dark scheme if possible or just standard.
    }
    
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
                    .onMove(perform: viewModel.moveMember)
                    .onDelete(perform: viewModel.removeMember)
                }
                .listStyle(PlainListStyle())
                .toolbar {
                     EditButton()
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
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .padding(.bottom)
            }
            .navigationTitle("メンバー入力")
            .navigationBarItems(trailing: Button("完了") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Tap / Game View
struct PenaltyTapView: View {
    @ObservedObject var viewModel: PenaltyGameViewModel
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Current Player Name at top
                Text("\(viewModel.players[viewModel.currentPlayerIndex].name) のターン")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                // Cursed Status
                if viewModel.players[viewModel.currentPlayerIndex].curseStrength > 0 {
                    Text("アウト確率 \(viewModel.players[viewModel.currentPlayerIndex].curseStrength)% UP中")
                        .font(.headline)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top, 10)
                }
                
                Spacer()
                
                if viewModel.gameState == .revealing {
                    Text("・・・")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                        .transition(.opacity)
                } else {
                    Text("画面をタップしてね")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Spacer()
                
                // Use Item Button
                if let itemStrength = viewModel.players[viewModel.currentPlayerIndex].itemStrength, viewModel.gameState == .tapToStart {
                    Button(action: {
                        viewModel.showItemSelector = true
                    }) {
                        Text("呪いアイテムを使用する (効果: \(itemStrength)%)")
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .purple, radius: 10)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .contentShape(Rectangle()) // Make whole screen tappable
        .onTapGesture {
            // Only tap screen if not tapping the button
            viewModel.tapScreen()
        }
    }
}

// MARK: - Result View
struct PenaltyResultView: View {
    @ObservedObject var viewModel: PenaltyGameViewModel
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
                .overlay(
                    viewModel.isSafe ? Color.blue.opacity(0.1) : Color.red.opacity(0.2)
                )
            
            // Quit Button (Top Right)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.resetGame()
                        appViewModel.selectedGame = nil
                    }) {
                        Text("ゲームをやめる")
                            .fontWeight(.bold)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                Spacer()
            }
            .zIndex(1) // Ensure button is clickable
            
            // Main Content
            VStack {
                // Name Header
                Text("\(viewModel.players[viewModel.currentPlayerIndex].name) のターン")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding(.top, 70)
                
                Spacer()
                
                Text(viewModel.penaltyText)
                    .font(.custom("Hiragino Mincho ProN", size: 40)) // Unique font look "Serif"
                    .fontWeight(.black)
                    .foregroundColor(viewModel.isSafe ? .white : .red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .scaleEffect(viewModel.isSafe ? 1.0 : 1.2)
                    .animation(.spring(), value: viewModel.penaltyText)
                
                Spacer()
                
                // Next Button
                Button(action: {
                    viewModel.checkNextTurn()
                }) {
                    Text("次の人へ")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Item Get View
struct PenaltyItemGetView: View {
    @ObservedObject var viewModel: PenaltyGameViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("呪いアイテムゲット！")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.purple)
                
                if let strength = viewModel.gainedItemStrength {
                    Text("アウト確率 \(strength)% UP")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple.opacity(0.5))
                        .cornerRadius(15)
                }
                
                Text("次の自分のターンで使用できます")
                    .foregroundColor(.gray)
                
                Button(action: {
                    viewModel.confirmItemGet()
                }) {
                    Text("OK")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 50)
                        .padding(.vertical)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Item Selector View
struct PenaltyItemSelectorView: View {
    @ObservedObject var viewModel: PenaltyGameViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.players) { player in
                    // Cannot use on self
                    if player.id != viewModel.players[viewModel.currentPlayerIndex].id {
                        Button(action: {
                            viewModel.useItem(targetPlayerId: player.id)
                            viewModel.showItemSelector = false
                        }) {
                            HStack {
                                Text(player.name)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("選択")
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                }
            }
            .navigationTitle("呪う相手を選択")
            .navigationBarItems(trailing: Button("キャンセル") {
                viewModel.showItemSelector = false
            })
        }
    }
}
