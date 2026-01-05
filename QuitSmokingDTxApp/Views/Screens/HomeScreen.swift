import SwiftUI

struct HomeScreen: View {
    @Environment(AppState.self) private var appState
    @State private var showingIntervention = false
    @State private var showingSmokingConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 状态卡片
                    StatusCard()
                    
                    // 主操作按钮
                    VStack(spacing: 16) {
                        PrimaryActionButton(
                            title: "我现在很想抽",
                            icon: "flame",
                            color: .orange
                        ) {
                            appState.handleCraving()
                            showingIntervention = true
                        }
                        
                        SecondaryActionButton(
                            title: "我刚刚抽了一支",
                            icon: "smoke",
                            color: .gray
                        ) {
                            showingSmokingConfirmation = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // 今日统计
                    TodayStatsCard()
                    
                    // 快速提示
                    QuickTipsSection()
                }
                .padding(.vertical)
            }
            .navigationTitle("戒烟支持")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingIntervention) {
                InterventionScreen()
            }
            .confirmationDialog("记录吸烟", isPresented: $showingSmokingConfirmation) {
                Button("记录吸烟") {
                    appState.recordSmoking()
                }
                Button("暂不记录", role: .cancel) { }
            } message: {
                Text("这次没忍住也没关系，要记录一下吗？")
            }
        }
    }
}

struct StatusCard: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: statusIcon)
                    .font(.title2)
                    .foregroundColor(statusColor)
                
                Text(statusTitle)
                    .font(.headline)
                
                Spacer()
            }
            
            if let lastSmokeTime = appState.lastSmokeTime {
                Text("上次吸烟: \(timeAgo(from: lastSmokeTime))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("尚未记录吸烟")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if appState.quitDuration > 0 {
                Text("已坚持: \(formattedDuration(appState.quitDuration))")
                    .font(.subheadline)
                    .foregroundColor(.green)
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
    
    private var statusIcon: String {
        switch appState.smokingStatus {
        case .stable: return "checkmark.circle"
        case .highRisk: return "exclamationmark.triangle"
        case .intervention: return "clock"
        case .resisted: return "hand.thumbsup"
        case .smoked: return "smoke"
        }
    }
    
    private var statusColor: Color {
        switch appState.smokingStatus {
        case .stable: return .green
        case .highRisk: return .orange
        case .intervention: return .blue
        case .resisted: return .green
        case .smoked: return .red
        }
    }
    
    private var statusTitle: String {
        switch appState.smokingStatus {
        case .stable: return "状态稳定"
        case .highRisk: return "高风险窗口"
        case .intervention: return "干预进行中"
        case .resisted: return "成功抵抗冲动"
        case .smoked: return "已记录吸烟"
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let days = hours / 24
        
        if days > 0 {
            return "\(days)天\(hours % 24)小时"
        } else {
            return "\(hours)小时"
        }
    }
}

struct PrimaryActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(color)
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                
                Text(title)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
            .foregroundColor(color)
        }
        .buttonStyle(.plain)
    }
}

struct TodayStatsCard: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        let stats = appState.todayStats
        
        VStack(spacing: 16) {
            HStack {
                Text("今日统计")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 20) {
                StatItem(
                    value: "\(stats.cigarettes)",
                    label: "已吸烟",
                    color: .red
                )
                
                StatItem(
                    value: "\(stats.resisted)",
                    label: "成功抵抗",
                    color: .green
                )
                
                StatItem(
                    value: "\(stats.cravings)",
                    label: "冲动次数",
                    color: .orange
                )
                
                StatItem(
                    value: String(format: "¥%.1f", stats.moneySaved),
                    label: "节省金额",
                    color: .blue
                )
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
}

struct StatItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickTipsSection: View {
    let tips = [
        "深呼吸5次，慢慢呼气",
        "喝一杯水",
        "起身走动2分钟",
        "想想戒烟的好处",
        "延迟满足：等10分钟再做决定"
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("快速提示")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            ForEach(tips, id: \.self) { tip in
                HStack {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.yellow)
                    
                    Text(tip)
                        .font(.subheadline)
                    
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

#Preview {
    HomeScreen()
        .environment(AppState())
}