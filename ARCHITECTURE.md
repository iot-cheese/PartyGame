# アーキテクチャ設計書

## MVVM アーキテクチャの実装

このプロジェクトは、SwiftUIを使用したMVVMパターンを採用しています。

### 構造図

```
┌─────────────────────────────────────────────────┐
│                  ContentView                     │
│              (メインメニュー)                     │
│   - GameManager.shared からゲーム一覧を表示      │
└─────────────────────────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────┐
        │      GameManager          │
        │   (シングルトン)           │
        │  - games: [PartyGameModel]│
        │  - registerGames()        │
        └───────────────────────────┘
                        │
        ┌───────────────┴────────────────┬──────────────┐
        ▼                                 ▼              ▼
┌──────────────┐              ┌──────────────┐  ┌──────────────┐
│TruthOrDareView│             │RandomNumberView│ │TeamDividerView│
│              │              │                │ │              │
└──────────────┘              └──────────────┘  └──────────────┘
        │                              │                │
        ▼                              ▼                ▼
┌──────────────┐              ┌──────────────┐  ┌──────────────┐
│TruthOrDare   │              │RandomNumber  │  │TeamDivider   │
│ViewModel     │              │ViewModel     │  │ViewModel     │
└──────────────┘              └──────────────┘  └──────────────┘
```

## 各レイヤーの責務

### Model層
- **Game.swift**: ゲームの共通プロトコルを定義
- **GameManager.swift**: ゲームの登録と管理を行うシングルトン

### ViewModel層
各ゲームのビジネスロジックを実装：
- **TruthOrDareViewModel**: 質問と挑戦のランダム選択ロジック
- **RandomNumberViewModel**: 数字生成とアニメーションの状態管理
- **TeamDividerViewModel**: チーム分けのアルゴリズム実装

### View層
SwiftUIで実装されたユーザーインターフェース：
- **ContentView**: メインのナビゲーション画面
- 各ゲームView: ViewModelを監視して状態変化に応じてUIを更新

## データフロー

```
User Action → View → ViewModel → Model
                ↑                  │
                └──────────────────┘
                  State Change
                  (@Published)
```

## 拡張性の設計

### 新しいゲームの追加手順

1. **ViewModelの作成**
   - `ObservableObject`プロトコルに準拠
   - `@Published`プロパティでUI状態を管理

2. **Viewの作成**
   - SwiftUIで実装
   - `@StateObject`でViewModelを保持

3. **GameManagerへの登録**
   - `registerGames()`メソッドに新しいゲームを追加
   - 自動的にメニューに表示される

### プロトコル指向設計

```swift
protocol Game: Identifiable {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var iconName: String { get }
    var viewBuilder: () -> AnyView { get }
}
```

このプロトコルにより、すべてのゲームが統一されたインターフェースを持ち、
新しいゲームの追加が容易になります。

## Swift/SwiftUIの機能活用

- **@StateObject**: ViewModelのライフサイクル管理
- **@Published**: リアクティブな状態更新
- **NavigationView/NavigationLink**: 画面遷移
- **SF Symbols**: システムアイコンの利用
- **アニメーション**: withAnimation()による滑らかなUI変更

## テストしやすい設計

- ViewModelはViewから独立しており、単体テストが可能
- ビジネスロジックがViewから分離されている
- 依存性が明確で、モックの作成が容易
