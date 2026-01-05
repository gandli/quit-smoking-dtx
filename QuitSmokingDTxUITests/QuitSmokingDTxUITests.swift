import XCTest

final class QuitSmokingDTxUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testHomeScreenElements() {
        // 检查标签页
        XCTAssertTrue(app.tabBars.buttons["干预"].exists)
        XCTAssertTrue(app.tabBars.buttons["趋势"].exists)
        XCTAssertTrue(app.tabBars.buttons["洞察"].exists)
        XCTAssertTrue(app.tabBars.buttons["经济"].exists)
        
        // 检查首页元素
        XCTAssertTrue(app.staticTexts["戒烟支持"].exists)
        XCTAssertTrue(app.buttons["我现在很想抽"].exists)
        XCTAssertTrue(app.buttons["我刚刚抽了一支"].exists)
    }
    
    func testTabNavigation() {
        // 切换到趋势页
        app.tabBars.buttons["趋势"].tap()
        XCTAssertTrue(app.staticTexts["行为趋势"].waitForExistence(timeout: 2))
        
        // 切换到洞察页
        app.tabBars.buttons["洞察"].tap()
        XCTAssertTrue(app.staticTexts["行为洞察"].waitForExistence(timeout: 2))
        
        // 切换到经济页
        app.tabBars.buttons["经济"].tap()
        XCTAssertTrue(app.staticTexts["经济分析"].waitForExistence(timeout: 2))
        
        // 切换回首页
        app.tabBars.buttons["干预"].tap()
        XCTAssertTrue(app.staticTexts["戒烟支持"].waitForExistence(timeout: 2))
    }
    
    func testCravingInterventionFlow() {
        // 点击冲动按钮
        app.buttons["CravingButton"].tap()
        
        // 检查干预页面出现
        XCTAssertTrue(app.staticTexts["冲动干预"].waitForExistence(timeout: 5))
        
        // 检查倒计时元素 (查找包含冒号的文本，如 04:59)
        let timerLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS ':'")).firstMatch
        XCTAssertTrue(timerLabel.waitForExistence(timeout: 2))
        
        // 检查替代行为按钮
        XCTAssertTrue(app.buttons["喝水"].exists)
        XCTAssertTrue(app.buttons["深呼吸"].exists)
        
        // 点击一个替代行为
        app.buttons["喝水"].tap()
        
        // 返回首页
        app.buttons["取消"].tap()
        XCTAssertTrue(app.staticTexts["戒烟支持"].waitForExistence(timeout: 5))
    }
    
    func testSmokingRecording() {
        // 点击记录吸烟按钮
        app.buttons["SmokedButton"].tap()
        
        // 检查确认对话框按钮
        let confirmButton = app.buttons["记录吸烟"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        
        // 点击记录吸烟按钮
        confirmButton.tap()
    }
    
    func testTrendsScreenContent() {
        // 导航到趋势页
        app.tabBars.buttons["趋势"].tap()
        
        // 检查核心指标
        XCTAssertTrue(app.staticTexts["核心指标"].exists)
        XCTAssertTrue(app.staticTexts["本周少抽"].exists)
        XCTAssertTrue(app.staticTexts["成功忍住"].exists)
        
        // 检查图表区域（现在只有热力图）
        XCTAssertTrue(app.staticTexts["吸烟 vs 忍住趋势"].exists)
        
        // 检查详细统计
        XCTAssertTrue(app.staticTexts["详细统计"].exists)
        XCTAssertTrue(app.staticTexts["戒烟天数"].exists)
        XCTAssertTrue(app.staticTexts["总节省金额"].exists)
    }
    
    func testInsightsScreenContent() {
        // 导航到洞察页
        app.tabBars.buttons["洞察"].tap()
        
        // 检查标题和说明
        // XCTAssertTrue(app.staticTexts["个人行为洞察"].exists)
        XCTAssertTrue(app.staticTexts["基于你的数据生成的个性化洞察"].exists)
        
        // 检查AI生成洞察区域
        XCTAssertTrue(app.staticTexts["AI生成洞察"].exists)
        
        // 检查自我反思区域
        XCTAssertTrue(app.staticTexts["自我反思"].exists)
        XCTAssertTrue(app.buttons["开始反思"].exists)
    }
    
    func testEconomyScreenContent() {
        // 导航到经济页
        app.tabBars.buttons["经济"].tap()
        
        // 检查总节省金额
        XCTAssertTrue(app.staticTexts["总节省金额"].exists)
        
        // 检查消费趋势
        XCTAssertTrue(app.staticTexts["消费趋势"].exists)
        
        // 检查机会成本分析
        XCTAssertTrue(app.staticTexts["机会成本分析"].exists)
        XCTAssertTrue(app.staticTexts["月度节省"].exists)
        XCTAssertTrue(app.staticTexts["年度节省"].exists)
        XCTAssertTrue(app.staticTexts["五年节省"].exists)
        
        // 检查替代目标
        XCTAssertTrue(app.staticTexts["替代目标"].exists)
        XCTAssertTrue(app.staticTexts["旅行基金"].exists)
        XCTAssertTrue(app.staticTexts["新手机"].exists)
        XCTAssertTrue(app.staticTexts["健身会员"].exists)
    }
    
    func testSettingsAccess() {
        // 导航到经济页
        app.tabBars.buttons["经济"].tap()
        
        // 点击设置按钮
        app.buttons["gearshape"].tap()
        
        // 检查设置页面
        XCTAssertTrue(app.staticTexts["经济设置"].waitForExistence(timeout: 2))
        
        // 返回
        app.buttons["取消"].tap()
    }
    
    func testAppLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}