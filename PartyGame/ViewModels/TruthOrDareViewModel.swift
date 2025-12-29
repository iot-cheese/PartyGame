//
//  TruthOrDareViewModel.swift
//  PartyGame
//
//  ViewModel for Truth or Dare game
//

import Foundation

class TruthOrDareViewModel: ObservableObject {
    @Published var currentPrompt: String = ""
    @Published var promptType: PromptType = .truth
    
    enum PromptType {
        case truth
        case dare
    }
    
    private let truths = [
        "今まで誰にも言ったことのない秘密は？",
        "人生で一番恥ずかしかった瞬間は？",
        "もし無人島に一つだけ持っていけるとしたら？",
        "初恋はいつでしたか？",
        "今までついた一番大きな嘘は？",
        "もし宝くじで1億円当たったら何をする？",
        "今まで会った中で一番印象的な人は？",
        "人生をやり直せるとしたら何を変えたい？",
        "この中で誰が一番面白いと思う？",
        "子供の頃の夢は何だった？"
    ]
    
    private let dares = [
        "20秒間片足立ちをする",
        "次のターンまで変な顔をし続ける",
        "好きな歌を15秒間歌う",
        "誰かの真似をして当ててもらう",
        "目を閉じて鼻を触れるか挑戦",
        "10秒間早口言葉を言う",
        "全員に一言ずつ褒め言葉を言う",
        "電話の着信音を真似する",
        "動物の鳴き声を5つ真似する",
        "次のターンまでロボットのように動く"
    ]
    
    func selectTruth() {
        promptType = .truth
        currentPrompt = truths.randomElement() ?? ""
    }
    
    func selectDare() {
        promptType = .dare
        currentPrompt = dares.randomElement() ?? ""
    }
}
