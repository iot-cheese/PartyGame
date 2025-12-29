# 開発ガイド

## セットアップ

### 必要な環境
- macOS 13.0以上
- Xcode 14.0以上
- iOS 16.0以上のシミュレータまたは実機

### プロジェクトのオープン

```bash
# リポジトリのクローン
git clone https://github.com/iot-cheese/PartyGame.git
cd PartyGame

# Xcodeで開く
open PartyGame.xcodeproj
```

## ビルドと実行

### シミュレータで実行

1. Xcodeでプロジェクトを開く
2. ツールバーからシミュレータを選択（例: iPhone 14 Pro）
3. `⌘ + R` を押すか、「Run」ボタンをクリック

### 実機で実行

1. iPhoneをMacに接続
2. Xcodeの「Signing & Capabilities」タブで開発チームを選択
3. デバイスを選択
4. `⌘ + R` を押してビルド＆実行

## コーディング規約

### Swift Style Guide
- インデント: スペース4つ
- 命名規則: キャメルケース（camelCase）
- クラス名: パスカルケース（PascalCase）

### ファイル構造
```
ファイル名とクラス名は一致させる
例: TruthOrDareViewModel.swift → class TruthOrDareViewModel
```

### コメント
```swift
// 簡単な説明は一行コメント

/// 公開APIには詳細なドキュメントコメント
/// - Parameters:
///   - parameter: パラメータの説明
/// - Returns: 戻り値の説明
func publicMethod(parameter: String) -> Bool {
    // 実装
}
```

## デバッグ

### プリントデバッグ
```swift
print("Debug: \(variable)")
```

### ブレークポイント
1. コードの左側をクリックしてブレークポイントを設定
2. `⌘ + R` でデバッグ実行
3. ブレークポイントで停止したら変数を確認

### SwiftUI Preview
各Viewファイルの下部にプレビューコードがあります：
```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

Xcode右側の「Canvas」でプレビューを確認できます。

## テスト

### ユニットテストの追加（今後）
```swift
import XCTest
@testable import PartyGame

class TruthOrDareViewModelTests: XCTestCase {
    var viewModel: TruthOrDareViewModel!
    
    override func setUp() {
        viewModel = TruthOrDareViewModel()
    }
    
    func testSelectTruth() {
        viewModel.selectTruth()
        XCTAssertFalse(viewModel.currentPrompt.isEmpty)
        XCTAssertEqual(viewModel.promptType, .truth)
    }
}
```

## トラブルシューティング

### ビルドエラー

**エラー: "No such module 'SwiftUI'"**
- Xcode 14以上を使用していることを確認
- iOS Deployment Target を 16.0 に設定

**エラー: "Command CompileSwiftSources failed"**
- `⌘ + Shift + K` でクリーンビルド
- Derived Data を削除: `~/Library/Developer/Xcode/DerivedData`

### シミュレータの問題

**シミュレータが起動しない**
```bash
# シミュレータをリセット
xcrun simctl shutdown all
xcrun simctl erase all
```

**アプリが表示されない**
- シミュレータのホーム画面で探す
- ビルドログでエラーを確認

## バージョン管理

### コミットメッセージの規約
```
形式: <type>: <subject>

type:
- feat: 新機能
- fix: バグ修正
- docs: ドキュメント
- refactor: リファクタリング
- test: テスト追加

例:
feat: Add rock paper scissors game
fix: Fix team divider crash on empty input
docs: Update README with installation instructions
```

### ブランチ戦略
```
main: 本番環境用
develop: 開発用
feature/xxx: 機能追加用
bugfix/xxx: バグ修正用
```

## パフォーマンス最適化

### SwiftUIのベストプラクティス

1. **@State vs @StateObject**
   - `@State`: シンプルな値型
   - `@StateObject`: ObservableObject

2. **リストの最適化**
   ```swift
   List(items) { item in
       // 各アイテムにIDが必要
   }
   ```

3. **重い処理はバックグラウンドで**
   ```swift
   DispatchQueue.global(qos: .userInitiated).async {
       // 重い処理
       DispatchQueue.main.async {
           // UI更新
       }
   }
   ```

## リリース準備

### App Storeへの提出前

1. **バージョン番号の更新**
   - `Info.plist` の `CFBundleShortVersionString`
   - `CFBundleVersion`

2. **アイコンの追加**
   - `Assets.xcassets/AppIcon.appiconset`
   - 必要なサイズ: 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024

3. **スクリーンショット撮影**
   - iPhone 6.7" (iPhone 14 Pro Max)
   - iPhone 6.5" (iPhone 11 Pro Max)
   - iPhone 5.5" (iPhone 8 Plus)
   - iPad Pro 12.9"

4. **プライバシー設定の確認**
   - 収集するデータの明記
   - 利用規約とプライバシーポリシー

## 参考リンク

- [Swift公式ドキュメント](https://swift.org/documentation/)
- [SwiftUIチュートリアル](https://developer.apple.com/tutorials/swiftui)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

## サポート

問題が発生した場合は、GitHubのIssuesで報告してください。
