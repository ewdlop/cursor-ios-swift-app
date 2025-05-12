import SwiftUI
import UIKit

struct HistoryItem: Identifiable {
    let id = UUID()
    let number: Double
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
    @State private var randomNumber = Double.random(in: 1...100)
    @State private var minNumber: Double = 1
    @State private var maxNumber: Double = 100
    @State private var isAnimating = false
    @State private var history: [HistoryItem] = []
    @State private var isDarkMode = false
    @State private var selectedThemeColor: ThemeColor = ThemeColor.themeColors[0]
    @State private var showingColorPicker = false
    @State private var showingShareSheet = false
    @State private var showingCopiedAlert = false
    @State private var isDecimalMode = false
    @State private var decimalPlaces: Double = 2
    @State private var showingStats = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    private let minNumberKey = "minNumber"
    private let maxNumberKey = "maxNumber"
    private let isDarkModeKey = "isDarkMode"
    private let themeColorKey = "themeColor"
    private let isDecimalModeKey = "isDecimalMode"
    private let decimalPlacesKey = "decimalPlaces"
    
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
                        
                        Button(action: {
                            showingStats.toggle()
                        }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                                .foregroundColor(selectedThemeColor.color)
                        }
                    }
                }
                
                Text(String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f" : "%.0f", randomNumber))
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(.primary)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .rotationEffect(.degrees(isAnimating ? 5 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f" : "%.0f", randomNumber)
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
                        Text("最小值: \(String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f" : "%.0f", minNumber))")
                            .font(.headline)
                        Spacer()
                        Text("最大值: \(String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f" : "%.0f", maxNumber))")
                            .font(.headline)
                    }
                    
                    Slider(value: $minNumber, in: 1...maxNumber, step: isDecimalMode ? pow(0.1, decimalPlaces) : 1)
                        .accentColor(selectedThemeColor.color)
                        .onChange(of: minNumber) { _ in saveSettings() }
                    Slider(value: $maxNumber, in: minNumber...1000, step: isDecimalMode ? pow(0.1, decimalPlaces) : 1)
                        .accentColor(selectedThemeColor.color)
                        .onChange(of: maxNumber) { _ in saveSettings() }
                }
                .padding(.horizontal)
                
                VStack(spacing: 10) {
                    Toggle("小数模式", isOn: $isDecimalMode)
                        .onChange(of: isDecimalMode) { _ in saveSettings() }
                    
                    if isDecimalMode {
                        HStack {
                            Text("小数位数: \(Int(decimalPlaces))")
                            Slider(value: $decimalPlaces, in: 1...5, step: 1)
                                .accentColor(selectedThemeColor.color)
                                .onChange(of: decimalPlaces) { _ in saveSettings() }
                        }
                    }
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
                                    Text(String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f" : "%.0f", item.number))
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
                ShareSheet(items: ["我刚刚生成了一个随机数：\(String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f" : "%.0f", randomNumber))"])
            }
            .sheet(isPresented: $showingStats) {
                StatsView(history: history, isDecimalMode: isDecimalMode, decimalPlaces: Int(decimalPlaces))
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
            randomNumber = Double.random(in: minNumber...maxNumber)
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
        UserDefaults.standard.set(isDecimalMode, forKey: isDecimalModeKey)
        UserDefaults.standard.set(decimalPlaces, forKey: decimalPlacesKey)
        try? UserDefaults.standard.setValue(selectedThemeColor.name, forKey: themeColorKey)
    }
    
    private func loadSettings() {
        let minVal = UserDefaults.standard.double(forKey: minNumberKey)
        let maxVal = UserDefaults.standard.double(forKey: maxNumberKey)
        minNumber = minVal > 0 ? minVal : 1
        maxNumber = maxVal > 0 ? maxVal : 100
        isDarkMode = UserDefaults.standard.bool(forKey: isDarkModeKey)
        isDecimalMode = UserDefaults.standard.bool(forKey: isDecimalModeKey)
        decimalPlaces = UserDefaults.standard.double(forKey: decimalPlacesKey)
        if decimalPlaces == 0 { decimalPlaces = 2 }
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

struct StatsView: View {
    let history: [HistoryItem]
    let isDecimalMode: Bool
    let decimalPlaces: Int
    @Environment(\.presentationMode) var presentationMode
    
    // 基本统计
    var average: Double {
        guard !history.isEmpty else { return 0 }
        return history.map { $0.number }.reduce(0, +) / Double(history.count)
    }
    
    var median: Double {
        guard !history.isEmpty else { return 0 }
        let sorted = history.map { $0.number }.sorted()
        let count = sorted.count
        if count % 2 == 0 {
            return (sorted[count/2 - 1] + sorted[count/2]) / 2
        } else {
            return sorted[count/2]
        }
    }
    
    var mode: Double {
        guard !history.isEmpty else { return 0 }
        let numbers = history.map { $0.number }
        let counts = numbers.reduce(into: [:]) { counts, number in
            counts[number, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key ?? 0
    }
    
    // 方差和标准差
    var variance: Double {
        guard !history.isEmpty else { return 0 }
        let numbers = history.map { $0.number }
        let mean = average
        return numbers.reduce(0) { $0 + pow($1 - mean, 2) } / Double(numbers.count)
    }
    
    var standardDeviation: Double {
        sqrt(variance)
    }
    
    // 四分位数
    var quartiles: (q1: Double, q2: Double, q3: Double) {
        guard !history.isEmpty else { return (0, 0, 0) }
        let sorted = history.map { $0.number }.sorted()
        let count = sorted.count
        
        let q2 = median
        
        // 安全地获取下半部分和上半部分
        let midPoint = count / 2
        let lowerHalf = Array(sorted[0..<midPoint])
        let upperHalf = Array(sorted[(midPoint + (count % 2 == 0 ? 0 : 1))..<count])
        
        // 安全地计算 Q1
        let q1: Double
        if lowerHalf.isEmpty {
            q1 = sorted[0]
        } else if lowerHalf.count == 1 {
            q1 = lowerHalf[0]
        } else {
            let lowerMid = lowerHalf.count / 2
            q1 = lowerHalf.count % 2 == 0
                ? (lowerHalf[lowerMid - 1] + lowerHalf[lowerMid]) / 2
                : lowerHalf[lowerMid]
        }
        
        // 安全地计算 Q3
        let q3: Double
        if upperHalf.isEmpty {
            q3 = sorted[count - 1]
        } else if upperHalf.count == 1 {
            q3 = upperHalf[0]
        } else {
            let upperMid = upperHalf.count / 2
            q3 = upperHalf.count % 2 == 0
                ? (upperHalf[upperMid - 1] + upperHalf[upperMid]) / 2
                : upperHalf[upperMid]
        }
        
        return (q1, q2, q3)
    }
    
    // 偏度
    var skewness: Double {
        guard !history.isEmpty else { return 0 }
        let numbers = history.map { $0.number }
        let mean = average
        let std = standardDeviation
        let n = Double(numbers.count)
        
        let sumCubedDeviations = numbers.reduce(0) { $0 + pow($1 - mean, 3) }
        return (sumCubedDeviations / n) / pow(std, 3)
    }
    
    // 峰度
    var kurtosis: Double {
        guard !history.isEmpty else { return 0 }
        let numbers = history.map { $0.number }
        let mean = average
        let std = standardDeviation
        let n = Double(numbers.count)
        
        let sumQuarticDeviations = numbers.reduce(0) { $0 + pow($1 - mean, 4) }
        return (sumQuarticDeviations / n) / pow(std, 4) - 3 // 减3得到超额峰度
    }
    
    var min: Double {
        history.map { $0.number }.min() ?? 0
    }
    
    var max: Double {
        history.map { $0.number }.max() ?? 0
    }
    
    var range: Double {
        max - min
    }
    
    // 变异系数 (CV)
    var coefficientOfVariation: Double {
        guard !history.isEmpty, average != 0 else { return 0 }
        return standardDeviation / abs(average)
    }
    
    // 几何平均数
    var geometricMean: Double {
        guard !history.isEmpty else { return 0 }
        let numbers = history.map { $0.number }
        let product = numbers.reduce(1.0) { $0 * $1 }
        return pow(product, 1.0 / Double(numbers.count))
    }
    
    // 调和平均数
    var harmonicMean: Double {
        guard !history.isEmpty else { return 0 }
        let numbers = history.map { $0.number }
        let sumOfReciprocals = numbers.reduce(0.0) { $0 + (1.0 / $1) }
        return Double(numbers.count) / sumOfReciprocals
    }
    
    // 中位数绝对偏差 (MAD)
    var medianAbsoluteDeviation: Double {
        guard !history.isEmpty else { return 0 }
        let numbers = history.map { $0.number }
        let deviations = numbers.map { abs($0 - median) }
        let sortedDeviations = deviations.sorted()
        let count = sortedDeviations.count
        if count % 2 == 0 {
            return (sortedDeviations[count/2 - 1] + sortedDeviations[count/2]) / 2
        } else {
            return sortedDeviations[count/2]
        }
    }
    
    // 样本熵
    var sampleEntropy: Double {
        guard !history.isEmpty else { return 0 }
        let numbers = history.map { $0.number }
        let uniqueNumbers = Set(numbers)
        let probabilities = uniqueNumbers.map { number in
            Double(numbers.filter { $0 == number }.count) / Double(numbers.count)
        }
        return -probabilities.reduce(0) { $0 + $1 * log2($1) }
    }
    
    // 卡方检验
    var chiSquareTest: (statistic: Double, pValue: Double) {
        guard !history.isEmpty else { return (0, 0) }
        let numbers = history.map { $0.number }
        let uniqueNumbers = Set(numbers)
        let observed = uniqueNumbers.map { number in
            Double(numbers.filter { $0 == number }.count)
        }
        let expected = Array(repeating: Double(numbers.count) / Double(uniqueNumbers.count), count: uniqueNumbers.count)
        
        let chiSquare = zip(observed, expected).reduce(0.0) { sum, pair in
            sum + pow(pair.0 - pair.1, 2) / pair.1
        }
        
        // 简化的p值计算（使用卡方分布近似）
        let degreesOfFreedom = Double(uniqueNumbers.count - 1)
        let pValue = 1.0 - (1.0 / (1.0 + exp(-chiSquare / 2.0)))
        
        return (chiSquare, pValue)
    }
    
    // Spearman相关系数
    var spearmanCorrelation: Double {
        guard history.count > 1 else { return 0 }
        let numbers = history.map { $0.number }
        let ranks = numbers.enumerated().sorted { $0.element < $1.element }
            .enumerated().sorted { $0.element.offset < $1.element.offset }
            .map { Double($0.offset + 1) }
        
        let n = Double(numbers.count)
        let sumD2 = zip(ranks, Array(1...Int(n))).reduce(0.0) { sum, pair in
            sum + pow(pair.0 - Double(pair.1), 2)
        }
        
        return 1.0 - (6.0 * sumD2) / (n * (n * n - 1.0))
    }
    
    // Kendall's Tau相关系数
    var kendallTau: Double {
        guard history.count > 1 else { return 0 }
        let numbers = history.map { $0.number }
        var concordant = 0
        var discordant = 0
        
        for i in 0..<numbers.count {
            for j in (i+1)..<numbers.count {
                if (numbers[i] < numbers[j] && i < j) || (numbers[i] > numbers[j] && i > j) {
                    concordant += 1
                } else {
                    discordant += 1
                }
            }
        }
        
        let n = Double(numbers.count)
        return Double(concordant - discordant) / (n * (n - 1) / 2)
    }
    
    // Bootstrap置信区间
    func bootstrapConfidenceInterval(confidence: Double = 0.95, iterations: Int = 1000) -> (lower: Double, upper: Double) {
        guard !history.isEmpty else { return (0, 0) }
        let numbers = history.map { $0.number }
        var bootstrapMeans: [Double] = []
        
        for _ in 0..<iterations {
            let sample = (0..<numbers.count).map { _ in numbers.randomElement()! }
            bootstrapMeans.append(sample.reduce(0, +) / Double(sample.count))
        }
        
        bootstrapMeans.sort()
        let lowerIndex = Int(Double(iterations) * (1 - confidence) / 2)
        let upperIndex = Int(Double(iterations) * (1 + confidence) / 2)
        
        return (bootstrapMeans[lowerIndex], bootstrapMeans[upperIndex])
    }
    
    // Cohen's d效应量
    var cohensD: Double {
        guard !history.isEmpty else { return 0 }
        let numbers = history.map { $0.number }
        let mean = average
        let std = standardDeviation
        return mean / std
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("基本统计")) {
                    StatRow(title: "平均值", value: average)
                    StatRow(title: "中位数", value: median)
                    StatRow(title: "众数", value: mode)
                    StatRow(title: "最小值", value: min)
                    StatRow(title: "最大值", value: max)
                    StatRow(title: "范围", value: range)
                }
                
                Section(header: Text("离散程度")) {
                    StatRow(title: "方差", value: variance)
                    StatRow(title: "标准差", value: standardDeviation)
                    StatRow(title: "变异系数", value: coefficientOfVariation)
                    StatRow(title: "中位数绝对偏差", value: medianAbsoluteDeviation)
                }
                
                Section(header: Text("其他平均数")) {
                    StatRow(title: "几何平均数", value: geometricMean)
                    StatRow(title: "调和平均数", value: harmonicMean)
                }
                
                Section(header: Text("四分位数")) {
                    StatRow(title: "第一四分位数 (Q1)", value: quartiles.q1)
                    StatRow(title: "第二四分位数 (Q2)", value: quartiles.q2)
                    StatRow(title: "第三四分位数 (Q3)", value: quartiles.q3)
                    StatRow(title: "四分位距 (IQR)", value: quartiles.q3 - quartiles.q1)
                }
                
                Section(header: Text("分布特征")) {
                    StatRow(title: "偏度", value: skewness)
                    StatRow(title: "峰度", value: kurtosis)
                    StatRow(title: "样本熵", value: sampleEntropy)
                    StatRow(title: "生成次数", value: Double(history.count))
                }
                
                Section(header: Text("假设检验")) {
                    StatRow(title: "卡方统计量", value: chiSquareTest.statistic)
                    StatRow(title: "卡方检验p值", value: chiSquareTest.pValue)
                }
                
                Section(header: Text("相关性分析")) {
                    StatRow(title: "Spearman相关系数", value: spearmanCorrelation)
                    StatRow(title: "Kendall's Tau", value: kendallTau)
                }
                
                Section(header: Text("现代统计方法")) {
                    let ci = bootstrapConfidenceInterval()
                    StatRow(title: "Bootstrap 95% CI下限", value: ci.lower)
                    StatRow(title: "Bootstrap 95% CI上限", value: ci.upper)
                    StatRow(title: "Cohen's d效应量", value: cohensD)
                }
                
                if !history.isEmpty {
                    Section(header: Text("最近生成")) {
                        ForEach(history.prefix(3)) { item in
                            HStack {
                                Text(String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f" : "%.0f", item.number))
                                Spacer()
                                Text(item.timestamp, style: .time)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("统计")
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct StatRow: View {
    let title: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(String(format: "%.2f", value))
                .foregroundColor(.gray)
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
