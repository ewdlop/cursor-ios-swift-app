import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    @Published var isEnglish: Bool = false
    
    private let languageKey = "isEnglish"
    
    init() {
        if let savedLanguage = UserDefaults.standard.object(forKey: languageKey) as? Bool {
            isEnglish = savedLanguage
        }
    }
    
    func toggleLanguage() {
        isEnglish.toggle()
        UserDefaults.standard.set(isEnglish, forKey: languageKey)
    }
    
    func localizedString(_ key: LocalizationKey) -> String {
        return isEnglish ? key.english : key.chinese
    }
}

enum LocalizationKey {
    case appTitle
    case minValue
    case maxValue
    case generateNewNumber
    case history
    case decimalMode
    case decimalPlaces
    case copy
    case share
    case stats
    case charts
    case selectThemeColor
    case cancel
    case done
    case basicStats
    case dispersion
    case otherAverages
    case quartiles
    case distributionFeatures
    case recentlyGenerated
    case histogram
    case boxPlot
    case distributionFit
    case trendChart
    case dataVisualization
    case min
    case max
    case range
    case variance
    case standardDeviation
    case coefficientOfVariation
    case medianAbsoluteDeviation
    case geometricMean
    case harmonicMean
    case firstQuartile
    case secondQuartile
    case thirdQuartile
    case interquartileRange
    case skewness
    case kurtosis
    case sampleEntropy
    case generationCount
    case normalDistribution
    case exponentialDistribution
    case poissonDistribution
    case mean
    case lambda
    case rSquared
    case median
    case mode
    
    var chinese: String {
        switch self {
        case .appTitle: return "随机数生成器"
        case .minValue: return "最小值"
        case .maxValue: return "最大值"
        case .generateNewNumber: return "生成新随机数"
        case .history: return "历史记录"
        case .decimalMode: return "小数模式"
        case .decimalPlaces: return "小数位数"
        case .copy: return "复制"
        case .share: return "分享"
        case .stats: return "统计"
        case .charts: return "图表"
        case .selectThemeColor: return "选择主题颜色"
        case .cancel: return "取消"
        case .done: return "完成"
        case .basicStats: return "基本统计"
        case .dispersion: return "离散程度"
        case .otherAverages: return "其他平均数"
        case .quartiles: return "四分位数"
        case .distributionFeatures: return "分布特征"
        case .recentlyGenerated: return "最近生成"
        case .histogram: return "分布直方图"
        case .boxPlot: return "箱型图"
        case .distributionFit: return "分布拟合"
        case .trendChart: return "趋势图"
        case .dataVisualization: return "数据可视化"
        case .min: return "最小值"
        case .max: return "最大值"
        case .range: return "范围"
        case .variance: return "方差"
        case .standardDeviation: return "标准差"
        case .coefficientOfVariation: return "变异系数"
        case .medianAbsoluteDeviation: return "中位数绝对偏差"
        case .geometricMean: return "几何平均数"
        case .harmonicMean: return "调和平均数"
        case .firstQuartile: return "第一四分位数 (Q1)"
        case .secondQuartile: return "第二四分位数 (Q2)"
        case .thirdQuartile: return "第三四分位数 (Q3)"
        case .interquartileRange: return "四分位距 (IQR)"
        case .skewness: return "偏度"
        case .kurtosis: return "峰度"
        case .sampleEntropy: return "样本熵"
        case .generationCount: return "生成次数"
        case .normalDistribution: return "正态分布"
        case .exponentialDistribution: return "指数分布"
        case .poissonDistribution: return "泊松分布"
        case .mean: return "均值"
        case .lambda: return "λ"
        case .rSquared: return "R²"
        case .median: return "中位数"
        case .mode: return "众数"
        }
    }
    
    var english: String {
        switch self {
        case .appTitle: return "Random Number Generator"
        case .minValue: return "Min Value"
        case .maxValue: return "Max Value"
        case .generateNewNumber: return "Generate New Number"
        case .history: return "History"
        case .decimalMode: return "Decimal Mode"
        case .decimalPlaces: return "Decimal Places"
        case .copy: return "Copy"
        case .share: return "Share"
        case .stats: return "Stats"
        case .charts: return "Charts"
        case .selectThemeColor: return "Select Theme Color"
        case .cancel: return "Cancel"
        case .done: return "Done"
        case .basicStats: return "Basic Statistics"
        case .dispersion: return "Dispersion"
        case .otherAverages: return "Other Averages"
        case .quartiles: return "Quartiles"
        case .distributionFeatures: return "Distribution Features"
        case .recentlyGenerated: return "Recently Generated"
        case .histogram: return "Distribution Histogram"
        case .boxPlot: return "Box Plot"
        case .distributionFit: return "Distribution Fit"
        case .trendChart: return "Trend Chart"
        case .dataVisualization: return "Data Visualization"
        case .min: return "Minimum"
        case .max: return "Maximum"
        case .range: return "Range"
        case .variance: return "Variance"
        case .standardDeviation: return "Standard Deviation"
        case .coefficientOfVariation: return "Coefficient of Variation"
        case .medianAbsoluteDeviation: return "Median Absolute Deviation"
        case .geometricMean: return "Geometric Mean"
        case .harmonicMean: return "Harmonic Mean"
        case .firstQuartile: return "First Quartile (Q1)"
        case .secondQuartile: return "Second Quartile (Q2)"
        case .thirdQuartile: return "Third Quartile (Q3)"
        case .interquartileRange: return "Interquartile Range (IQR)"
        case .skewness: return "Skewness"
        case .kurtosis: return "Kurtosis"
        case .sampleEntropy: return "Sample Entropy"
        case .generationCount: return "Generation Count"
        case .normalDistribution: return "Normal Distribution"
        case .exponentialDistribution: return "Exponential Distribution"
        case .poissonDistribution: return "Poisson Distribution"
        case .mean: return "Mean"
        case .lambda: return "λ"
        case .rSquared: return "R²"
        case .median: return "Median"
        case .mode: return "Mode"
        }
    }
} 