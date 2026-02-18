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
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("サウンド設定")) {
                    Toggle(isOn: $settingsManager.soundEnabled) {
                        HStack {
                            Image(systemName: settingsManager.soundEnabled ? "speaker.wave.3" : "speaker.slash")
                                .foregroundColor(settingsManager.soundEnabled ? .blue : .gray)
                            Text("アプリ内サウンド")
                        }
                    }
                }
                
                Section(header: Text("データ管理")) {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("保存されたメンバー情報を削除")
                        }
                    }
                }
                
                Section(header: Text("情報")) {
                    Button {
                        if let url = URL(string: "https://sato-monaka.github.io/PartyGame/TermsAndConditions.html") {
                            #if os(iOS)
                            UIApplication.shared.open(url)
                            #endif
                        }
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("利用規約")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button {
                        if let url = URL(string: "https://sato-monaka.github.io/PartyGame/PrivacyPolicy.html") {
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
                    
                    HStack {
                        Spacer()
                        Text("バージョン 1.0.0")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
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
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("確認"),
                    message: Text("すべてのゲームの保存されたメンバー情報を削除しますか？\nこの操作は取り消せません。"),
                    primaryButton: .destructive(Text("削除")) {
                        settingsManager.resetAllGameData()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

#Preview {
    SettingsView(settingsManager: SettingsManager())
}
