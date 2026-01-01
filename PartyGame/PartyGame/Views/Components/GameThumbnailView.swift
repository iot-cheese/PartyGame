//
//  GameThumbnailView.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import SwiftUI

struct GameThumbnailView: View {
    let game: GameType
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: game.thumbnailName)
                .font(.system(size: 60))
                .foregroundColor(.white)
                .frame(width: 120, height: 120)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(radius: 5)
            
            Text(game.rawValue)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(game.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 300)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview {
    GameThumbnailView(game: .fiveSecondStop)
}
