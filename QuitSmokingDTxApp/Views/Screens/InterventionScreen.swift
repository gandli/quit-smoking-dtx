import SwiftUI

struct InterventionScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @State private var timeRemaining = 300 // 5分钟，单位：秒
    @State private var timer: Timer?
    @State private var isCompleted = false
    @State private var selectedAlternative: AlternativeAction?
    @State private var showCompletionOptions = false
    
    let interventionDuration = 300 // 5分钟
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // 倒计时进度环
                CountdownRing(
                    progress: Double(timeRemaining) / Double(interventionDuration),
                    timeRemaining: timeRemaining
                )
                .frame(width: 200, height: 200)
                
                // 文案区
                VStack(spacing: 12) {
                    Text(interventionPhrase)
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("坚持就是胜利！")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 替代行为按钮
                VStack(spacing: 12) {
                    Text("试试这些替代行为：")
                        .font(.headline)
                    
                    ForEach(AlternativeAction.allCases, id: \.self) { action in
                        AlternativeActionButton(
                            action: action,
                            isSelected: selectedAlternative == action
                        ) {
                            selectedAlternative = action
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 完成按钮
                if isCompleted {
                    VStack(spacing: 16) {
                        Button("我成功抵抗了冲动") {
                            appState.recordResistedCraving(duration: TimeInterval(interventionDuration - timeRemaining))
                            showCompletionOptions = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button("我还是想抽") {
                            dismiss()
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .padding(.vertical, 40)
            .navigationTitle("冲动干预")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        timer?.invalidate()
                        dismiss()
                    }
                }
            }
            .onAppear {
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
            .confirmationDialog("完成干预", isPresented: $showCompletionOptions) {
                Button("记录成功抵抗") {
                    appState.recordResistedCraving(duration: TimeInterval(interventionDuration - timeRemaining))
                    dismiss()
                }
                Button("返回继续") { }
            } message: {
                Text("你成功抵抗了这次冲动！")
            }
        }
    }
    
    private var interventionPhrase: String {
        let phrases = [
            "冲动就像海浪，它会过去",
            "每抵抗一次，你就更强大",
            "想想呼吸新鲜空气的感觉",
            "你的健康值得这5分钟的坚持",
            "这不是放弃，而是选择更好的自己"
        ]
        
        if timeRemaining > 240 {
            return phrases[0]
        } else if timeRemaining > 180 {
            return phrases[1]
        } else if timeRemaining > 120 {
            return phrases[2]
        } else if timeRemaining > 60 {
            return phrases[3]
        } else {
            return phrases[4]
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    isCompleted = true
                }
            }
        }
    }
}

struct CountdownRing: View {
    let progress: Double
    let timeRemaining: Int
    
    var body: some View {
        ZStack {
            // 背景环
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
            
            // 进度环
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.orange, .yellow, .green]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            // 时间显示
            VStack {
                Text(formattedTime)
                    .font(.system(size: 32, weight: .bold))
                    .monospacedDigit()
                
                Text("剩余时间")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

enum AlternativeAction: String, CaseIterable {
    case drinkWater = "喝水"
    case deepBreath = "深呼吸"
    case walkAround = "走动一下"
    case distraction = "转移注意力"
    
    var icon: String {
        switch self {
        case .drinkWater: return "drop"
        case .deepBreath: return "wind"
        case .walkAround: return "figure.walk"
        case .distraction: return "brain.head.profile"
        }
    }
    
    var description: String {
        switch self {
        case .drinkWater: return "喝一杯水，慢慢吞咽"
        case .deepBreath: return "深呼吸5次，专注呼吸"
        case .walkAround: return "起身走动2分钟"
        case .distraction: return "想一件有趣的事"
        }
    }
    
    var color: Color {
        switch self {
        case .drinkWater: return .blue
        case .deepBreath: return .green
        case .walkAround: return .orange
        case .distraction: return .purple
        }
    }
}

struct AlternativeActionButton: View {
    let action: AlternativeAction
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: action.icon)
                    .font(.title2)
                    .foregroundColor(action.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(action.rawValue)
                        .font(.headline)
                    
                    Text(action.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? action.color.opacity(0.1) : Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? action.color.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    InterventionScreen()
        .environment(AppState())
}