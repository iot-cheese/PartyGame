//
//  GameSelectionView.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import SwiftUI

struct GameSelectionView: View {
    @ObservedObject var viewModel: AppViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                NavigationView {
                    ScrollView {
                        VStack {
                            Text("ゲーム選択")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 50)
                                .padding(.bottom, -20)
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(GameType.allCases) { game in
                                    GameThumbnailView(game: game, onTap: {
                                        viewModel.selectGame(game)
                                    })
                                }
                            }
                            .padding()
                        }
                    }
                    .background(
                        Image("game_selection_background")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                    )
                    .edgesIgnoringSafeArea(.all)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.title2)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView(settingsManager: viewModel.settingsManager)
        }
    }
}

#Preview {
    GameSelectionView(viewModel: AppViewModel())
}
