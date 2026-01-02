//
//  MusicalNote.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/02.
//

import Foundation

enum MusicalNote: String, CaseIterable {
    // 3オクターブ分の音階（C3からC5まで）
    case c3 = "ド（低）"
    case d3 = "レ（低）"
    case e3 = "ミ（低）"
    case f3 = "ファ（低）"
    case g3 = "ソ（低）"
    case a3 = "ラ（低）"
    case b3 = "シ（低）"
    
    case c4 = "ド"
    case d4 = "レ"
    case e4 = "ミ"
    case f4 = "ファ"
    case g4 = "ソ"
    case a4 = "ラ"
    case b4 = "シ"
    
    case c5 = "ド（高）"
    case d5 = "レ（高）"
    case e5 = "ミ（高）"
    case f5 = "ファ（高）"
    case g5 = "ソ（高）"
    case a5 = "ラ（高）"
    case b5 = "シ（高）"
    
    var soundFileName: String {
        return rawValue.replacingOccurrences(of: "（", with: "_")
            .replacingOccurrences(of: "）", with: "")
            .lowercased()
    }
    
    var frequency: Double {
        // 各音の周波数（Hz）
        switch self {
        case .c3: return 130.81
        case .d3: return 146.83
        case .e3: return 164.81
        case .f3: return 174.61
        case .g3: return 196.00
        case .a3: return 220.00
        case .b3: return 246.94
        case .c4: return 261.63
        case .d4: return 293.66
        case .e4: return 329.63
        case .f4: return 349.23
        case .g4: return 392.00
        case .a4: return 440.00
        case .b4: return 493.88
        case .c5: return 523.25
        case .d5: return 587.33
        case .e5: return 659.25
        case .f5: return 698.46
        case .g5: return 783.99
        case .a5: return 880.00
        case .b5: return 987.77
        }
    }
}
