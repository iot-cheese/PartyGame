//
//  TruthOrDareView.swift
//  PartyGame
//
//  Truth or Dare game view
//

import SwiftUI

struct TruthOrDareView: View {
    @StateObject private var viewModel = TruthOrDareViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("真実か挑戦か")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if !viewModel.currentPrompt.isEmpty {
                VStack(spacing: 20) {
                    Text(viewModel.promptType == .truth ? "真実" : "挑戦")
                        .font(.title2)
                        .foregroundColor(viewModel.promptType == .truth ? .blue : .orange)
                        .fontWeight(.semibold)
                    
                    Text(viewModel.currentPrompt)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Text("ボタンを押して始めよう！")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding()
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation {
                        viewModel.selectTruth()
                    }
                }) {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                        Text("真実")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                
                Button(action: {
                    withAnimation {
                        viewModel.selectDare()
                    }
                }) {
                    VStack {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 40))
                        Text("挑戦")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
    }
}

struct TruthOrDareView_Previews: PreviewProvider {
    static var previews: some View {
        TruthOrDareView()
    }
}
