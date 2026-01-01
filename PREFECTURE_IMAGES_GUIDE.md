# 都道府県画像の追加方法

## 概要
都道府県当てゲームで使用する都道府県の形の画像を追加する方法を説明します。

## 画像の入手方法

### 推奨: Wikimedia Commonsから入手
以下のURLから各都道府県のシルエット画像をダウンロードできます：
https://commons.wikimedia.org/wiki/Category:Shadow_picture_maps_of_prefectures_of_Japan

### 画像のダウンロード手順
1. 上記URLにアクセス
2. 各都道府県の画像（例: "Shadow picture of Tokyo prefecture.png"）をクリック
3. "Download" ボタンから画像をダウンロード
4. 必要に応じてPNG形式に変換

## 画像の追加方法

### 1. Assets.xcassetsに画像を追加
1. Xcodeで `PartyGame/Assets.xcassets` を開く
2. 左下の「+」ボタンをクリック → "New Image Set" を選択
3. 以下の命名規則で画像セットを作成：
   - 北海道: `hokkaido`
   - 青森県: `aomori`
   - 岩手県: `iwate`
   - 宮城県: `miyagi`
   - 秋田県: `akita`
   - 山形県: `yamagata`
   - 福島県: `fukushima`
   - 茨城県: `ibaraki`
   - 栃木県: `tochigi`
   - 群馬県: `gunma`
   - 埼玉県: `saitama`
   - 千葉県: `chiba`
   - 東京都: `tokyo`
   - 神奈川県: `kanagawa`
   - 新潟県: `niigata`
   - 富山県: `toyama`
   - 石川県: `ishikawa`
   - 福井県: `fukui`
   - 山梨県: `yamanashi`
   - 長野県: `nagano`
   - 岐阜県: `gifu`
   - 静岡県: `shizuoka`
   - 愛知県: `aichi`
   - 三重県: `mie`
   - 滋賀県: `shiga`
   - 京都府: `kyoto`
   - 大阪府: `osaka`
   - 兵庫県: `hyogo`
   - 奈良県: `nara`
   - 和歌山県: `wakayama`
   - 鳥取県: `tottori`
   - 島根県: `shimane`
   - 岡山県: `okayama`
   - 広島県: `hiroshima`
   - 山口県: `yamaguchi`
   - 徳島県: `tokushima`
   - 香川県: `kagawa`
   - 愛媛県: `ehime`
   - 高知県: `kochi`
   - 福岡県: `fukuoka`
   - 佐賀県: `saga`
   - 長崎県: `nagasaki`
   - 熊本県: `kumamoto`
   - 大分県: `oita`
   - 宮崎県: `miyazaki`
   - 鹿児島県: `kagoshima`
   - 沖縄県: `okinawa`

4. 各画像セットにダウンロードした画像をドラッグ&ドロップ

### 2. PrefectureGuessView.swiftを更新
画像を追加したら、`PrefectureGuessView.swift` の以下の部分を更新：

```swift
// 変更前（プレースホルダー）
Image(systemName: "map.fill")
    .resizable()
    .aspectRatio(contentMode: .fit)
    .frame(width: 250, height: 250)
    .foregroundColor(.green)

// 変更後（実際の画像）
if let imageName = prefecture.imageName {
    Image(imageName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 250, height: 250)
}
```

## 注意事項
- 画像はパブリックドメインまたはクリエイティブ・コモンズライセンスのものを使用してください
- 各画像のサイズは統一することを推奨（例: 500x500px程度）
- 背景は透明にすることを推奨

## ライセンス情報
Wikimedia Commonsの画像を使用する場合は、各画像のライセンス情報を確認し、
必要に応じて適切なクレジット表記を行ってください。
