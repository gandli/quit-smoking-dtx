import Foundation
import UserNotifications

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var notificationsEnabled = true
    @Published var highRiskNotificationsEnabled = true
    @Published var encouragementNotificationsEnabled = true
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        setupNotificationCategories()
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("请求通知权限失败: \(error)")
            return false
        }
    }
    
    func scheduleHighRiskWindowNotification(time: Date, context: String) {
        guard highRiskNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "高风险窗口提醒"
        content.body = "这是你容易想抽的时候（\(context)），要不要缓一缓？"
        content.sound = .default
        content.categoryIdentifier = "HIGH_RISK_CATEGORY"
        
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "high_risk_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("安排高风险通知失败: \(error)")
            }
        }
    }
    
    func scheduleEncouragementNotification() {
        guard encouragementNotificationsEnabled else { return }
        
        let messages = [
            "今天你成功抵抗了冲动，真棒！",
            "每减少一支烟，健康就多一分保障",
            "坚持就是胜利，你做得很好",
            "想想呼吸新鲜空气的感觉",
            "你的健康值得每一份努力"
        ]
        
        let randomMessage = messages.randomElement() ?? "继续努力，你正在变得更好"
        
        let content = UNMutableNotificationContent()
        content.title = "戒烟鼓励"
        content.body = randomMessage
        content.sound = .default
        content.categoryIdentifier = "ENCOURAGEMENT_CATEGORY"
        
        // 随机安排在白天时间（9:00-20:00）
        let randomHour = Int.random(in: 9...20)
        let randomMinute = Int.random(in: 0...59)
        
        var dateComponents = DateComponents()
        dateComponents.hour = randomHour
        dateComponents.minute = randomMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "encouragement_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("安排鼓励通知失败: \(error)")
            }
        }
    }
    
    func scheduleDailyReminder(time: Date) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "每日提醒"
        content.body = "记得记录今天的吸烟情况，坚持就是胜利！"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("安排每日提醒失败: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(with identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    private func setupNotificationCategories() {
        // 高风险窗口类别
        let highRiskCategory = UNNotificationCategory(
            identifier: "HIGH_RISK_CATEGORY",
            actions: [
                UNNotificationAction(
                    identifier: "DELAY_ACTION",
                    title: "延迟5分钟",
                    options: []
                ),
                UNNotificationAction(
                    identifier: "RECORD_CRAVING_ACTION",
                    title: "记录冲动",
                    options: []
                ),
                UNNotificationAction(
                    identifier: "DISMISS_ACTION",
                    title: "忽略",
                    options: .destructive
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        // 鼓励类别
        let encouragementCategory = UNNotificationCategory(
            identifier: "ENCOURAGEMENT_CATEGORY",
            actions: [
                UNNotificationAction(
                    identifier: "THANKS_ACTION",
                    title: "谢谢提醒",
                    options: []
                ),
                UNNotificationAction(
                    identifier: "RECORD_RESISTED_ACTION",
                    title: "记录成功抵抗",
                    options: []
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([highRiskCategory, encouragementCategory])
    }
    
    // 检查用户的高风险时间段
    func analyzeHighRiskWindows(from events: [CravingEvent]) -> [HighRiskWindow] {
        var hourCounts = Array(repeating: 0, count: 24)
        
        for event in events {
            let hour = Calendar.current.component(.hour, from: event.timestamp)
            hourCounts[hour] += 1
        }
        
        var windows: [HighRiskWindow] = []
        
        // 找出 cravings 最多的3个小时
        let topHours = hourCounts.enumerated()
            .sorted { $0.element > $1.element }
            .prefix(3)
            .map { $0.offset }
        
        for hour in topHours {
            if hourCounts[hour] > 0 {
                let window = HighRiskWindow(
                    hour: hour,
                    cravingCount: hourCounts[hour],
                    context: getContextForHour(hour)
                )
                windows.append(window)
            }
        }
        
        return windows.sorted { $0.cravingCount > $1.cravingCount }
    }
    
    private func getContextForHour(_ hour: Int) -> String {
        switch hour {
        case 6...9:
            return "早晨"
        case 10...12:
            return "上午"
        case 13...15:
            return "午后"
        case 16...18:
            return "傍晚"
        case 19...22:
            return "晚上"
        case 23, 0...5:
            return "深夜"
        default:
            return "其他时间"
        }
    }
    
    // 安排基于分析的高风险窗口通知
    func scheduleHighRiskWindowNotifications(for windows: [HighRiskWindow]) {
        for window in windows {
            // 只在 cravings 数量达到阈值时安排通知
            if window.cravingCount >= 3 {
                let date = Calendar.current.date(bySettingHour: window.hour, minute: 0, second: 0, of: Date()) ?? Date()
                scheduleHighRiskWindowNotification(time: date, context: window.context)
            }
        }
    }
}

struct HighRiskWindow {
    let hour: Int
    let cravingCount: Int
    let context: String
}