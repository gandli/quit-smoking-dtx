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
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("吸烟 vs 忍住趋势")
                    .font(.headline)
                Spacer()
            }
            
            ContributionChart(data: sampleData, timeRange: timeRange)
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

struct HeatmapChart: View {
    let data: [DailyData]
    let timeRange: TimeRange
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Chart(data) { item in
                RectangleMark(
                    xStart: .value("Start week", item.date, unit: .weekOfYear),
                    xEnd: .value("End week", item.date, unit: .weekOfYear),
                    yStart: .value("Start weekday", weekday(for: item.date)),
                    yEnd: .value("End weekday", weekday(for: item.date) + 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius).inset(by: insetBy))
                .foregroundStyle(by: .value("抵抗次数", item.resistedCount))
            }
            .chartPlotStyle { content in
                content
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .frame(height: chartHeight)
            }
            .chartForegroundStyleScale(range: Gradient(colors: colors))
            .chartXAxis {
                if shouldShowMonthLabels {
                    AxisMarks(position: .top, values: .stride(by: .month)) {
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                            .foregroundStyle(Color(.label))
                            .font(.system(size: xAxisFontSize))
                    }
                } else {
                    AxisMarks(position: .top) { _ in
                        AxisValueLabel("")
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: yAxisValues) { value in
                    if let value = value.as(Int.self) {
                        AxisValueLabel {
                            Text(weekdayLabel(for: value))
                                .font(.system(size: yAxisFontSize))
                        }
                        .foregroundStyle(Color(.label))
                    }
                }
            }
            .chartYScale(domain: .automatic(includesZero: false, reversed: true))
            .chartLegend {
                HStack(spacing: 4) {
                    Text("少")
                        .font(.caption2)
                    ForEach(legendColors, id: \.self) { color in
                        color
                            .frame(width: 10, height: 10)
                            .cornerRadius(2)
                    }
                    Text("多")
                        .font(.caption2)
                }
                .padding(4)
                .foregroundStyle(Color(.label))
            }
            .padding(.trailing, 20)
        }
    }
    
    // 根据时间范围调整方格大小
    private func getCellSize() -> CGFloat {
        switch timeRange {
        case .week: return 24
        case .month: return 18
        case .threeMonths: return 12
        case .year: return 8
        }
    }
    
    private var cornerRadius: CGFloat {
        switch timeRange {
        case .week: return 3
        case .month: return 2
        case .threeMonths: return 2
        case .year: return 1
        }
    }
    
    private var insetBy: CGFloat {
        switch timeRange {
        case .week: return 2
        case .month: return 1.5
        case .threeMonths: return 1
        case .year: return 0.5
        }
    }
    
    private var chartHeight: CGFloat {
        switch timeRange {
        case .week: return 200
        case .month: return 180
        case .threeMonths: return 150
        case .year: return 120
        }
    }
    
    private var shouldShowMonthLabels: Bool {
        timeRange != .week
    }
    
    private var xAxisFontSize: CGFloat {
        switch timeRange {
        case .week: return 10
        case .month: return 9
        case .threeMonths: return 8
        case .year: return 7
        }
    }
    
    private var yAxisFontSize: CGFloat {
        switch timeRange {
        case .week: return 11
        case .month: return 10
        case .threeMonths: return 9
        case .year: return 8
        }
    }
    
    private var yAxisValues: [Int] {
        switch timeRange {
        case .week: return [1, 2, 3, 4, 5, 6, 7]
        case .month: return [1, 3, 5, 7]
        case .threeMonths, .year: return [1, 4, 7]
        }
    }
    
    // 将周日(1)转换为7，其他星期减1，使周一为1
    private func weekday(for date: Date) -> Int {
        let weekday = Calendar.current.component(.weekday, from: date)
        let adjustedWeekday = (weekday == 1) ? 7 : (weekday - 1)
        return adjustedWeekday
    }
    
    private func weekdayLabel(for value: Int) -> String {
        let labels = ["一", "二", "三", "四", "五", "六", "日"]
        return labels[value - 1]
    }
    
    private var aspectRatio: Double {
        if data.isEmpty { return 1 }
        let firstDate = data.first!.date
        let lastDate = data.last!.date
        let firstWeek = Calendar.current.component(.weekOfYear, from: firstDate)
        let lastWeek = Calendar.current.component(.weekOfYear, from: lastDate)
        return Double(lastWeek - firstWeek + 1) / 7
    }
    
    private var colors: [Color] {
        (0...10).map { index in
            if index == 0 {
                return Color(.systemGray5)
            }
            return Color(.systemGreen).opacity(Double(index) / 10)
        }
    }
    
    private var legendColors: [Color] {
        Array(stride(from: 0, to: colors.count, by: 2).map { colors[$0] })
    }
}

// MARK: - 简化版贡献图
struct ContributionChart: View {
    let data: [DailyData]
    let timeRange: TimeRange
    
    private let weekdays = ["一", "三", "五", "日"]
    
    var body: some View {
        VStack(spacing: 8) {
            // 图表主体
            GeometryReader { geometry in
                let cellSize = calculateCellSize(width: geometry.size.width)
                let spacing: CGFloat = 2
                
                HStack(alignment: .top, spacing: 0) {
                    // Y 轴标签
                    VStack(spacing: 0) {
                        ForEach(0..<7) { index in
                            if index % 2 == 0 {
                                Text(weekdays[index / 2])
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                                    .frame(height: cellSize + spacing)
                            } else {
                                Color.clear.frame(height: cellSize + spacing)
                            }
                        }
                    }
                    .frame(width: 16)
                    
                    // 热力图方格
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: 7), spacing: spacing) {
                            ForEach(sortedData) { item in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(colorForCount(item.resistedCount))
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                        .padding(.trailing, 8)
                    }
                }
            }
            .frame(height: chartHeight)
            
            // 图例
            HStack(spacing: 4) {
                Spacer()
                Text("少")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                ForEach(legendColors, id: \.self) { color in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: 10, height: 10)
                }
                Text("多")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var sortedData: [DailyData] {
        data.sorted { $0.date < $1.date }
    }
    
    private func calculateCellSize(width: CGFloat) -> CGFloat {
        switch timeRange {
        case .week: return 22
        case .month: return 16
        case .threeMonths: return 12
        case .year: return 8
        }
    }
    
    private var chartHeight: CGFloat {
        switch timeRange {
        case .week: return 180
        case .month: return 150
        case .threeMonths: return 120
        case .year: return 90
        }
    }
    
    private func colorForCount(_ count: Int) -> Color {
        if count == 0 { return Color(.systemGray5) }
        else if count <= 2 { return Color.green.opacity(0.3) }
        else if count <= 4 { return Color.green.opacity(0.5) }
        else if count <= 6 { return Color.green.opacity(0.7) }
        else { return Color.green }
    }
    
    private var legendColors: [Color] {
        [
            Color(.systemGray5),
            Color.green.opacity(0.3),
            Color.green.opacity(0.5),
            Color.green.opacity(0.7),
            Color.green
        ]
    }
}
