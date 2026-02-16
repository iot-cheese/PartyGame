//
//  GameSelectionView.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import SwiftUI

struct GameSelectionView: View {
    @ObservedObject var viewModel: AppViewModel
    
    private let brainGames: [GameType] = [.samekunCount, .wordFlash, .prefectureGuess, .pitchGuess]
    private let psychologyGames: [GameType] = [.wordWolf, .shimoneta]
    private let senseGames: [GameType] = [.grandparentGuess, .fiveSecondStop, .tomodachi, .dragonflyStop, .drawingShiritori, .senseGame]
    private let luckGames: [GameType] = [.penaltyGame]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 30) {
                            // Banner Ad
                            Button(action: {
                                if let url = URL(string: "https://store.line.me/stickershop/product/27491818/ja") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(spacing: 0) {
                                    Image("samekun_stamp")
                                        .resizable()
                                        .scaledToFit()
                                    
                                    Spacer().frame(width: 0)
                                    
                                    HStack {
                                        Image(systemName: "cart.fill")
                                        Text("サメくんのLINEスタンプ発売中！")
                                            .fontWeight(.bold)
                                    }
                                    .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .frame(height: 60)
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }

                            HStack {
                                Text("ゲーム選択")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                                
                                // Notification Button
                                Button {
                                    viewModel.showNotifications = true
                                } label: {
                                    ZStack(alignment: .topTrailing) {
                                        Image(systemName: "bell.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Color.white.opacity(0.2))
                                            .clipShape(Circle())
                                        
                                        if viewModel.notificationManager.unreadCount > 0 {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 12, height: 12)
                                                .offset(x: 2, y: -2)
                                        }
                                    }
                                }
                                .padding(.trailing, 8)
                                
                                // Settings Button
                                Button {
                                    viewModel.showSettings = true
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            
                            gameSection(title: "頭脳系", games: brainGames, geometry: geometry)
                            gameSection(title: "センス系", games: senseGames, geometry: geometry)
                            gameSection(title: "心理戦", games: psychologyGames, geometry: geometry)
                            gameSection(title: "運ゲー", games: luckGames, geometry: geometry)
                            
                            // Secret Question Section
                            Button(action: {
                                viewModel.selectGame(.secretQuestion)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0.8, blue: 0.9), Color(red: 0.1, green: 0.5, blue: 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.5), lineWidth: 4)
                                        )
                                        .shadow(color: Color(red: 0.1, green: 0.5, blue: 0.8).opacity(0.5), radius: 10, x: 0, y: 5)
                                    
                                    VStack(spacing: 8) {
                                        Image(systemName: "bonjour")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                        
                                        Text("秘密の質問")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Text("みんなの本音")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                            }
                            .padding(.vertical, 20)
                            .id(GameType.secretQuestion.id)
                            
                            Spacer().frame(height: 50)
                        }
                    }
                    .background(
                        Color(red: 0.12, green: 0.12, blue: 0.18) // Dark background
                            .edgesIgnoringSafeArea(.all)
                    )
                    .onAppear {
                        if let lastId = viewModel.lastSelectedGameId {
                            // Delay slightly to ensure layout is ready
                            DispatchQueue.main.async {
                                proxy.scrollTo(lastId, anchor: .center)
                            }
                        }
                        // Fetch notifications when view appears
                        viewModel.notificationManager.fetchNotifications()
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView(settingsManager: viewModel.settingsManager)
        }
        .sheet(isPresented: $viewModel.showNotifications) {
             NotificationListView(notificationManager: viewModel.notificationManager)
        }
    }
    
    private func gameSection(title: String, games: [GameType], geometry: GeometryProxy) -> some View {
        ZStack(alignment: .topLeading) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(games) { game in
                    GameThumbnailView(game: game, onTap: {
                        viewModel.selectGame(game)
                    })
                    .id(game.id)
                }
            }
            .padding()
            .padding(.top, 20)
            .background(Color.white.opacity(0.08))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
            )
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(red: 0.12, green: 0.12, blue: 0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                )
                .cornerRadius(10)
                .offset(x: 24, y: -16)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

#Preview {
    GameSelectionView(viewModel: AppViewModel())
}
