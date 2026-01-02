//
//  WordChallenge.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/02.
//

import Foundation

struct WordChallenge {
    let hiragana: String
    let wordCount: Int
    
    var timeLimit: Int {
        // 4文字以内は5秒、5文字以上は10秒
        return wordCount <= 4 ? 5 : 10
    }
    
    static func generateRandom() -> WordChallenge {
        // ひらがな一覧（濁音・半濁音を含む、「ん」を除く）
        let hiraganaList = [
            // 清音
            "あ", "い", "う", "え", "お",
            "か", "き", "く", "け", "こ",
            "さ", "し", "す", "せ", "そ",
            "た", "ち", "つ", "て", "と",
            "な", "に", "ぬ", "ね", "の",
            "は", "ひ", "ふ", "へ", "ほ",
            "ま", "み", "む", "め", "も",
            "や", "ゆ", "よ",
            "ら", "り", "る", "れ", "ろ",
            "わ",
            // 濁音
            "が", "ぎ", "ぐ", "げ", "ご",
            "ざ", "じ", "ず", "ぜ", "ぞ",
            "だ", "ぢ", "で", "ど",
            "ば", "び", "ぶ", "べ", "ぼ",
            // 半濁音
            "ぱ", "ぴ", "ぷ", "ぺ", "ぽ"
        ]
        
        let randomHiragana = hiraganaList.randomElement() ?? "あ"
        
        // 文字数の確率分布
        // 2-4文字: 66.7%、5-6文字: 26.7%、7-9文字: 6.7%
        let randomValue = Double.random(in: 0...1)
        let randomWordCount: Int
        
        if randomValue < 0.667 {
            // 2-4文字 (66.7%)
            randomWordCount = Int.random(in: 2...4)
        } else if randomValue < 0.933 {
            // 5-6文字 (26.7%)
            randomWordCount = Int.random(in: 5...6)
        } else {
            // 7-9文字 (6.7%)
            randomWordCount = Int.random(in: 7...9)
        }
        
        return WordChallenge(hiragana: randomHiragana, wordCount: randomWordCount)
    }
}
