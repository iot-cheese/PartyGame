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
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(GameType.allCases) { game in
                        GameThumbnailView(game: game)
                            .onTapGesture {
                                viewModel.selectGame(game)
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("ゲーム選択")
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
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView(settingsManager: viewModel.settingsManager)
        }
    }
}

#Preview {
    GameSelectionView(viewModel: AppViewModel())
}
