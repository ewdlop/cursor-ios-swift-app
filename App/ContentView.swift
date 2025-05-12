import SwiftUI
import UIKit
import Charts
import Foundation

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
        case "黄色": return .yellow
        case "青色": return .cyan
        case "粉色": return .pink
        case "棕色": return .brown
        case "灰色": return .gray
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
        ThemeColor(name: "橙色"),
        ThemeColor(name: "黄色"),
        ThemeColor(name: "青色"),
        ThemeColor(name: "粉色"),
        ThemeColor(name: "棕色"),
        ThemeColor(name: "灰色")
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
    @State private var showingCharts = false
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
                        
                        Button(action: {
                            showingCharts.toggle()
                        }) {
                            Image(systemName: "chart.xyaxis.line")
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
                    
                    Slider(value: $minNumber, in: 1...maxNumber, step: isDecimalMode ? Foundation.pow(0.1, decimalPlaces) : 1)
                        .accentColor(selectedThemeColor.color)
                        .onChange(of: minNumber) { _ in saveSettings() }
                    Slider(value: $maxNumber, in: minNumber...1000, step: isDecimalMode ? Foundation.pow(0.1, decimalPlaces) : 1)
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
            .sheet(isPresented: $showingCharts) {
                ChartView(history: history, isDecimalMode: isDecimalMode, decimalPlaces: Int(decimalPlaces))
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
        return numbers.reduce(0) { $0 + Foundation.pow($1 - mean, 2) } / Double(numbers.count)
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
        
        let sumCubedDeviations = numbers.reduce(0) { $0 + Foundation.pow($1 - mean, 3) }
        return (sumCubedDeviations / n) / Foundation.pow(std, 3)
    }
    
    // 峰度
    var kurtosis: Double {
        guard !history.isEmpty else { return 0 }
        let numbers = history.map { $0.number }
        let mean = average
        let std = standardDeviation
        let n = Double(numbers.count)
        
        let sumQuarticDeviations = numbers.reduce(0) { $0 + Foundation.pow($1 - mean, 4) }
        return (sumQuarticDeviations / n) / Foundation.pow(std, 4) - 3 // 减3得到超额峰度
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
        return Foundation.pow(product, 1.0 / Double(numbers.count))
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
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ChartView: View {
    let history: [HistoryItem]
    let isDecimalMode: Bool
    let decimalPlaces: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedFitType = "正态分布"
    
    // 直方图数据
    var histogramData: [(range: String, count: Int)] {
        guard !history.isEmpty else { return [] }
        let numbers = history.map { $0.number }
        let minValue = numbers.min() ?? 0
        let maxValue = numbers.max() ?? 1
        let range = maxValue - minValue
        let binCount = Swift.min(10, history.count)
        let binSize = range / Double(binCount)
        
        var bins = Array(repeating: 0, count: binCount)
        for number in numbers {
            let binIndex = Swift.min(Int((number - minValue) / binSize), binCount - 1)
            bins[binIndex] += 1
        }
        
        return bins.enumerated().map { index, count in
            let start = minValue + Double(index) * binSize
            let end = start + binSize
            return (
                range: String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f-%.\(Int(decimalPlaces))f" : "%.0f-%.0f", start, end),
                count: count
            )
        }
    }
    
    // 箱型图数据
    var boxPlotData: (min: Double, q1: Double, median: Double, q3: Double, max: Double) {
        guard !history.isEmpty else { return (0, 0, 0, 0, 0) }
        let numbers = history.map { $0.number }.sorted()
        let count = numbers.count
        
        let min = numbers.first!
        let max = numbers.last!
        let median = count % 2 == 0
            ? (numbers[count/2 - 1] + numbers[count/2]) / 2
            : numbers[count/2]
        
        let q1 = count % 2 == 0
            ? (numbers[count/4 - 1] + numbers[count/4]) / 2
            : numbers[count/4]
        
        let q3 = count % 2 == 0
            ? (numbers[3*count/4 - 1] + numbers[3*count/4]) / 2
            : numbers[3*count/4]
        
        return (min, q1, median, q3, max)
    }
    
    // 趋势图数据
    var trendData: [(date: Date, value: Double)] {
        history.map { ($0.timestamp, $0.number) }
    }
    
    // 正态分布拟合
    var normalDistributionFit: (mean: Double, stdDev: Double, rSquared: Double) {
        guard !history.isEmpty else { return (0, 0, 0) }
        let numbers = history.map { $0.number }
        let mean = numbers.reduce(0, +) / Double(numbers.count)
        let variance = numbers.reduce(0) { $0 + pow($1 - mean, 2) } / Double(numbers.count)
        let stdDev = sqrt(variance)
        
        // 计算R²
        let histogram = histogramData
        let totalCount = Double(histogram.reduce(0) { $0 + $1.count })
        let expectedFreq = histogram.map { range -> Double in
            let rangeValues = range.range.split(separator: "-").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0 }
            guard rangeValues.count == 2 else { return 0 }
            let lower = rangeValues[0]
            let upper = rangeValues[1]
            let p = normalCDF(upper, mean: mean, stdDev: stdDev) - normalCDF(lower, mean: mean, stdDev: stdDev)
            return p * totalCount
        }
        let observedFreq = histogram.map { Double($0.count) }
        let rSquared = calculateRSquared(observed: observedFreq, expected: expectedFreq)
        
        return (mean, stdDev, rSquared)
    }
    
    // 指数分布拟合
    var exponentialDistributionFit: (lambda: Double, rSquared: Double) {
        guard !history.isEmpty else { return (0, 0) }
        let numbers = history.map { $0.number }
        let mean = numbers.reduce(0, +) / Double(numbers.count)
        let lambda = 1.0 / mean
        
        // 计算R²
        let histogram = histogramData
        let totalCount = Double(histogram.reduce(0) { $0 + $1.count })
        let expectedFreq = histogram.map { range -> Double in
            let rangeValues = range.range.split(separator: "-").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0 }
            guard rangeValues.count == 2 else { return 0 }
            let lower = rangeValues[0]
            let upper = rangeValues[1]
            let p = exp(-lambda * lower) - exp(-lambda * upper)
            return p * totalCount
        }
        let observedFreq = histogram.map { Double($0.count) }
        let rSquared = calculateRSquared(observed: observedFreq, expected: expectedFreq)
        
        return (lambda, rSquared)
    }
    
    // 泊松分布拟合
    var poissonDistributionFit: (lambda: Double, rSquared: Double) {
        guard !history.isEmpty else { return (0, 0) }
        let numbers = history.map { $0.number }
        let lambda = numbers.reduce(0, +) / Double(numbers.count)
        
        // 计算R²
        let histogram = histogramData
        let totalCount = Double(histogram.reduce(0) { $0 + $1.count })
        let expectedFreq = histogram.map { range -> Double in
            let rangeValues = range.range.split(separator: "-").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0 }
            guard rangeValues.count == 2 else { return 0 }
            let k = Int(round((rangeValues[0] + rangeValues[1]) / 2))
            let p = pow(lambda, Double(k)) * exp(-lambda) / factorial(k)
            return p * totalCount
        }
        let observedFreq = histogram.map { Double($0.count) }
        let rSquared = calculateRSquared(observed: observedFreq, expected: expectedFreq)
        
        return (lambda, rSquared)
    }
    
    // 辅助函数
    private func normalCDF(_ x: Double, mean: Double, stdDev: Double) -> Double {
        return 0.5 * (1 + erf((x - mean) / (stdDev * sqrt(2))))
    }
    
    private func factorial(_ n: Int) -> Double {
        return (1...n).map { Double($0) }.reduce(1, *)
    }
    
    private func calculateRSquared(observed: [Double], expected: [Double]) -> Double {
        let meanObserved = observed.reduce(0, +) / Double(observed.count)
        let ssTotal = observed.reduce(0) { $0 + pow($1 - meanObserved, 2) }
        let ssResidual = zip(observed, expected).reduce(0) { $0 + pow($1.0 - $1.1, 2) }
        return 1 - (ssResidual / ssTotal)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("分布直方图")) {
                    Chart(histogramData, id: \.range) { item in
                        BarMark(
                            x: .value("范围", item.range),
                            y: .value("频数", item.count)
                        )
                    }
                    .frame(height: 200)
                }
                
                Section(header: Text("箱型图")) {
                    let boxData = boxPlotData
                    VStack(alignment: .leading, spacing: 10) {
                        Text("最小值: \(String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f" : "%.0f", boxData.min))")
                        Text("Q1: \(String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f" : "%.0f", boxData.q1))")
                        Text("中位数: \(String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f" : "%.0f", boxData.median))")
                        Text("Q3: \(String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f" : "%.0f", boxData.q3))")
                        Text("最大值: \(String(format: isDecimalMode ? "%.\(Int(decimalPlaces))f" : "%.0f", boxData.max))")
                    }
                    .padding()
                }
                
                Section(header: Text("分布拟合")) {
                    Picker("拟合类型", selection: $selectedFitType) {
                        Text("正态分布").tag("正态分布")
                        Text("指数分布").tag("指数分布")
                        Text("泊松分布").tag("泊松分布")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical)
                    
                    if selectedFitType == "正态分布" {
                        let fit = normalDistributionFit
                        VStack(alignment: .leading, spacing: 10) {
                            Text("均值: \(String(format: "%.2f", fit.mean))")
                            Text("标准差: \(String(format: "%.2f", fit.stdDev))")
                            Text("R² = \(String(format: "%.4f", fit.rSquared))")
                        }
                        .padding()
                    } else if selectedFitType == "指数分布" {
                        let fit = exponentialDistributionFit
                        VStack(alignment: .leading, spacing: 10) {
                            Text("λ = \(String(format: "%.2f", fit.lambda))")
                            Text("R² = \(String(format: "%.4f", fit.rSquared))")
                        }
                        .padding()
                    } else {
                        let fit = poissonDistributionFit
                        VStack(alignment: .leading, spacing: 10) {
                            Text("λ = \(String(format: "%.2f", fit.lambda))")
                            Text("R² = \(String(format: "%.4f", fit.rSquared))")
                        }
                        .padding()
                    }
                    
                    Chart(histogramData, id: \.range) { item in
                        BarMark(
                            x: .value("范围", item.range),
                            y: .value("频数", item.count)
                        )
                        .foregroundStyle(.blue)
                        
                        if selectedFitType == "正态分布" {
                            let fit = normalDistributionFit
                            let rangeValues = item.range.split(separator: "-").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0 }
                            if rangeValues.count == 2 {
                                let p = normalCDF(rangeValues[1], mean: fit.mean, stdDev: fit.stdDev) - normalCDF(rangeValues[0], mean: fit.mean, stdDev: fit.stdDev)
                                LineMark(
                                    x: .value("范围", item.range),
                                    y: .value("拟合值", p * Double(history.count))
                                )
                                .foregroundStyle(.red)
                            }
                        } else if selectedFitType == "指数分布" {
                            let fit = exponentialDistributionFit
                            let rangeValues = item.range.split(separator: "-").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0 }
                            if rangeValues.count == 2 {
                                let p = exp(-fit.lambda * rangeValues[0]) - exp(-fit.lambda * rangeValues[1])
                                LineMark(
                                    x: .value("范围", item.range),
                                    y: .value("拟合值", p * Double(history.count))
                                )
                                .foregroundStyle(.red)
                            }
                        } else {
                            let fit = poissonDistributionFit
                            let rangeValues = item.range.split(separator: "-").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0 }
                            if rangeValues.count == 2 {
                                let k = Int(round((rangeValues[0] + rangeValues[1]) / 2))
                                let p = pow(fit.lambda, Double(k)) * exp(-fit.lambda) / factorial(k)
                                LineMark(
                                    x: .value("范围", item.range),
                                    y: .value("拟合值", p * Double(history.count))
                                )
                                .foregroundStyle(.red)
                            }
                        }
                    }
                    .frame(height: 200)
                }
                
                Section(header: Text("趋势图")) {
                    Chart(trendData, id: \.date) { item in
                        LineMark(
                            x: .value("时间", item.date),
                            y: .value("数值", item.value)
                        )
                    }
                    .frame(height: 200)
                }
            }
            .navigationTitle("数据可视化")
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    ContentView()
}
