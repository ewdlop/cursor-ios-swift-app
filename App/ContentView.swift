//
//  ContentView.swift
//  App
//
//  Created by Raymond Lei on 5/11/25.
//

import SwiftUI

struct HistoryItem: Identifiable {
    let id = UUID()
    let number: Int
    let timestamp: Date
}

struct ContentView: View {
    @State private var randomNumber = Int.random(in: 1...100)
    @State private var minNumber: Double = 1
    @State private var maxNumber: Double = 100
    @State private var isAnimating = false
    @State private var history: [HistoryItem] = []
    @State private var isDarkMode = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                HStack {
                    Text("随机数生成器")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                Text("\(randomNumber)")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(.primary)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("最小值: \(Int(minNumber))")
                            .font(.headline)
                        Spacer()
                        Text("最大值: \(Int(maxNumber))")
                            .font(.headline)
                    }
                    
                    Slider(value: $minNumber, in: 1...maxNumber, step: 1)
                        .accentColor(.blue)
                    Slider(value: $maxNumber, in: minNumber...1000, step: 1)
                        .accentColor(.blue)
                }
                .padding(.horizontal)
                
                Button(action: {
                    generateNewNumber()
                }) {
                    HStack {
                        Image(systemName: "dice.fill")
                        Text("生成新随机数")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                if !history.isEmpty {
                    List {
                        Section(header: Text("历史记录")) {
                            ForEach(history.prefix(5)) { item in
                                HStack {
                                    Text("\(item.number)")
                                        .font(.headline)
                                    Spacer()
                                    Text(item.timestamp, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                }
            }
            .padding()
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
    
    private func generateNewNumber() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        withAnimation {
            isAnimating = true
            randomNumber = Int.random(in: Int(minNumber)...Int(maxNumber))
            history.insert(HistoryItem(number: randomNumber, timestamp: Date()), at: 0)
            if history.count > 10 {
                history.removeLast()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
        }
    }
}

#Preview {
    ContentView()
}
