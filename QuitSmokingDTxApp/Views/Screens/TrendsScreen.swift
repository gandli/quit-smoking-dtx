import SwiftUI
import Charts

struct TrendsScreen: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showingStatsDetail = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 时间范围选择器
                    TimeRangePicker(selection: $selectedTimeRange)
                    
                    // 核心指标卡片
                    CoreMetricsCard()
                    
                    // 趋势图表
                    TrendsChart(timeRange: selectedTimeRange)
                    
                    // 详细统计
                    DetailedStatsSection()
                    
                    // 成就徽章
                    AchievementBadges()
                }
                .padding(.vertical)
            }
            .navigationTitle("行为趋势")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingStatsDetail) {
                StatsDetailScreen()
            }
        }
    }
}

enum TimeRange: String, CaseIterable {
    case week = "本周"
    case month = "本月"
    case threeMonths = "近3月"
    case year = "今年"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .year: return 365
        }
    }
}

struct TimeRangePicker: View {
    @Binding var selection: TimeRange
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button(action: { selection = range }) {
                        Text(range.rawValue)
                            .font(.subheadline)
                            .fontWeight(selection == range ? .semibold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selection == range ? Color.blue : Color(.secondarySystemBackground))
                            )
                            .foregroundColor(selection == range ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CoreMetricsCard: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        let stats = calculateWeeklyStats()
        
        VStack(spacing: 20) {
            HStack {
                Text("核心指标")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    MetricItem(
                        value: "\(stats.cigarettesReduction)",
                        label: "本周少抽",
                        unit: "支",
                        trend: stats.cigarettesTrend,
                        color: .green
                    )
                    
                    MetricItem(
                        value: "\(stats.resistedCount)",
                        label: "成功忍住",
                        unit: "次",
                        trend: .up,
                        color: .blue
                    )
                }
                
                HStack(spacing: 20) {
                    MetricItem(
                        value: String(format: "%.1f", stats.successRate),
                        label: "成功率",
                        unit: "%",
                        trend: stats.successRate > 50 ? .up : .down,
                        color: .orange
                    )
                    
                    MetricItem(
                        value: String(format: "¥%.0f", stats.moneySaved),
                        label: "节省金额",
                        unit: "",
                        trend: .up,
                        color: .purple
                    )
                }
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
    
    private func calculateWeeklyStats() -> WeeklyStats {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        
        let weeklySmokingEvents = appState.smokingEvents.filter {
            $0.timestamp >= weekAgo && $0.timestamp <= today
        }
        
        let weeklyCravingEvents = appState.cravingEvents.filter {
            $0.timestamp >= weekAgo && $0.timestamp <= today
        }
        
        let cigarettesThisWeek = weeklySmokingEvents.reduce(0) { $0 + $1.cigarettes }
        let resistedThisWeek = weeklyCravingEvents.filter { $0.resisted }.count
        let totalCravingsThisWeek = weeklyCravingEvents.count
        
        // 计算减少量（基于每日吸烟量设置）
        let expectedCigarettes = appState.cigarettesPerDay * 7
        let cigarettesReduction = max(0, expectedCigarettes - cigarettesThisWeek)
        
        // 计算成功率
        let successRate = totalCravingsThisWeek > 0 ?
            Double(resistedThisWeek) / Double(totalCravingsThisWeek) * 100 : 0
        
        // 计算节省金额
        let moneySaved = Double(cigarettesReduction) * appState.cigarettePrice
        
        // 判断趋势（简化版）
        let cigarettesTrend: TrendDirection = cigarettesThisWeek < (expectedCigarettes / 2) ? .up : .down
        
        return WeeklyStats(
            cigarettesReduction: cigarettesReduction,
            resistedCount: resistedThisWeek,
            successRate: successRate,
            moneySaved: moneySaved,
            cigarettesTrend: cigarettesTrend
        )
    }
}

struct WeeklyStats {
    let cigarettesReduction: Int
    let resistedCount: Int
    let successRate: Double
    let moneySaved: Double
    let cigarettesTrend: TrendDirection
}

enum TrendDirection {
    case up, down, stable
    
    var icon: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        }
    }
    
    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .red
        case .stable: return .gray
        }
    }
}

struct MetricItem: View {
    let value: String
    let label: String
    let unit: String
    let trend: TrendDirection
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: trend.icon)
                    .font(.caption)
                    .foregroundColor(trend.color)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TrendsChart: View {
    @Environment(AppState.self) private var appState
    let timeRange: TimeRange
    
    @State private var chartType: Int = 0 // 0: 柱状图, 1: 折线图
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("吸烟 vs 忍住趋势")
                    .font(.headline)
                
                Picker("图表类型", selection: $chartType) {
                    Text("柱状图").tag(0)
                    Text("折线图").tag(1)
                }
                .pickerStyle(.segmented)
            }
            
            Chart {
                ForEach(sampleData) { data in
                    if chartType == 0 {
                        BarMark(
                            x: .value("日期", data.date, unit: .day),
                            y: .value("数量", data.smokingCount)
                        )
                        .foregroundStyle(.red.opacity(0.7))
                        .cornerRadius(4)
                        
                        BarMark(
                            x: .value("日期", data.date, unit: .day),
                            y: .value("数量", data.resistedCount)
                        )
                        .foregroundStyle(.green.opacity(0.7))
                        .cornerRadius(4)
                    } else {
                        LineMark(
                            x: .value("日期", data.date, unit: .day),
                            y: .value("数量", data.smokingCount),
                            series: .value("类型", "吸烟")
                        )
                        .foregroundStyle(.red)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("日期", data.date, unit: .day),
                            y: .value("数量", data.smokingCount)
                        )
                        .foregroundStyle(.red)
                        
                        LineMark(
                            x: .value("日期", data.date, unit: .day),
                            y: .value("数量", data.resistedCount),
                            series: .value("类型", "忍住")
                        )
                        .foregroundStyle(.green)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("日期", data.date, unit: .day),
                            y: .value("数量", data.resistedCount)
                        )
                        .foregroundStyle(.green)
                    }
                }
            }
            .frame(height: 200)
            .chartForegroundStyleScale([
                "吸烟": .red,
                "忍住": .green
            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day())
                }
            }
            .chartYAxis {
                AxisMarks()
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
    
    private var sampleData: [DailyData] {
        // 生成示例数据
        var data: [DailyData] = []
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<timeRange.days {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            // 随机生成数据（实际应用中应从真实数据计算）
            let smokingCount = Int.random(in: 0...5)
            let resistedCount = Int.random(in: 0...8)
            
            data.append(DailyData(
                date: date,
                smokingCount: smokingCount,
                resistedCount: resistedCount
            ))
        }
        
        return data.sorted { $0.date < $1.date }
    }
}

struct DailyData: Identifiable {
    let id = UUID()
    let date: Date
    let smokingCount: Int
    let resistedCount: Int
}

struct DetailedStatsSection: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("详细统计")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                StatRow(
                    label: "戒烟天数",
                    value: "\(Int(appState.quitDuration / (24 * 3600)))",
                    icon: "calendar"
                )
                
                StatRow(
                    label: "总节省金额",
                    value: String(format: "¥%.0f", appState.moneySaved),
                    icon: "dollarsign.circle"
                )
                
                StatRow(
                    label: "总抵抗次数",
                    value: "\(appState.cravingEvents.filter { $0.resisted }.count)",
                    icon: "hand.thumbsup"
                )
                
                StatRow(
                    label: "平均每日吸烟",
                    value: String(format: "%.1f支", averageDailyCigarettes()),
                    icon: "smoke"
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
    
    private func averageDailyCigarettes() -> Double {
        guard !appState.smokingEvents.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let firstDate = appState.smokingEvents.map { $0.timestamp }.min() ?? Date()
        let days = calendar.dateComponents([.day], from: firstDate, to: Date()).day ?? 1
        
        let totalCigarettes = appState.smokingEvents.reduce(0) { $0 + $1.cigarettes }
        return Double(totalCigarettes) / Double(max(days, 1))
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(label)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct AchievementBadges: View {
    let badges = [
        ("首日无烟", "1day", Color.green),
        ("一周坚持", "7day", Color.blue),
        ("节省百元", "100yuan", Color.orange),
        ("十次抵抗", "10resist", Color.purple)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("成就徽章")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(badges, id: \.0) { badge in
                        BadgeView(
                            title: badge.0,
                            icon: badge.1,
                            color: badge.2,
                            isUnlocked: Bool.random() // 示例数据
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct BadgeView: View {
    let title: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Image(systemName: isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                    .font(.title2)
                    .foregroundColor(isUnlocked ? color : .gray)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(isUnlocked ? .primary : .secondary)
        }
    }
}

struct StatsDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("本周统计") {
                    DetailRow(title: "吸烟次数", value: "12次")
                    DetailRow(title: "抵抗次数", value: "8次")
                    DetailRow(title: "成功率", value: "40%")
                    DetailRow(title: "减少吸烟", value: "28支")
                }
                
                Section("最佳表现") {
                    DetailRow(title: "最长无烟时间", value: "3天2小时")
                    DetailRow(title: "单日最少吸烟", value: "2支")
                    DetailRow(title: "单日最多抵抗", value: "5次")
                }
                
                Section("模式识别") {
                    DetailRow(title: "高风险时段", value: "晚上8-10点")
                    DetailRow(title: "最常见触发", value: "工作压力")
                    DetailRow(title: "最有效替代", value: "深呼吸")
                }
            }
            .navigationTitle("详细统计")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    TrendsScreen()
        .environment(AppState())
}
