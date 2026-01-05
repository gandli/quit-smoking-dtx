import Foundation
import SwiftData

@MainActor
class DataStorageService {
    static let shared = DataStorageService()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let smokingEvents = "smoking_events"
        static let cravingEvents = "craving_events"
        static let userSettings = "user_settings"
        static let quitStartDate = "quit_start_date"
        static let cigarettesPerDay = "cigarettes_per_day"
        static let cigarettePrice = "cigarette_price"
        static let notificationSettings = "notification_settings"
        static let lastAppLaunch = "last_app_launch"
    }
    
    // MARK: - Smoking Events
    func saveSmokingEvents(_ events: [SmokingEvent]) {
        do {
            let data = try encoder.encode(events)
            userDefaults.set(data, forKey: Keys.smokingEvents)
        } catch {
            print("保存吸烟事件失败: \(error)")
        }
    }
    
    func loadSmokingEvents() -> [SmokingEvent] {
        guard let data = userDefaults.data(forKey: Keys.smokingEvents) else {
            return []
        }
        
        do {
            return try decoder.decode([SmokingEvent].self, from: data)
        } catch {
            print("加载吸烟事件失败: \(error)")
            return []
        }
    }
    
    // MARK: - Craving Events
    func saveCravingEvents(_ events: [CravingEvent]) {
        do {
            let data = try encoder.encode(events)
            userDefaults.set(data, forKey: Keys.cravingEvents)
        } catch {
            print("保存冲动事件失败: \(error)")
        }
    }
    
    func loadCravingEvents() -> [CravingEvent] {
        guard let data = userDefaults.data(forKey: Keys.cravingEvents) else {
            return []
        }
        
        do {
            return try decoder.decode([CravingEvent].self, from: data)
        } catch {
            print("加载冲动事件失败: \(error)")
            return []
        }
    }
    
    // MARK: - User Settings
    func saveUserSettings(_ settings: UserSettings) {
        do {
            let data = try encoder.encode(settings)
            userDefaults.set(data, forKey: Keys.userSettings)
        } catch {
            print("保存用户设置失败: \(error)")
        }
    }
    
    func loadUserSettings() -> UserSettings {
        guard let data = userDefaults.data(forKey: Keys.userSettings) else {
            return UserSettings.defaultSettings
        }
        
        do {
            return try decoder.decode(UserSettings.self, from: data)
        } catch {
            print("加载用户设置失败: \(error)")
            return UserSettings.defaultSettings
        }
    }
    
    // MARK: - Individual Settings
    func saveQuitStartDate(_ date: Date) {
        userDefaults.set(date, forKey: Keys.quitStartDate)
    }
    
    func loadQuitStartDate() -> Date {
        return userDefaults.object(forKey: Keys.quitStartDate) as? Date ?? Date()
    }
    
    func saveCigarettesPerDay(_ count: Int) {
        userDefaults.set(count, forKey: Keys.cigarettesPerDay)
    }
    
    func loadCigarettesPerDay() -> Int {
        let count = userDefaults.integer(forKey: Keys.cigarettesPerDay)
        return count > 0 ? count : 10 // 默认值
    }
    
    func saveCigarettePrice(_ price: Double) {
        userDefaults.set(price, forKey: Keys.cigarettePrice)
    }
    
    func loadCigarettePrice() -> Double {
        let price = userDefaults.double(forKey: Keys.cigarettePrice)
        return price > 0 ? price : 5.0 // 默认值
    }
    
    // MARK: - Notification Settings
    func saveNotificationSettings(_ settings: NotificationSettings) {
        do {
            let data = try encoder.encode(settings)
            userDefaults.set(data, forKey: Keys.notificationSettings)
        } catch {
            print("保存通知设置失败: \(error)")
        }
    }
    
    func loadNotificationSettings() -> NotificationSettings {
        guard let data = userDefaults.data(forKey: Keys.notificationSettings) else {
            return NotificationSettings.defaultSettings
        }
        
        do {
            return try decoder.decode(NotificationSettings.self, from: data)
        } catch {
            print("加载通知设置失败: \(error)")
            return NotificationSettings.defaultSettings
        }
    }
    
    // MARK: - App Usage Tracking
    func recordAppLaunch() {
        userDefaults.set(Date(), forKey: Keys.lastAppLaunch)
    }
    
    func getLastAppLaunch() -> Date? {
        return userDefaults.object(forKey: Keys.lastAppLaunch) as? Date
    }
    
    func getDaysSinceLastLaunch() -> Int {
        guard let lastLaunch = getLastAppLaunch() else {
            return 0
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: lastLaunch, to: Date())
        return components.day ?? 0
    }
    
    // MARK: - Data Export
    func exportAllData() -> Data? {
        let exportData = DataExport(
            smokingEvents: loadSmokingEvents(),
            cravingEvents: loadCravingEvents(),
            userSettings: loadUserSettings(),
            notificationSettings: loadNotificationSettings(),
            exportDate: Date()
        )
        
        do {
            return try encoder.encode(exportData)
        } catch {
            print("导出数据失败: \(error)")
            return nil
        }
    }
    
    // MARK: - Data Cleanup
    func cleanupOldData(olderThan days: Int = 365) {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        // 清理吸烟事件
        var smokingEvents = loadSmokingEvents()
        smokingEvents.removeAll { $0.timestamp < cutoffDate }
        saveSmokingEvents(smokingEvents)
        
        // 清理冲动事件
        var cravingEvents = loadCravingEvents()
        cravingEvents.removeAll { $0.timestamp < cutoffDate }
        saveCravingEvents(cravingEvents)
    }
    
    // MARK: - Privacy Methods
    func deleteAllUserData() {
        let keys = [
            Keys.smokingEvents,
            Keys.cravingEvents,
            Keys.userSettings,
            Keys.quitStartDate,
            Keys.cigarettesPerDay,
            Keys.cigarettePrice,
            Keys.notificationSettings,
            Keys.lastAppLaunch
        ]
        
        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    func anonymizeData() {
        // 移除所有个人身份信息
        var settings = loadUserSettings()
        settings.name = nil
        settings.age = nil
        saveUserSettings(settings)
        
        // 保留行为数据但移除时间戳中的具体日期
        let smokingEvents = loadSmokingEvents()
        let anonymizedSmokingEvents = smokingEvents.map { event in
            // 创建新的匿名事件，只保留小时和分钟
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: event.timestamp)
            let anonymizedDate = calendar.date(from: components) ?? Date()
            
            return SmokingEvent(
                timestamp: anonymizedDate,
                cigarettes: event.cigarettes,
                context: event.context,
                resisted: event.resisted
            )
        }
        saveSmokingEvents(anonymizedSmokingEvents)
        
        let cravingEvents = loadCravingEvents()
        let anonymizedCravingEvents = cravingEvents.map { event in
            // 创建新的匿名事件，只保留小时和分钟
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: event.timestamp)
            let anonymizedDate = calendar.date(from: components) ?? Date()
            
            return CravingEvent(
                timestamp: anonymizedDate,
                intensity: event.intensity,
                context: event.context,
                resisted: event.resisted,
                resistanceDuration: event.resistanceDuration
            )
        }
        saveCravingEvents(anonymizedCravingEvents)
    }
}

// MARK: - Data Models for Storage
struct UserSettings: Codable {
    var name: String?
    var age: Int?
    var smokingYears: Int?
    var dailyCigarettes: Int
    var cigarettePrice: Double
    var quitStartDate: Date
    var notificationEnabled: Bool
    
    static var defaultSettings: UserSettings {
        return UserSettings(
            name: nil,
            age: nil,
            smokingYears: nil,
            dailyCigarettes: 10,
            cigarettePrice: 5.0,
            quitStartDate: Date(),
            notificationEnabled: true
        )
    }
}

struct NotificationSettings: Codable {
    var highRiskEnabled: Bool
    var encouragementEnabled: Bool
    var dailyReminderEnabled: Bool
    var dailyReminderTime: Date
    
    static var defaultSettings: NotificationSettings {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute], from: Date())
        components.hour = 20 // 晚上8点
        components.minute = 0
        
        return NotificationSettings(
            highRiskEnabled: true,
            encouragementEnabled: true,
            dailyReminderEnabled: true,
            dailyReminderTime: calendar.date(from: components) ?? Date()
        )
    }
}

struct DataExport: Codable {
    let smokingEvents: [SmokingEvent]
    let cravingEvents: [CravingEvent]
    let userSettings: UserSettings
    let notificationSettings: NotificationSettings
    let exportDate: Date
}

// MARK: - Extensions for Codable Support
extension SmokingEvent: Codable {
    enum CodingKeys: String, CodingKey {
        case timestamp, cigarettes, context, resisted
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let timestamp = try container.decode(Date.self, forKey: .timestamp)
        let cigarettes = try container.decode(Int.self, forKey: .cigarettes)
        let context = try container.decode(String.self, forKey: .context)
        let resisted = try container.decode(Bool.self, forKey: .resisted)
        
        self.init(
            timestamp: timestamp,
            cigarettes: cigarettes,
            context: context,
            resisted: resisted
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(cigarettes, forKey: .cigarettes)
        try container.encode(context, forKey: .context)
        try container.encode(resisted, forKey: .resisted)
    }
}

extension CravingEvent: Codable {
    enum CodingKeys: String, CodingKey {
        case timestamp, intensity, context, resisted, resistanceDuration
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let timestamp = try container.decode(Date.self, forKey: .timestamp)
        let intensity = try container.decode(CravingIntensity.self, forKey: .intensity)
        let context = try container.decode(String.self, forKey: .context)
        let resisted = try container.decode(Bool.self, forKey: .resisted)
        let resistanceDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .resistanceDuration)
        
        self.init(
            timestamp: timestamp,
            intensity: intensity,
            context: context,
            resisted: resisted,
            resistanceDuration: resistanceDuration
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(intensity, forKey: .intensity)
        try container.encode(context, forKey: .context)
        try container.encode(resisted, forKey: .resisted)
        try container.encodeIfPresent(resistanceDuration, forKey: .resistanceDuration)
    }
}

extension CravingEvent.CravingIntensity: Codable {
    enum CodingKeys: String, CodingKey {
        case low, medium, high
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "low": self = .low
        case "medium": self = .medium
        case "high": self = .high
        default: self = .medium
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .low: try container.encode("low")
        case .medium: try container.encode("medium")
        case .high: try container.encode("high")
        }
    }
}