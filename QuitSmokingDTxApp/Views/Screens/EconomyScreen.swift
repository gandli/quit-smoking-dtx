import SwiftUI
import Charts

struct EconomyScreen: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTimeRange: EconomyTimeRange = .month
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 标题和设置
                    EconomyHeaderSection(showingSettings: $showingSettings)
                    
                    // 总节省金额
                    TotalSavingsCard()
                    
                    // 消费趋势图表
                    SpendingTrendChart(timeRange: selectedTimeRange)
                    
                    // 机会成本分析
                    OpportunityCostSection()
                    
                    // 替代目标进度
                    AlternativeGoalsSection()
                    
                    // 中性提示
                    NeutralTipsSection()
                }
                .padding(.vertical)
            }
            .navigationTitle("经济分析")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingSettings) {
                EconomySettingsScreen()
            }
        }
    }
}

struct EconomyHeaderSection: View {
    @Environment(AppState.self) private var appState
    @Binding var showingSettings: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("经济消费分析")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("帮助你感知戒烟的经济影响")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            
            Text("数据仅供参考，不构成财务建议")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                )
                .padding(.horizontal)
        }
    }
}

enum EconomyTimeRange: String, CaseIterable {
    case week = "本周"
    case month = "本月"
    case quarter = "本季"
    case year = "今年"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .quarter: return 90
        case .year: return 365
        }
    }
}

struct TotalSavingsCard: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("总节省金额")
                    .font(.headline)
                Spacer()
                
                Text("自戒烟开始")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                Text(String(format: "¥%.0f", appState.moneySaved))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.green)
                
                Text("相当于")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 等价换算
                HStack(spacing: 16) {
                    EquivalentItem(
                        icon: "cup.and.saucer",
                        label: "\(equivalentCoffeeCups())杯咖啡"
                    )
                    
                    EquivalentItem(
                        icon: "film",
                        label: "\(equivalentMovies())场电影"
                    )
                    
                    EquivalentItem(
                        icon: "book",
                        label: "\(equivalentBooks())本书"
                    )
                }
            }
            
            // 日均节省
            HStack {
                Text("日均节省")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(String(format: "¥%.1f/天", dailySavings()))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private func dailySavings() -> Double {
        let days = max(1, Int(appState.quitDuration / (24 * 3600)))
        return appState.moneySaved / Double(days)
    }
    
    private func equivalentCoffeeCups() -> Int {
        let coffeePrice = 30.0
        return Int(appState.moneySaved / coffeePrice)
    }
    
    private func equivalentMovies() -> Int {
        let moviePrice = 50.0
        return Int(appState.moneySaved / moviePrice)
    }
    
    private func equivalentBooks() -> Int {
        let bookPrice = 80.0
        return Int(appState.moneySaved / bookPrice)
    }
}

struct EquivalentItem: View {
    let icon: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(label)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SpendingTrendChart: View {
    @Environment(AppState.self) private var appState
    let timeRange: EconomyTimeRange
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("消费趋势")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            Chart {
                ForEach(generateMonthlySpendingData()) { data in
                    BarMark(
                        x: .value("月份", data.month, unit: .month),
                        y: .value("金额", data.amount)
                    )
                    .foregroundStyle(.red.opacity(0.8))
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.narrow))
                        .font(.system(size: 10))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    if let amount = value.as(Double.self) {
                        AxisValueLabel("¥\(Int(amount))")
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private func generateMonthlySpendingData() -> [MonthlySpendingData] {
        var data: [MonthlySpendingData] = []
        let calendar = Calendar.current
        let today = Date()
        
        // 生成最近 12 个月的数据
        for i in 0..<12 {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: today) else { continue }
            
            // 获取该月的第一天
            let components = calendar.dateComponents([.year, .month], from: monthDate)
            guard let firstDayOfMonth = calendar.date(from: components) else { continue }
            
            // 计算该月的消费金额（基于每日吸烟量和价格）
            let baseAmount = Double(appState.cigarettesPerDay) * appState.cigarettePrice * 30
            // 添加一些随机变化使数据更真实
            let variation = Double.random(in: 0.7...1.3)
            // 越早的月份消费越高（模拟戒烟进度）
            let progressFactor = 1.0 - (Double(i) * 0.05)
            let amount = baseAmount * variation * progressFactor
            
            data.append(MonthlySpendingData(month: firstDayOfMonth, amount: max(0, amount)))
        }
        
        return data.sorted { $0.month < $1.month }
    }
}

struct MonthlySpendingData: Identifiable {
    let id = UUID()
    let month: Date
    let amount: Double
}

struct SpendingData: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

struct OpportunityCostSection: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("机会成本分析")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                OpportunityCostRow(
                    title: "月度节省",
                    amount: monthlySavings(),
                    period: "每月"
                )
                
                OpportunityCostRow(
                    title: "年度节省",
                    amount: yearlySavings(),
                    period: "每年"
                )
                
                OpportunityCostRow(
                    title: "五年节省",
                    amount: fiveYearSavings(),
                    period: "五年"
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
    }
    
    private func monthlySavings() -> Double {
        return dailySavings() * 30
    }
    
    private func yearlySavings() -> Double {
        return dailySavings() * 365
    }
    
    private func fiveYearSavings() -> Double {
        return yearlySavings() * 5
    }
    
    private func dailySavings() -> Double {
        let days = max(1, Int(appState.quitDuration / (24 * 3600)))
        return appState.moneySaved / Double(days)
    }
}

struct OpportunityCostRow: View {
    let title: String
    let amount: Double
    let period: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                
                Text(period)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "¥%.0f", amount))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
    }
}

struct AlternativeGoalsSection: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("替代目标")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 20) {
                GoalProgressCard(
                    title: "旅行基金",
                    targetAmount: 5000,
                    currentAmount: min(appState.moneySaved, 5000),
                    icon: "airplane"
                )
                
                GoalProgressCard(
                    title: "新手机",
                    targetAmount: 8000,
                    currentAmount: min(appState.moneySaved, 8000),
                    icon: "iphone"
                )
                
                GoalProgressCard(
                    title: "健身会员",
                    targetAmount: 3000,
                    currentAmount: min(appState.moneySaved, 3000),
                    icon: "dumbbell"
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
    }
}

struct GoalProgressCard: View {
    let title: String
    let targetAmount: Double
    let currentAmount: Double
    let icon: String
    
    private var progress: Double {
        return min(currentAmount / targetAmount, 1.0)
    }
    
    private var progressText: String {
        if progress >= 1.0 {
            return "目标达成！"
        } else {
            return String(format: "%.0f%%", progress * 100)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text(progressText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(progress >= 1.0 ? .green : .blue)
            }
            
            ProgressView(value: progress)
                .tint(progress >= 1.0 ? .green : .blue)
            
            HStack {
                Text(String(format: "已存: ¥%.0f", currentAmount))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(String(format: "目标: ¥%.0f", targetAmount))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct NeutralTipsSection: View {
    let tips = [
        "节省的资金可以用于其他生活目标",
        "每减少一支烟，就离财务目标更近一步",
        "健康投资是最有价值的投资",
        "小改变积累成大成果"
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("中性提示")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "quote.opening")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Text(tip)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
            }
        }
    }
}

struct EconomySettingsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    @State private var cigarettesPerDay: Int
    @State private var cigarettePrice: Double
    @State private var quitDate: Date
    
    init() {
        let appState = AppState()
        _cigarettesPerDay = State(initialValue: appState.cigarettesPerDay)
        _cigarettePrice = State(initialValue: appState.cigarettePrice)
        _quitDate = State(initialValue: appState.quitStartDate)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("吸烟习惯") {
                    Stepper("每日吸烟量: \(cigarettesPerDay)支", value: $cigarettesPerDay, in: 1...50)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("单支价格: ¥\(cigarettePrice, specifier: "%.1f")")
                        
                        Slider(value: $cigarettePrice, in: 1...20, step: 0.5)
                    }
                }
                
                Section("戒烟时间") {
                    DatePicker("戒烟开始日期", selection: $quitDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                Section {
                    Button("保存设置") {
                        saveSettings()
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("经济设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveSettings() {
        print("保存设置: \(cigarettesPerDay)支/天, ¥\(cigarettePrice)/支, 开始日期: \(quitDate)")
    }
}

#Preview {
    EconomyScreen()
        .environment(AppState())
}