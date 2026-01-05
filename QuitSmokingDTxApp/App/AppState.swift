import SwiftUI
import Foundation

@MainActor
@Observable
class AppState {
    // 服务
    private let dataStorage = DataStorageService.shared
    private let notificationService = NotificationService.shared
    
    // 导航状态
    var navigationPath = NavigationPath()
    var selectedTab: Tab = .home
    
    // 应用状态
    var isLoading = false
    var error: AppError?
    var user: User?
    
    // 戒烟状态
    var smokingStatus: SmokingStatus = .stable
    var lastSmokeTime: Date?
    var cravingsCountToday = 0
    var resistedCravingsCountToday = 0
    
    // 用户设置
    var cigarettesPerDay: Int = 10
    var cigarettePrice: Double = 5.0
    var quitStartDate: Date = Date()
    
    // 数据存储
    var smokingEvents: [SmokingEvent] = []
    var cravingEvents: [CravingEvent] = []
    
    // 通知设置
    var notificationsEnabled = true
    var highRiskNotificationsEnabled = true
    var encouragementNotificationsEnabled = true
    
    enum Tab: Hashable {
        case home, trends, insights, economy
    }
    
    func initialize() async {
        isLoading = true
        defer { isLoading = false }
        
        // 记录应用启动
        dataStorage.recordAppLaunch()
        
        // 请求通知权限
        await requestNotificationPermission()
        
        // 加载用户数据
        await loadUserData()
        
        // 加载历史数据
        await loadHistoricalData()
        
        // 检查高风险窗口并安排通知
        await checkHighRiskWindows()
        
        // 安排鼓励通知
        scheduleEncouragementNotifications()
    }
    
    private func requestNotificationPermission() async {
        let granted = await notificationService.requestAuthorization()
        if granted {
            print("通知权限已授予")
        } else {
            print("通知权限被拒绝")
        }
    }
    
    private func loadUserData() async {
        // 从持久化存储加载用户设置
        cigarettesPerDay = dataStorage.loadCigarettesPerDay()
        cigarettePrice = dataStorage.loadCigarettePrice()
        quitStartDate = dataStorage.loadQuitStartDate()
        
        // 加载通知设置
        let notificationSettings = dataStorage.loadNotificationSettings()
        notificationsEnabled = notificationSettings.dailyReminderEnabled
        highRiskNotificationsEnabled = notificationSettings.highRiskEnabled
        encouragementNotificationsEnabled = notificationSettings.encouragementEnabled
        
        // 安排每日提醒
        if notificationsEnabled {
            notificationService.scheduleDailyReminder(time: notificationSettings.dailyReminderTime)
        }
    }
    
    private func loadHistoricalData() async {
        // 从持久化存储加载历史数据
        smokingEvents = dataStorage.loadSmokingEvents()
        cravingEvents = dataStorage.loadCravingEvents()
        
        // 更新今日统计
        updateTodayStats()
    }
    
    private func checkHighRiskWindows() async {
        // 分析高风险窗口
        let highRiskWindows = notificationService.analyzeHighRiskWindows(from: cravingEvents)
        
        // 安排高风险窗口通知
        if highRiskNotificationsEnabled {
            notificationService.scheduleHighRiskWindowNotifications(for: highRiskWindows)
        }
    }
    
    private func scheduleEncouragementNotifications() {
        if encouragementNotificationsEnabled {
            // 每天安排1-2个鼓励通知
            let notificationCount = Int.random(in: 1...2)
            for _ in 0..<notificationCount {
                notificationService.scheduleEncouragementNotification()
            }
        }
    }
    
    private func updateTodayStats() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        cravingsCountToday = cravingEvents.filter {
            calendar.startOfDay(for: $0.timestamp) == today
        }.count
        
        resistedCravingsCountToday = cravingEvents.filter {
            calendar.startOfDay(for: $0.timestamp) == today && $0.resisted
        }.count
        
        // 更新最后吸烟时间
        lastSmokeTime = smokingEvents.max(by: { $0.timestamp < $1.timestamp })?.timestamp
    }
    
    private func saveData() {
        // 保存吸烟事件
        dataStorage.saveSmokingEvents(smokingEvents)
        
        // 保存冲动事件
        dataStorage.saveCravingEvents(cravingEvents)
        
        // 保存用户设置
        let userSettings = UserSettings(
            name: user?.name,
            age: user?.age,
            smokingYears: user?.smokingYears,
            dailyCigarettes: cigarettesPerDay,
            cigarettePrice: cigarettePrice,
            quitStartDate: quitStartDate,
            notificationEnabled: notificationsEnabled
        )
        dataStorage.saveUserSettings(userSettings)
        
        // 保存通知设置
        let notificationSettings = NotificationSettings(
            highRiskEnabled: highRiskNotificationsEnabled,
            encouragementEnabled: encouragementNotificationsEnabled,
            dailyReminderEnabled: notificationsEnabled,
            dailyReminderTime: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
        )
        dataStorage.saveNotificationSettings(notificationSettings)
        
        // 保存单独设置
        dataStorage.saveCigarettesPerDay(cigarettesPerDay)
        dataStorage.saveCigarettePrice(cigarettePrice)
        dataStorage.saveQuitStartDate(quitStartDate)
    }
    
    // 处理吸烟冲动
    func handleCraving() {
        // 记录冲动事件
        let event = CravingEvent(
            timestamp: Date(),
            intensity: .high,
            context: "自主触发",
            resisted: false
        )
        cravingEvents.append(event)
        
        // 更新状态
        smokingStatus = .highRisk
        cravingsCountToday += 1
        
        // 保存数据
        saveData()
    }
    
    // 记录吸烟事件
    func recordSmoking() {
        let event = SmokingEvent(
            timestamp: Date(),
            cigarettes: 1,
            context: "记录吸烟",
            resisted: false
        )
        smokingEvents.append(event)
        
        // 更新状态
        smokingStatus = .smoked
        lastSmokeTime = Date()
        
        // 保存数据
        saveData()
    }
    
    // 记录成功抵抗
    func recordResistedCraving(duration: TimeInterval) {
        let event = CravingEvent(
            timestamp: Date(),
            intensity: .high,
            context: "成功抵抗",
            resisted: true,
            resistanceDuration: duration
        )
        cravingEvents.append(event)
        
        // 更新状态
        smokingStatus = .resisted
        resistedCravingsCountToday += 1
        
        // 保存数据
        saveData()
    }
    
    // 获取今日统计数据
    var todayStats: TodayStats {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todaySmokingEvents = smokingEvents.filter {
            calendar.startOfDay(for: $0.timestamp) == today
        }
        
        let todayCravingEvents = cravingEvents.filter {
            calendar.startOfDay(for: $0.timestamp) == today
        }
        
        let cigarettesToday = todaySmokingEvents.reduce(0) { $0 + $1.cigarettes }
        let resistedToday = todayCravingEvents.filter { $0.resisted }.count
        
        return TodayStats(
            cigarettes: cigarettesToday,
            resisted: resistedToday,
            cravings: todayCravingEvents.count,
            moneySaved: Double(cigarettesToday) * cigarettePrice
        )
    }
    
    // 获取戒烟时长
    var quitDuration: TimeInterval {
        return Date().timeIntervalSince(quitStartDate)
    }
    
    // 获取金钱节省统计
    var moneySaved: Double {
        let totalCigarettes = smokingEvents.reduce(0) { $0 + $1.cigarettes }
        let expectedCigarettes = Double(cigarettesPerDay) * (quitDuration / (24 * 3600))
        return (expectedCigarettes - Double(totalCigarettes)) * cigarettePrice
    }
    
    // 数据管理方法
    func exportData() -> Data? {
        return dataStorage.exportAllData()
    }
    
    func deleteAllData() {
        dataStorage.deleteAllUserData()
        smokingEvents = []
        cravingEvents = []
        cigarettesPerDay = 10
        cigarettePrice = 5.0
        quitStartDate = Date()
        
        // 取消所有通知
        notificationService.cancelAllNotifications()
    }
    
    func anonymizeData() {
        dataStorage.anonymizeData()
        // 重新加载匿名化后的数据
        smokingEvents = dataStorage.loadSmokingEvents()
        cravingEvents = dataStorage.loadCravingEvents()
    }
    
    func cleanupOldData() {
        dataStorage.cleanupOldData()
        // 重新加载清理后的数据
        smokingEvents = dataStorage.loadSmokingEvents()
        cravingEvents = dataStorage.loadCravingEvents()
    }
}

enum AppError: LocalizedError {
    case dataLoadError(String)
    case networkError(Error)
    case storageError(String)
    
    var errorDescription: String? {
        switch self {
        case .dataLoadError(let message):
            return "数据加载失败: \(message)"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .storageError(let message):
            return "存储错误: \(message)"
        }
    }
}

struct User {
    var name: String?
    var age: Int?
    var smokingYears: Int?
    var dailyCigarettes: Int
}

enum SmokingStatus {
    case stable          // 稳定状态
    case highRisk        // 高风险状态
    case intervention    // 干预中
    case resisted        // 成功抑制
    case smoked          // 已吸烟
}

struct SmokingEvent: Identifiable {
    var id = UUID()
    let timestamp: Date
    let cigarettes: Int
    let context: String
    let resisted: Bool
}

struct CravingEvent: Identifiable {
    var id = UUID()
    let timestamp: Date
    let intensity: CravingIntensity
    let context: String
    let resisted: Bool
    var resistanceDuration: TimeInterval?
    
    enum CravingIntensity {
        case low, medium, high
    }
}

struct TodayStats {
    let cigarettes: Int
    let resisted: Int
    let cravings: Int
    let moneySaved: Double
}