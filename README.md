# PartyGame (パーティーゲーム)

日本語のパーティーゲームアプリケーションです。友達や家族と一緒に楽しめる複数のゲームが含まれています。

## 概要

このアプリは、パーティーで使える楽しいゲームを集めたiOSアプリです。インターネット接続は不要で、すべての機能がiPhone上で完結します。

## アーキテクチャ

このプロジェクトは**MVVM（Model-View-ViewModel）**アーキテクチャで設計されています：

- **Models**: ゲームのデータモデルとロジック（`PartyGame/Models/`）
- **ViewModels**: ビジネスロジックとデータ処理（`PartyGame/ViewModels/`）
- **Views**: SwiftUIを使用したユーザーインターフェース（`PartyGame/Views/`）

## プロジェクト構造

```
PartyGame/
├── PartyGame.xcodeproj/          # Xcodeプロジェクトファイル
└── PartyGame/
    ├── PartyGameApp.swift        # アプリのエントリーポイント
    ├── Info.plist                # アプリ設定
    ├── Models/
    │   ├── Game.swift            # ゲームプロトコルとモデル
    │   └── GameManager.swift     # ゲーム管理クラス
    ├── ViewModels/
    │   ├── TruthOrDareViewModel.swift
    │   ├── RandomNumberViewModel.swift
    │   └── TeamDividerViewModel.swift
    ├── Views/
    │   ├── ContentView.swift     # メインメニュー
    │   ├── TruthOrDareView.swift
    │   ├── RandomNumberView.swift
    │   └── TeamDividerView.swift
    └── Assets.xcassets/          # アプリアセット
```

## 含まれているゲーム

### 1. 真実か挑戦か (Truth or Dare)
クラシックなパーティーゲーム。プレイヤーは「真実」または「挑戦」を選択し、質問やタスクに答えます。

### 2. ランダム選択 (Random Number Generator)
指定された範囲内でランダムな数字を生成します。順番決めや当選者の選出に便利です。

### 3. チーム分け (Team Divider)
参加者を自動的にランダムなチームに分けます。スポーツやゲームの前に便利です。

## 新しいゲームの追加方法

このアプリは拡張しやすい設計になっています。新しいゲームを追加するには：

### 1. ViewModelを作成
```swift
// PartyGame/ViewModels/YourGameViewModel.swift
import Foundation

class YourGameViewModel: ObservableObject {
    @Published var gameState: String = ""
    
    func startGame() {
        // ゲームロジックをここに実装
    }
}
```

### 2. Viewを作成
```swift
// PartyGame/Views/YourGameView.swift
import SwiftUI

struct YourGameView: View {
    @StateObject private var viewModel = YourGameViewModel()
    
    var body: some View {
        VStack {
            Text("Your Game")
                .font(.largeTitle)
            // UIをここに実装
        }
    }
}
```

### 3. GameManagerに登録
```swift
// PartyGame/Models/GameManager.swift の registerGames() メソッドに追加
games.append(PartyGameModel(
    name: "あなたのゲーム名",
    description: "ゲームの説明",
    iconName: "star.fill"  // SF Symbolsアイコン
) {
    AnyView(YourGameView())
})
```

## 必要環境

- iOS 16.0以上
- Xcode 14.0以上
- Swift 5.0以上

## ビルドと実行

1. Xcodeでプロジェクトを開く：
   ```bash
   open PartyGame.xcodeproj
   ```

2. シミュレータまたは実機を選択

3. ⌘ + R でビルドして実行

## 技術スタック

- **SwiftUI**: 宣言的なUI構築
- **Combine**: リアクティブプログラミング（@Published プロパティ経由）
- **MVVM**: クリーンなアーキテクチャパターン
- **プロトコル指向設計**: 拡張可能なゲームシステム

## ライセンス

このプロジェクトはオープンソースです。

## 今後の拡張アイデア

- より多くのゲームの追加
- ゲーム設定のカスタマイズ
- ダークモード対応
- アニメーション効果の追加
- 多言語対応（英語、中国語など）
- ゲーム履歴の保存