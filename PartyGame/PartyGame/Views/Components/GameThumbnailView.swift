//
//  GameThumbnailView.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import SwiftUI

struct GameThumbnailView: View {
    let game: GameType
    let isLocked: Bool
    let onTap: () -> Void
    
    @State private var pressed: Bool = false
    
    init(game: GameType, isLocked: Bool = false, onTap: @escaping () -> Void) {
        self.game = game
        self.isLocked = isLocked
        self.onTap = onTap
    }
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
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
                    .grayscale(isLocked ? 1.0 : 0.0)
                    .opacity(isLocked ? 0.6 : 1.0)
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 0)
                }
            }
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
