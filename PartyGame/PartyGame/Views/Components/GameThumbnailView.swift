//
//  GameThumbnailView.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import SwiftUI

struct GameThumbnailView: View {
    let game: GameType
    let onTap: () -> Void
    
    @State private var pressed: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            Image(game.thumbnailName)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(radius: 5)
                .scaleEffect(pressed ? 0.9 : 1.0)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cornerRadius(15)
        .contentShape(Rectangle())
        .onTapGesture {
            pressed = true
            withAnimation(.easeInOut(duration: 0.1)) {
                pressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    pressed = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onTap()
                }
            }
        }
    }
}

#Preview {
    GameThumbnailView(game: .fiveSecondStop, onTap: {})
}
