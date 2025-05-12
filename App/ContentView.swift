import SwiftUI
import UIKit

struct HistoryItem: Identifiable {
    let id = UUID()
    let number: Int
    let timestamp: Date
}

struct ThemeColor: Identifiable {
    let id = UUID()
    let name: String
    
    var color: Color {
        switch name {
        case "蓝色": return .blue
        case "红色": return .red
        case "绿色": return .green
        case "紫色": return .purple
        case "橙色": return .orange
        default: return .blue
        }
    }
    
    static func themeColor(for name: String) -> ThemeColor {
        ThemeColor(name: name)
    }
    
    static let themeColors: [ThemeColor] = [
        ThemeColor(name: "蓝色"),
        ThemeColor(name: "红色"),
        ThemeColor(name: "绿色"),
        ThemeColor(name: "紫色"),
        ThemeColor(name: "橙色")
    ]
}

struct ContentView: View {
    @State private var randomNumber = Int.random(in: 1...100)
    @State private var minNumber: Double = 1
    @State private var maxNumber: Double = 100
    @State private var isAnimating = false
    @State private var history: [HistoryItem] = []
    @State private var isDarkMode = false
    @State private var selectedThemeColor: ThemeColor = ThemeColor.themeColors[0]
    @State private var showingColorPicker = false
    @State private var showingShareSheet = false
    @State private var showingCopiedAlert = false
    @Environment(\.colorScheme) var colorScheme
    
    private let minNumberKey = "minNumber"
    private let maxNumberKey = "maxNumber"
    private let isDarkModeKey = "isDarkMode"
    private let themeColorKey = "themeColor"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                HStack {
                    Text("随机数生成器")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(selectedThemeColor.color)
                    
                    Spacer()
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            showingColorPicker.toggle()
                        }) {
                            Image(systemName: "paintpalette.fill")
                                .font(.title2)
                                .foregroundColor(selectedThemeColor.color)
                        }
                        
                        Button(action: {
                            isDarkMode.toggle()
                            saveSettings()
                        }) {
                            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.title2)
                                .foregroundColor(selectedThemeColor.color)
                        }
                    }
                }
                
                Text("\(randomNumber)")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(.primary)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = "\(randomNumber)"
                            showingCopiedAlert = true
                        }) {
                            Label("复制", systemImage: "doc.on.doc")
                        }
                        
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            Label("分享", systemImage: "square.and.arrow.up")
                        }
                    }
                
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("最小值: \(Int(minNumber))")
                            .font(.headline)
                        Spacer()
                        Text("最大值: \(Int(maxNumber))")
                            .font(.headline)
                    }
                    
                    Slider(value: $minNumber, in: 1...maxNumber, step: 1)
                        .accentColor(selectedThemeColor.color)
                        .onChange(of: minNumber) { _ in saveSettings() }
                    Slider(value: $maxNumber, in: minNumber...1000, step: 1)
                        .accentColor(selectedThemeColor.color)
                        .onChange(of: maxNumber) { _ in saveSettings() }
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
                    .background(selectedThemeColor.color)
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
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerView(selectedColor: $selectedThemeColor, onDismiss: saveSettings)
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: ["我刚刚生成了一个随机数：\(randomNumber)"])
            }
            .alert("已复制", isPresented: $showingCopiedAlert) {
                Button("确定", role: .cancel) { }
            }
            .onAppear(perform: loadSettings)
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
    
    private func saveSettings() {
        UserDefaults.standard.set(minNumber, forKey: minNumberKey)
        UserDefaults.standard.set(maxNumber, forKey: maxNumberKey)
        UserDefaults.standard.set(isDarkMode, forKey: isDarkModeKey)
        try? UserDefaults.standard.setValue(selectedThemeColor.name, forKey: themeColorKey)
    }
    
    private func loadSettings() {
        let minVal = UserDefaults.standard.double(forKey: minNumberKey)
        let maxVal = UserDefaults.standard.double(forKey: maxNumberKey)
        minNumber = minVal > 0 ? minVal : 1
        maxNumber = maxVal > 0 ? maxVal : 100
        isDarkMode = UserDefaults.standard.bool(forKey: isDarkModeKey)
        if let name = UserDefaults.standard.string(forKey: themeColorKey) {
            selectedThemeColor = ThemeColor.themeColor(for: name)
        }
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: ThemeColor
    let onDismiss: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(ThemeColor.themeColors) { themeColor in
                Button(action: {
                    selectedColor = themeColor
                    presentationMode.wrappedValue.dismiss()
                    onDismiss()
                }) {
                    HStack {
                        Circle()
                            .fill(themeColor.color)
                            .frame(width: 30, height: 30)
                        Text(themeColor.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if themeColor.id == selectedColor.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("选择主题颜色")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}
