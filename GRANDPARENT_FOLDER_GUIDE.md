# GrandpaOrGrandmaフォルダ内の画像の追加方法

## フォルダ構成

Assets.xcassetsに以下の構造で画像を追加してください：

```
Assets.xcassets/
└── GrandpaOrGrandma/
    ├── Grandpa/
    │   ├── grandpa_1.imageset/
    │   ├── grandpa_2.imageset/
    │   ├── ...
    │   └── grandpa_N.imageset/
    └── Grandma/
        ├── grandma_1.imageset/
        ├── grandma_2.imageset/
        ├── ...
        └── grandma_N.imageset/
```

## 画像の追加手順

### 1. Xcodeでフォルダを開く
1. Xcodeで `Assets.xcassets` を開く
2. `GrandpaOrGrandma` フォルダが既に作成されています

### 2. おじいちゃん画像を追加
1. `GrandpaOrGrandma/Grandpa` フォルダを選択
2. 左下の「+」ボタン → "New Image Set" を選択
3. 画像セット名を `grandpa_1`, `grandpa_2`, ... と命名
4. 各画像セットに画像をドラッグ&ドロップ

### 3. おばあちゃん画像を追加
1. `GrandpaOrGrandma/Grandma` フォルダを選択
2. 左下の「+」ボタン → "New Image Set" を選択
3. 画像セット名を `grandma_1`, `grandma_2`, ... と命名
4. 各画像セットに画像をドラッグ&ドロップ

## 重要なポイント

### 命名規則
- おじいちゃん: `grandpa_1`, `grandpa_2`, `grandpa_3`, ...
- おばあちゃん: `grandma_1`, `grandma_2`, `grandma_3`, ...
- 番号は1から連番で付けてください

### 自動検出
- アプリは自動的に `grandpa_1` ~ `grandpa_100` と `grandma_1` ~ `grandma_100` の範囲で画像を検索します
- 存在する画像のみがゲームに使用されます
- 何枚でも追加可能（最大各100枚まで）

### 画像の推奨仕様
- フォーマット: PNG または JPG
- サイズ: 正方形（例: 500x500px程度）
- 内容: おじいちゃん・おばあちゃんの顔写真やイラスト

## 例

おじいちゃん画像を5枚、おばあちゃん画像を3枚追加した場合：
- `GrandpaOrGrandma/Grandpa/grandpa_1`
- `GrandpaOrGrandma/Grandpa/grandpa_2`
- `GrandpaOrGrandma/Grandpa/grandpa_3`
- `GrandpaOrGrandma/Grandpa/grandpa_4`
- `GrandpaOrGrandma/Grandpa/grandpa_5`
- `GrandpaOrGrandma/Grandma/grandma_1`
- `GrandpaOrGrandma/Grandma/grandma_2`
- `GrandpaOrGrandma/Grandma/grandma_3`

→ これらの8枚からランダムに1枚が表示されます

## 画像の入手方法

- いらすとや (https://www.irasutoya.com/)
- Pixabay (https://pixabay.com/)
- Unsplash (https://unsplash.com/)
- AI画像生成ツール（Stable Diffusion, Midjourney, DALL-E）

## 注意事項
- 著作権・肖像権に注意してください
- 商用利用可能な素材を使用してください
- 各画像は見分けがつく程度に多様性を持たせてください
