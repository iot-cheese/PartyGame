//
//  Game.swift
//  PartyGame
//
//  Game protocol for extensibility
//

import Foundation
import SwiftUI

/// Protocol that all party games must conform to
protocol Game: Identifiable {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var iconName: String { get }
    var viewBuilder: () -> AnyView { get }
}

/// Concrete game model
struct PartyGameModel: Game {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let viewBuilder: () -> AnyView
    
    init(id: UUID = UUID(),
         name: String,
         description: String,
         iconName: String,
         viewBuilder: @escaping () -> AnyView) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.viewBuilder = viewBuilder
    }
}
