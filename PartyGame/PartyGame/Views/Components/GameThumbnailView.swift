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
                .font(.system(size: 45))
                .foregroundColor(.white)
                .frame(width: 100, height: 100)
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
                .font(.title3)
                .fontWeight(.bold)
            
            Text(game.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview {
    GameThumbnailView(game: .fiveSecondStop)
}
