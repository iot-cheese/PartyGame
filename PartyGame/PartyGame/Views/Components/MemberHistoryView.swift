//
//  MemberHistoryView.swift
//  PartyGame
//
//  Created by Daniel on 2026/02/17.
//

import SwiftUI

struct MemberHistoryView: View {
    @ObservedObject var settingsManager: SettingsManager
    let gameId: String
    let onSelect: ([String]) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if let histories = settingsManager.memberHistory[gameId], !histories.isEmpty {
                    List {
                        ForEach(Array(histories.enumerated()), id: \.offset) { index, members in
                            Button(action: {
                                onSelect(members)
                                dismiss()
                            }) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("\(index + 1)番目の履歴")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text(members.joined(separator: ", "))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                settingsManager.deleteHistory(gameId: gameId, at: index)
                            }
                        }
                    }
                } else {
                    Spacer()
                    Text("履歴はありません")
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .navigationTitle("メンバー履歴")
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
            .toolbar {
                EditButton()
            }
        }
    }
}
