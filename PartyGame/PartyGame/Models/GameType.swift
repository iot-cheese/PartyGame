//
//  GameType.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import Foundation

enum GameType: String, CaseIterable, Identifiable {
    case fiveSecondStop = "5秒ストップ"
    case prefectureGuess = "都道府県当て"
    case grandparentGuess = "おじいちゃんorおばあちゃん"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .fiveSecondStop:
            return "5秒ぴったりでストップできるか挑戦！"
        case .prefectureGuess:
            return "一瞬表示される都道府県の形を当てよう！"
        case .grandparentGuess:
            return "おじいちゃん？おばあちゃん？"
        }
    }
    
    var thumbnailName: String {
        switch self {
        case .fiveSecondStop:
            return "stopwatch"
        case .prefectureGuess:
            return "map"
        case .grandparentGuess:
            return "person.2"
        }
    }
}
