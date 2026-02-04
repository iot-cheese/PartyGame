//
//  ContentView.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else {
                if let selectedGame = viewModel.selectedGame {
                    NavigationView {
                        gameView(for: selectedGame)
                    }
                } else {
                    GameSelectionView(viewModel: viewModel)
                }
            }
        }
    }
    
    @ViewBuilder
    private func gameView(for game: GameType) -> some View {
        switch game {
        case .fiveSecondStop:
            FiveSecondStopView(appViewModel: viewModel)
        case .prefectureGuess:
            PrefectureGuessView(appViewModel: viewModel)
        case .grandparentGuess:
            GrandparentGuessView(appViewModel: viewModel)
        case .pitchGuess:
            PitchGuessView(appViewModel: viewModel)
        case .wordFlash:
            WordFlashView(appViewModel: viewModel)
        case .tomodachi:
            TomodachiGameView(appViewModel: viewModel)
        case .samekunCount:
            SamekunCountView(appViewModel: viewModel)
        case .dragonflyStop:
            DragonflyStopView(appViewModel: viewModel)
        case .wordWolf:
            WordWolfView(appViewModel: viewModel)
        case .penaltyGame:
            PenaltyGameView(appViewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
