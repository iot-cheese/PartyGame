//
//  GameResult.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import Foundation

enum GameResult {
    case success
    case failure
    
    var message: String {
        switch self {
        case .success:
            return "成功！"
        case .failure:
            return "失敗..."
        }
    }
}
