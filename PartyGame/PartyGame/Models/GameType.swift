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
    case pitchGuess = "音階当て"
    case wordFlash = "単語ひらめき"
    case tomodachi = "ともだち"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .fiveSecondStop:
            return "5秒ぴったりでストップできるか挑戦！"
        case .prefectureGuess:
            return "一瞬表示される都道府県の形を当てよう！"
        case .grandparentGuess:
            return "おじいちゃん？おばあちゃん？"
        case .pitchGuess:
            return "流れた音階を当てよう！"
        case .wordFlash:
            return "ひらめけ！制限時間内に単語を答えよう！"
        case .tomodachi:
            return "宇宙人と心を通わせるんだ！"
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
        case .pitchGuess:
            return "music.note"
        case .wordFlash:
            return "character.bubble"
        case .tomodachi:
            return "hand.point.up.fill"
        }
    }
}
