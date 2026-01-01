//
//  SettingsView.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settingsManager: SettingsManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("サウンド設定")) {
                    Toggle(isOn: $settingsManager.soundEnabled) {
                        HStack {
                            Image(systemName: settingsManager.soundEnabled ? "speaker.wave.3" : "speaker.slash")
                                .foregroundColor(settingsManager.soundEnabled ? .blue : .gray)
                            Text("効果音")
                        }
                    }
                }
                
                Section(header: Text("情報")) {
                    Button {
                        if let url = URL(string: "https://example.com/privacy-policy") {
                            // 実際にはSafariViewControllerなどで開く
                            #if os(iOS)
                            UIApplication.shared.open(url)
                            #endif
                        }
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised")
                            Text("プライバシーポリシー")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(settingsManager: SettingsManager())
}
