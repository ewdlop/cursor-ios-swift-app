import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    @Published var isEnglish: Bool = false
    
    private let languageKey = "isEnglish"
    
    init() {
        // 保持默认语言为中文
        isEnglish = false
    }
    
    func toggleLanguage() {
        // 暂时禁用语言切换功能
        // isEnglish.toggle()
        // UserDefaults.standard.set(isEnglish, forKey: languageKey)
    }
    
    func localizedString(_ key: LocalizationKey) -> String {
        // 始终返回中文
        return key.chinese
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
        }
    }
} 