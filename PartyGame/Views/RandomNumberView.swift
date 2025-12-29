//
//  RandomNumberView.swift
//  PartyGame
//
//  Random Number Generator game view
//

import SwiftUI

struct RandomNumberView: View {
    @StateObject private var viewModel = RandomNumberViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("ランダム選択")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("最小値")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("最小", value: $viewModel.minNumber, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("最大値")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("最大", value: $viewModel.maxNumber, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            if let result = viewModel.result {
                VStack {
                    Text("結果")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("\(result)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.blue)
                        .transition(.scale)
                }
            } else if viewModel.isAnimating {
                ProgressView()
                    .scaleEffect(2)
            } else {
                Text("ボタンを押して数字を生成")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: {
                    viewModel.generateRandomNumber()
                }) {
                    HStack {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 25))
                        Text("ランダム生成")
                            .fontWeight(.semibold)
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .disabled(viewModel.isAnimating)
                
                if viewModel.result != nil {
                    Button(action: {
                        withAnimation {
                            viewModel.reset()
                        }
                    }) {
                        Text("リセット")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
    }
}

struct RandomNumberView_Previews: PreviewProvider {
    static var previews: some View {
        RandomNumberView()
    }
}
