//
//  ContentView.swift
//  PartyGame
//
//  Main menu view
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager.shared
    
    var body: some View {
        NavigationView {
            List(gameManager.games) { game in
                NavigationLink(destination: game.viewBuilder()) {
                    HStack(spacing: 15) {
                        Image(systemName: game.iconName)
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                            .frame(width: 50)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(game.name)
                                .font(.headline)
                            Text(game.description)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("パーティーゲーム")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
