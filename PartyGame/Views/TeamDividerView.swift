//
//  TeamDividerView.swift
//  PartyGame
//
//  Team Divider game view
//

import SwiftUI

struct TeamDividerView: View {
    @StateObject private var viewModel = TeamDividerViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("チーム分け")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if !viewModel.hasGenerated {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("参加者名を入力（1行に1人）")
                            .font(.headline)
                        
                        TextEditor(text: $viewModel.playerNames)
                            .frame(height: 200)
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        
                        HStack {
                            Text("チーム数")
                                .font(.headline)
                            
                            Spacer()
                            
                            Stepper(value: $viewModel.numberOfTeams, in: 2...10) {
                                Text("\(viewModel.numberOfTeams)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 20) {
                        ForEach(Array(viewModel.teams.enumerated()), id: \.offset) { index, team in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("チーム \(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 5)
                                    .background(teamColor(for: index))
                                    .cornerRadius(8)
                                
                                ForEach(team, id: \.self) { player in
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(teamColor(for: index))
                                        Text(player)
                                            .font(.body)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    if !viewModel.hasGenerated {
                        Button(action: {
                            withAnimation {
                                viewModel.divideIntoTeams()
                            }
                        }) {
                            HStack {
                                Image(systemName: "shuffle")
                                    .font(.system(size: 25))
                                Text("チーム分け開始")
                                    .fontWeight(.semibold)
                                    .font(.title3)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                    } else {
                        Button(action: {
                            withAnimation {
                                viewModel.reset()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("やり直す")
                                    .fontWeight(.semibold)
                            }
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
    
    private func teamColor(for index: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .cyan, .indigo, .mint]
        return colors[index % colors.count]
    }
}

struct TeamDividerView_Previews: PreviewProvider {
    static var previews: some View {
        TeamDividerView()
    }
}
