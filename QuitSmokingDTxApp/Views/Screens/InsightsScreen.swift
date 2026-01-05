import SwiftUI

struct InsightsScreen: View {
    @Environment(AppState.self) private var appState
    @State private var insights: [Insight] = []
    @State private var isLoading = false
    @State private var showingReflection = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 标题和说明
                    InsightsHeaderSection()
                    
                    if isLoading {
                        LoadingView()
                    } else if insights.isEmpty {
                        EmptyStateView()
                    } else {
                        // 洞察卡片列表
                        InsightsList()
                        
                        // 自我反思部分
                        ReflectionSection()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("行为洞察")
            .background(Color(.systemGroupedBackground))
            .task {
                await loadInsights()
            }
            .refreshable {
                await loadInsights()
            }
            .sheet(isPresented: $showingReflection) {
                ReflectionScreen()
            }
        }
    }
    
    private func loadInsights() async {
        isLoading = true
        defer { isLoading = false }
        
        // 模拟AI生成洞察（实际应用中应调用AI服务）
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒延迟模拟网络请求
        
        insights = generateSampleInsights()
    }
    
    private func generateSampleInsights() -> [Insight] {
        return [
            Insight(
                title: "时间模式识别",
                description: "你在晚上8-10点最容易产生吸烟冲动，这可能是晚餐后的习惯性反应。",
                confidence: .high,
                category: .pattern,
                actionTip: "尝试在晚上这个时间段安排其他活动，如散步或阅读。",
                dataPoints: ["过去7天有5次冲动发生在这个时段", "成功率比其他时段低30%"]
            ),
            Insight(
                title: "延迟满足效果",
                description: "当你使用'延迟5分钟'策略时，成功抵抗冲动的概率提高了65%。",
                confidence: .medium,
                category: .strategy,
                actionTip: "下次冲动时，先告诉自己'等5分钟再说'。",
                dataPoints: ["5分钟延迟策略成功率85%", "立即行动成功率仅20%"]
            ),
            Insight(
                title: "情绪触发关联",
                description: "工作压力是你最常见的吸烟触发因素，占所有冲动的40%。",
                confidence: .high,
                category: .trigger,
                actionTip: "尝试用深呼吸或短暂休息替代吸烟来缓解工作压力。",
                dataPoints: ["40%的冲动与工作压力相关", "压力时吸烟量增加50%"]
            ),
            Insight(
                title: "替代行为效果",
                description: "喝水和深呼吸是你最有效的替代行为，成功率分别达到78%和72%。",
                confidence: .medium,
                category: .behavior,
                actionTip: "在办公桌旁常备水杯，冲动时先喝一大口水。",
                dataPoints: ["喝水成功率78%", "深呼吸成功率72%", "走动成功率65%"]
            ),
            Insight(
                title: "进步趋势",
                description: "过去两周你的每日吸烟量减少了35%，抵抗成功率提高了20%。",
                confidence: .high,
                category: .progress,
                actionTip: "继续保持当前策略，你正在建立新的健康习惯。",
                dataPoints: ["吸烟量减少35%", "抵抗成功率提高20%", "冲动频率降低15%"]
            )
        ]
    }
}

struct InsightsHeaderSection: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("个人行为洞察")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("基于你的数据生成的个性化洞察")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            Text("AI分析你的行为模式，提供可操作的改进建议")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                )
                .padding(.horizontal)
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("正在分析你的行为数据...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("AI正在识别模式并生成个性化洞察")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("暂无洞察数据")
                .font(.headline)
            
            Text("继续使用应用，AI将根据你的行为生成个性化洞察")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("手动刷新") {
                // 刷新逻辑
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct InsightsList: View {
    @State private var insights = [
        Insight(
            title: "时间模式识别",
            description: "你在晚上8-10点最容易产生吸烟冲动",
            confidence: .high,
            category: .pattern,
            actionTip: "尝试在晚上安排其他活动",
            dataPoints: ["过去7天有5次冲动发生在这个时段"]
        )
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("AI生成洞察")
                    .font(.headline)
                Spacer()
                
                Text("\(insights.count)条洞察")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            ForEach(insights) { insight in
                InsightCard(insight: insight)
            }
        }
    }
}

struct Insight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let confidence: ConfidenceLevel
    let category: InsightCategory
    let actionTip: String
    let dataPoints: [String]
    
    enum ConfidenceLevel {
        case low, medium, high
        
        var text: String {
            switch self {
            case .low: return "低可信度"
            case .medium: return "中等可信度"
            case .high: return "高可信度"
            }
        }
        
        var color: Color {
            switch self {
            case .low: return .orange
            case .medium: return .yellow
            case .high: return .green
            }
        }
        
        var icon: String {
            switch self {
            case .low: return "exclamationmark.triangle"
            case .medium: return "checkmark.circle"
            case .high: return "star.circle"
            }
        }
    }
    
    enum InsightCategory {
        case pattern, trigger, strategy, behavior, progress
        
        var text: String {
            switch self {
            case .pattern: return "模式识别"
            case .trigger: return "触发因素"
            case .strategy: return "策略效果"
            case .behavior: return "替代行为"
            case .progress: return "进步趋势"
            }
        }
        
        var icon: String {
            switch self {
            case .pattern: return "chart.line.uptrend.xyaxis"
            case .trigger: return "bolt"
            case .strategy: return "lightbulb"
            case .behavior: return "figure.walk"
            case .progress: return "chart.bar"
            }
        }
        
        var color: Color {
            switch self {
            case .pattern: return .blue
            case .trigger: return .red
            case .strategy: return .purple
            case .behavior: return .green
            case .progress: return .orange
            }
        }
    }
}

struct InsightCard: View {
    let insight: Insight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题和置信度
            HStack {
                Label(insight.category.text, systemImage: insight.category.icon)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(insight.category.color.opacity(0.1))
                    )
                    .foregroundColor(insight.category.color)
                
                Spacer()
                
                Label(insight.confidence.text, systemImage: insight.confidence.icon)
                    .font(.caption)
                    .foregroundColor(insight.confidence.color)
            }
            
            // 洞察内容
            VStack(alignment: .leading, spacing: 8) {
                Text(insight.title)
                    .font(.headline)
                
                Text(insight.description)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            // 数据点
            if !insight.dataPoints.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("数据支持：")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(insight.dataPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 4))
                                .foregroundColor(.blue)
                                .padding(.top, 6)
                            
                            Text(point)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // 行动建议
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.yellow)
                    
                    Text("行动建议")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Text(insight.actionTip)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .padding(.leading, 24)
            }
            .padding(.top, 8)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.yellow.opacity(0.1))
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

struct ReflectionSection: View {
    @State private var showingReflection = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("自我反思")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                Text("花几分钟反思你的戒烟旅程")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    showingReflection = true
                } label: {
                    HStack {
                        Image(systemName: "pencil.and.list.clipboard")
                        Text("开始反思")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Text("AI会帮助你整理思绪，但不做任何判断")
                    .font(.caption)
                    .foregroundColor(.secondary)
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

struct ReflectionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reflectionText = ""
    @State private var selectedMood: Mood = .neutral
    @State private var isSubmitting = false
    
    enum Mood: String, CaseIterable {
        case happy = "开心"
        case neutral = "平静"
        case stressed = "压力"
        case tired = "疲惫"
        case proud = "自豪"
        
        var icon: String {
            switch self {
            case .happy: return "face.smiling"
            case .neutral: return "face.dashed"
            case .stressed: return "face.dashed.fill"
            case .tired: return "bed.double"
            case .proud: return "star"
            }
        }
        
        var color: Color {
            switch self {
            case .happy: return .yellow
            case .neutral: return .gray
            case .stressed: return .red
            case .tired: return .blue
            case .proud: return .purple
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("当前心情") {
                    Picker("选择心情", selection: $selectedMood) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            Label(mood.rawValue, systemImage: mood.icon)
                                .tag(mood)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("反思内容") {
                    TextEditor(text: $reflectionText)
                        .frame(minHeight: 150)
                        .overlay(
                            Group {
                                if reflectionText.isEmpty {
                                    VStack {
                                        Text("写下你的想法...")
                                            .foregroundColor(.secondary)
                                            .padding(.top, 8)
                                            .padding(.leading, 5)
                                        Spacer()
                                    }
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                Section {
                    Button("提交反思") {
                        submitReflection()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(reflectionText.isEmpty || isSubmitting)
                }
            }
            .navigationTitle("自我反思")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if isSubmitting {
                    ProgressView()
                        .scaleEffect(1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 10)
                                .frame(width: 100, height: 100)
                        )
                }
            }
        }
    }
    
    private func submitReflection() {
        isSubmitting = true
        
        // 模拟提交过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            dismiss()
            
            // 这里实际应该保存反思数据
            print("反思已保存: \(reflectionText)")
        }
    }
}

#Preview {
    InsightsScreen()
        .environment(AppState())
}