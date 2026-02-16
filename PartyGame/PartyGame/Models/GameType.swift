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
    case samekunCount = "サメくんを数えろ"
    case dragonflyStop = "トンボよ止まれ"
    case wordWolf = "ワードウルフ"
    case penaltyGame = "罰ゲーム"
    case shimoneta = "下ネタを作るな"
    case drawingShiritori = "お絵描きしりとり"
    case senseGame = "感覚ゲーム"
    case secretQuestion = "秘密の質問"
    
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
        case .samekunCount:
            return "通り過ぎるサメくんの数を数えよう！"
        case .dragonflyStop:
            return "円を描いてトンボを呼び寄せよう！"
        case .wordWolf:
            return "みんなとは違うお題が配られているのは誰だ！？"
        case .penaltyGame:
            return "ランダムで選ばれた人が罰ゲーム！"
        case .shimoneta:
            return "禁止文字を回避してターゲットを追い詰めろ！"
        case .drawingShiritori:
            return "お絵描きでしりとりを繋げよう！"
        case .senseGame:
            return "面積、色、文字...瞬時に判断せよ！"
        case .secretQuestion:
            return "みんなに質問して匿名で回答を集めよう！"
        }
    }
    
    var thumbnailName: String {
        switch self {
        case .fiveSecondStop:
            return "stop_5sec_game_icon"
        case .prefectureGuess:
            return "prefectures_game_icon"
        case .grandparentGuess:
            return "grandpa_or_grandma_game_icon"
        case .pitchGuess:
            return "scale_guess_game_icon"
        case .wordFlash:
            return "dosukoi_game_icon"
        case .tomodachi:
            return "tomodachi_game_icon"
        case .samekunCount:
            return "samekun_count_game_icon"
        case .dragonflyStop:
            return "dragonfly_game_icon"
        case .wordWolf:
            return "word_wolf_game_icon"
        case .penaltyGame:
            return "penalty_game_icon"
        case .shimoneta:
            return "shimoneta_game_icon"
        case .drawingShiritori:
            return "drawing_shiritori_game_icon"
        case .senseGame:
            return "sense_game_icon"
        case .secretQuestion:
            return "secret_question_game_icon" // Placeholder
        }
    }
}
