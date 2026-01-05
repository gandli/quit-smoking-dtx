import XCTest
@testable import QuitSmokingDTx

final class QuitSmokingDTxTests: XCTestCase {
    
    func testAppStateInitialization() {
        let appState = AppState()
        
        XCTAssertEqual(appState.cigarettesPerDay, 10)
        XCTAssertEqual(appState.cigarettePrice, 5.0, accuracy: 0.01)
        XCTAssertEqual(appState.smokingStatus, .stable)
    }
    
    func testTodayStatsCalculation() {
        let appState = AppState()
        
        // 添加一些测试数据
        let smokingEvent = SmokingEvent(
            timestamp: Date(),
            cigarettes: 2,
            context: "测试",
            resisted: false
        )
        appState.smokingEvents = [smokingEvent]
        
        let stats = appState.todayStats
        XCTAssertEqual(stats.cigarettes, 2)
        XCTAssertEqual(stats.moneySaved, 10.0, accuracy: 0.01)
    }
    
    func testMoneySavedCalculation() {
        let appState = AppState()
        appState.cigarettesPerDay = 20
        appState.cigarettePrice = 10.0
        
        // 模拟戒烟3天，每天少抽20支
        appState.quitStartDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        
        // 实际抽了10支
        let smokingEvents = [
            SmokingEvent(timestamp: Date(), cigarettes: 5, context: "测试", resisted: false),
            SmokingEvent(timestamp: Date(), cigarettes: 5, context: "测试", resisted: false)
        ]
        appState.smokingEvents = smokingEvents
        
        // 预期：3天 * 20支/天 * 10元/支 = 600元
        // 实际：抽了10支 * 10元/支 = 100元
        // 节省：600 - 100 = 500元
        let moneySaved = appState.moneySaved
        XCTAssertEqual(moneySaved, 500.0, accuracy: 10.0)
    }
    
    func testCravingEventRecording() {
        let appState = AppState()
        
        let initialCount = appState.cravingsCountToday
        
        appState.handleCraving()
        
        XCTAssertEqual(appState.cravingsCountToday, initialCount + 1)
        XCTAssertEqual(appState.smokingStatus, .highRisk)
    }
    
    func testSmokingEventRecording() {
        let appState = AppState()
        
        appState.recordSmoking()
        
        XCTAssertEqual(appState.smokingEvents.count, 1)
        XCTAssertEqual(appState.smokingStatus, .smoked)
        XCTAssertNotNil(appState.lastSmokeTime)
    }
    
    func testResistedCravingRecording() {
        let appState = AppState()
        
        let initialResistedCount = appState.resistedCravingsCountToday
        
        appState.recordResistedCraving(duration: 300) // 5分钟
        
        XCTAssertEqual(appState.resistedCravingsCountToday, initialResistedCount + 1)
        XCTAssertEqual(appState.smokingStatus, .resisted)
        XCTAssertEqual(appState.cravingEvents.last?.resistanceDuration, 300)
    }
}