//
//  Prefecture.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/01.
//

import Foundation

struct Prefecture: Identifiable {
    let id: Int
    let name: String
    let imageName: String
    
    static let all: [Prefecture] = [
        Prefecture(id: 1, name: "北海道", imageName: "hokkaido"),
        Prefecture(id: 2, name: "青森県", imageName: "aomori"),
        Prefecture(id: 3, name: "岩手県", imageName: "iwate"),
        Prefecture(id: 4, name: "宮城県", imageName: "miyagi"),
        Prefecture(id: 5, name: "秋田県", imageName: "akita"),
        Prefecture(id: 6, name: "山形県", imageName: "yamagata"),
        Prefecture(id: 7, name: "福島県", imageName: "fukushima"),
        Prefecture(id: 8, name: "茨城県", imageName: "ibaraki"),
        Prefecture(id: 9, name: "栃木県", imageName: "tochigi"),
        Prefecture(id: 10, name: "群馬県", imageName: "gunma"),
        Prefecture(id: 11, name: "埼玉県", imageName: "saitama"),
        Prefecture(id: 12, name: "千葉県", imageName: "chiba"),
        Prefecture(id: 13, name: "東京都", imageName: "tokyo"),
        Prefecture(id: 14, name: "神奈川県", imageName: "kanagawa"),
        Prefecture(id: 15, name: "新潟県", imageName: "niigata"),
        Prefecture(id: 16, name: "富山県", imageName: "toyama"),
        Prefecture(id: 17, name: "石川県", imageName: "ishikawa"),
        Prefecture(id: 18, name: "福井県", imageName: "fukui"),
        Prefecture(id: 19, name: "山梨県", imageName: "yamanashi"),
        Prefecture(id: 20, name: "長野県", imageName: "nagano"),
        Prefecture(id: 21, name: "岐阜県", imageName: "gifu"),
        Prefecture(id: 22, name: "静岡県", imageName: "shizuoka"),
        Prefecture(id: 23, name: "愛知県", imageName: "aichi"),
        Prefecture(id: 24, name: "三重県", imageName: "mie"),
        Prefecture(id: 25, name: "滋賀県", imageName: "shiga"),
        Prefecture(id: 26, name: "京都府", imageName: "kyoto"),
        Prefecture(id: 27, name: "大阪府", imageName: "osaka"),
        Prefecture(id: 28, name: "兵庫県", imageName: "hyogo"),
        Prefecture(id: 29, name: "奈良県", imageName: "nara"),
        Prefecture(id: 30, name: "和歌山県", imageName: "wakayama"),
        Prefecture(id: 31, name: "鳥取県", imageName: "tottori"),
        Prefecture(id: 32, name: "島根県", imageName: "shimane"),
        Prefecture(id: 33, name: "岡山県", imageName: "okayama"),
        Prefecture(id: 34, name: "広島県", imageName: "hiroshima"),
        Prefecture(id: 35, name: "山口県", imageName: "yamaguchi"),
        Prefecture(id: 36, name: "徳島県", imageName: "tokushima"),
        Prefecture(id: 37, name: "香川県", imageName: "kagawa"),
        Prefecture(id: 38, name: "愛媛県", imageName: "ehime"),
        Prefecture(id: 39, name: "高知県", imageName: "kochi"),
        Prefecture(id: 40, name: "福岡県", imageName: "fukuoka"),
        Prefecture(id: 41, name: "佐賀県", imageName: "saga"),
        Prefecture(id: 42, name: "長崎県", imageName: "nagasaki"),
        Prefecture(id: 43, name: "熊本県", imageName: "kumamoto"),
        Prefecture(id: 44, name: "大分県", imageName: "oita"),
        Prefecture(id: 45, name: "宮崎県", imageName: "miyazaki"),
        Prefecture(id: 46, name: "鹿児島県", imageName: "kagoshima"),
        Prefecture(id: 47, name: "沖縄県", imageName: "okinawa")
    ]
}
