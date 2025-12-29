//
//  RandomNumberViewModel.swift
//  PartyGame
//
//  ViewModel for Random Number Generator
//

import Foundation

class RandomNumberViewModel: ObservableObject {
    @Published var minNumber: Int = 1
    @Published var maxNumber: Int = 10
    @Published var result: Int?
    @Published var isAnimating: Bool = false
    
    func generateRandomNumber() {
        guard minNumber <= maxNumber else {
            return
        }
        
        isAnimating = true
        result = nil
        
        // Simulate animation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.result = Int.random(in: self.minNumber...self.maxNumber)
            self.isAnimating = false
        }
    }
    
    func reset() {
        result = nil
        isAnimating = false
    }
}
