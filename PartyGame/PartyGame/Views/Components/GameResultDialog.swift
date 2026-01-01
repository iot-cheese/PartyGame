//
//  GameResultDialog.swift
//  PartyGame
//
//  Created by Daniel on 2025/12/29.
//

import SwiftUI

struct GameResultDialog: View {
    @Environment(\.dismiss) var dismiss
    let result: GameResult
    let elapsedTime: Double?
    let onContinue: () -> Void
    let onBackToSelection: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // 結果アイコン
                Image(systemName: result == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(result == .success ? .green : .red)
                
                // 結果テキスト
                Text(result.message)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // ストップした秒数を表示（5秒ストップゲーム用）
                if let time = elapsedTime {
                    VStack(spacing: 8) {
                        Text(String(format: "%.2f秒", time))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.primary)
                        
                        let difference = abs(time - 5.0)
                        Text("誤差: \(String(format: "%.2f", difference))秒")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // ボタン
                VStack(spacing: 15) {
                    Button {
                        dismiss()
                        onContinue()
                    } label: {
                        Text("ゲームを続ける")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    
                    Button {
                        dismiss()
                        onBackToSelection()
                    } label: {
                        Text("別のゲームを選択")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            .navigationTitle("結果")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    GameResultDialog(
        result: .success,
        elapsedTime: 5.12,
        onContinue: {},
        onBackToSelection: {}
    )
}
