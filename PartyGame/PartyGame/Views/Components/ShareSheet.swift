//
//  ShareSheet.swift
//  PartyGame
//
//  Created by Daniel on 2026/02/16.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    var completion: ((Bool) -> Void)? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        // iPad対応のための設定（もし必要なら）
        // controller.popoverPresentationController?.sourceView = ...
        
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            // シェアが完了した場合、またはキャンセルされた場合（エラーがなければ）
            // UIActivityViewControllerのcompletedは、ユーザーが実際に投稿ボタンを押した場合にtrueになることが多い
            // ただし、一部のアクティビティ（コピーなど）では完了しても通知されないことがある
            // ここでは、ユーザーが何らかのアクションを起こそうとしたらOKとするか、completedを見るか
            
            // 要件は「シェアしたら解禁」なので、基本的には完了を待つ
            if let completion = self.completion {
                completion(completed)
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 更新が必要な場合はここに記述
    }
}
// プレビュー用
#Preview {
    Text("Share Sheet Preview")
        .sheet(isPresented: .constant(true)) {
            ShareSheet(activityItems: ["Test"])
        }
}
