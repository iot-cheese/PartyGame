//
//  SettingsManager.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import Foundation
import Combine

class SettingsManager: ObservableObject {
    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        }
    }
    
    init() {
        self.soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        // デフォルトでサウンドをONに設定（初回起動時）
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            self.soundEnabled = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
}
