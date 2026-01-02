//
//  GrandparentImage.swift
//  PartyGame
//
//  Created by Daniel on 2026/01/02.
//

import Foundation
import UIKit

enum GrandparentType: String {
    case grandpa = "おじいちゃん"
    case grandma = "おばあちゃん"
}

struct GrandparentImage: Identifiable {
    let id: String
    let imageName: String
    let type: GrandparentType
    
    static let all: [GrandparentImage] = {
        var images: [GrandparentImage] = []
        
        // GrandpaOrGrandma/Grandpa/内の画像を検出
        for i in 1...100 {
            let imageName = "grandpa_\(i)"
            if UIImage(named: imageName) != nil {
                images.append(GrandparentImage(
                    id: "grandpa_\(i)",
                    imageName: imageName,
                    type: .grandpa
                ))
            }
        }
        
        // GrandpaOrGrandma/Grandma/内の画像を検出
        for i in 1...100 {
            let imageName = "grandma_\(i)"
            if UIImage(named: imageName) != nil {
                images.append(GrandparentImage(
                    id: "grandma_\(i)",
                    imageName: imageName,
                    type: .grandma
                ))
            }
        }
        
        return images
    }()
}
