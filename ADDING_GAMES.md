# 新しいゲームの追加例

このドキュメントでは、新しいゲームを追加する具体的な例を示します。

## 例: じゃんけんゲームの追加

### ステップ 1: ViewModelの作成

`PartyGame/ViewModels/RockPaperScissorsViewModel.swift` を作成：

```swift
//
//  RockPaperScissorsViewModel.swift
//  PartyGame
//
//  ViewModel for Rock Paper Scissors game
//

import Foundation

class RockPaperScissorsViewModel: ObservableObject {
    @Published var playerChoice: HandSign?
    @Published var computerChoice: HandSign?
    @Published var result: GameResult?
    
    enum HandSign: String, CaseIterable {
        case rock = "✊"
        case paper = "✋"
        case scissors = "✌️"
        
        var name: String {
            switch self {
            case .rock: return "グー"
            case .paper: return "パー"
            case .scissors: return "チョキ"
            }
        }
    }
    
    enum GameResult {
        case win
        case lose
        case draw
        
        var message: String {
            switch self {
            case .win: return "あなたの勝ち！"
            case .lose: return "あなたの負け！"
            case .draw: return "引き分け！"
            }
        }
    }
    
    func play(choice: HandSign) {
        playerChoice = choice
        computerChoice = HandSign.allCases.randomElement()
        
        guard let computer = computerChoice else { return }
        
        if choice == computer {
            result = .draw
        } else if (choice == .rock && computer == .scissors) ||
                  (choice == .paper && computer == .rock) ||
                  (choice == .scissors && computer == .paper) {
            result = .win
        } else {
            result = .lose
        }
    }
    
    func reset() {
        playerChoice = nil
        computerChoice = nil
        result = nil
    }
}
```

### ステップ 2: Viewの作成

`PartyGame/Views/RockPaperScissorsView.swift` を作成：

```swift
//
//  RockPaperScissorsView.swift
//  PartyGame
//
//  Rock Paper Scissors game view
//

import SwiftUI

struct RockPaperScissorsView: View {
    @StateObject private var viewModel = RockPaperScissorsViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("じゃんけんゲーム")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let result = viewModel.result {
                VStack(spacing: 20) {
                    HStack(spacing: 50) {
                        VStack {
                            Text("あなた")
                                .font(.headline)
                            Text(viewModel.playerChoice?.rawValue ?? "")
                                .font(.system(size: 60))
                        }
                        
                        Text("VS")
                            .font(.title)
                            .foregroundColor(.gray)
                        
                        VStack {
                            Text("コンピュータ")
                                .font(.headline)
                            Text(viewModel.computerChoice?.rawValue ?? "")
                                .font(.system(size: 60))
                        }
                    }
                    
                    Text(result.message)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(result == .win ? .green : result == .lose ? .red : .orange)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                }
                .transition(.scale)
            } else {
                Text("手を選んでください")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    ForEach(RockPaperScissorsViewModel.HandSign.allCases, id: \.self) { sign in
                        Button(action: {
                            withAnimation {
                                viewModel.play(choice: sign)
                            }
                        }) {
                            VStack {
                                Text(sign.rawValue)
                                    .font(.system(size: 50))
                                Text(sign.name)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                    }
                }
                
                if viewModel.result != nil {
                    Button(action: {
                        withAnimation {
                            viewModel.reset()
                        }
                    }) {
                        Text("もう一度")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(15)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
    }
}

struct RockPaperScissorsView_Previews: PreviewProvider {
    static var previews: some View {
        RockPaperScissorsView()
    }
}
```

### ステップ 3: GameManagerへの登録

`PartyGame/Models/GameManager.swift` の `registerGames()` メソッドに追加：

```swift
private func registerGames() {
    // 既存のゲーム...
    
    // じゃんけんゲームを追加
    games.append(PartyGameModel(
        name: "じゃんけん",
        description: "コンピュータとじゃんけん勝負！グー・チョキ・パーで勝負しよう！",
        iconName: "hand.raised.fill"
    ) {
        AnyView(RockPaperScissorsView())
    })
}
```

### ステップ 4: Xcodeプロジェクトへの追加

1. Xcodeでプロジェクトを開く
2. `ViewModels`グループに`RockPaperScissorsViewModel.swift`を追加
3. `Views`グループに`RockPaperScissorsView.swift`を追加
4. ビルドして実行

## 他のゲームアイデア

### 1. タイマーゲーム
```swift
// 制限時間内にボタンを連打するゲーム
@Published var count: Int = 0
@Published var timeRemaining: Int = 10
@Published var isPlaying: Bool = false
```

### 2. ルーレット
```swift
// 複数の選択肢からランダムに一つ選ぶ
@Published var options: [String] = []
@Published var selectedOption: String?
@Published var isSpinning: Bool = false
```

### 3. ドリンクゲーム
```swift
// ドリンクを飲む順番や量をランダムに決定
@Published var players: [String] = []
@Published var selectedPlayer: String?
@Published var drinkAmount: Int = 0
```

### 4. 罰ゲームルーレット
```swift
// 様々な罰ゲームからランダムに選択
@Published var penalties: [String] = []
@Published var selectedPenalty: String?
```

## ベストプラクティス

1. **ViewModelはUIに依存しない**
   - SwiftUIのViewをimportしない
   - Foundationのみを使用

2. **状態管理は@Publishedで**
   - UIに反映したい値はすべて@Publishedにする
   - プライベートなロジックは通常のメソッドで実装

3. **アニメーションはViewで**
   - withAnimation()を使用してスムーズな遷移を実現
   - ViewModelは状態の変更のみを担当

4. **適切な命名**
   - ファイル名: `XxxViewModel.swift`, `XxxView.swift`
   - クラス名: `XxxViewModel`, `XxxView`

5. **SF Symbolsの活用**
   - 一貫したアイコンデザイン
   - https://developer.apple.com/sf-symbols/

## まとめ

新しいゲームの追加は3つのステップで完了：
1. ViewModelを作成してロジックを実装
2. Viewを作成してUIを実装
3. GameManagerに登録

この設計により、ゲームを独立して開発でき、既存のコードに影響を与えません。
