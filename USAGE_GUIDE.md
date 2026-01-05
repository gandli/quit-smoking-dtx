# 使用指南：如何集成戒烟数字疗法系统

## 快速集成步骤

### 步骤1：创建新的Xcode项目
1. 打开Xcode，创建新项目
2. 选择"iOS" → "App"模板
3. 配置：
   - Product Name: `YourQuitSmokingApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `None`

### 步骤2：复制核心文件
将以下目录复制到你的项目中：
```
QuitSmokingDTxApp/
├── App/                    # 应用核心
├── Views/                  # 所有UI界面
├── Services/               # 数据和服务层
├── Models/                 # 数据模型
├── Utilities/              # 工具类
└── Resources/              # 资源文件
```

### 步骤3：配置项目设置
1. **添加权限**（Info.plist）：
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>发送戒烟提醒和鼓励通知</string>
```

2. **配置签名**：
   - 选择你的开发团队
   - 启用Push Notifications能力

### 步骤4：运行应用
1. 选择模拟器（建议iPhone 16）
2. 点击运行按钮（▶️）
3. 应用将启动并显示主界面

## 核心组件说明

### 1. AppState（全局状态管理）
```swift
// 在你的App中初始化
@State private var appState = AppState()

var body: some Scene {
    WindowGroup {
        ContentView()
            .environment(appState)
            .task {
                await appState.initialize()
            }
    }
}
```

### 2. 数据存储服务
系统自动处理数据持久化：
- 吸烟事件记录
- 冲动事件记录
- 用户设置保存
- 隐私保护

### 3. 通知服务
自动管理：
- 高风险窗口通知
- 鼓励通知
- 每日提醒

## 自定义配置

### 修改默认设置
在`AppState.swift`中：
```swift
// 修改默认值
var cigarettesPerDay: Int = 15  // 默认每日吸烟量
var cigarettePrice: Double = 8.0 // 默认香烟价格
```

### 自定义UI主题
在`QuitSmokingDTxApp.swift`中：
```swift
private func configureAppearance() {
    // 自定义导航栏
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .systemBlue
    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().tintColor = .white
}
```

### 添加新功能
1. **创建新屏幕**：
```swift
// 在Views/Screens/中添加新文件
struct NewFeatureScreen: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        // 你的UI代码
    }
}
```

2. **添加到TabView**：
```swift
// 在ContentView.swift中
TabView(selection: $appState.selectedTab) {
    // 现有标签...
    
    NewFeatureScreen()
        .tabItem {
            Label("新功能", systemImage: "star")
        }
        .tag(AppState.Tab.newFeature)
}
```

## 测试建议

### 1. 功能测试
- 点击"我现在很想抽"测试干预流程
- 记录吸烟事件验证数据保存
- 查看趋势页面验证图表显示
- 测试通知权限和发送

### 2. 数据持久化测试
- 重启应用验证数据恢复
- 测试数据导出功能
- 验证隐私设置（删除/匿名化）

### 3. 性能测试
- 监控内存使用
- 测试大量数据时的性能
- 验证通知定时准确性

## 常见问题解决

### Q1: 构建错误"Invalid custom path"
**解决方案**：
1. 使用Xcode创建新项目
2. 手动复制文件，不要使用Package.swift
3. 确保所有文件都在正确的目录中

### Q2: 通知不工作
**检查步骤**：
1. 确认Info.plist中有通知权限描述
2. 检查项目设置中的Push Notifications能力
3. 在模拟器中授权通知权限
4. 验证`NotificationService`的初始化

### Q3: 数据不保存
**检查步骤**：
1. 确认`DataStorageService`正确初始化
2. 检查`saveData()`方法是否被调用
3. 验证UserDefaults访问权限

### Q4: UI显示问题
**检查步骤**：
1. 确认所有SwiftUI视图都有`#Preview`
2. 检查环境对象的传递
3. 验证数据绑定正确性

## 生产环境准备

### 1. 代码优化
- 添加错误处理
- 实现加载状态
- 添加空状态UI
- 优化图片和资源

### 2. 测试覆盖
- 添加单元测试
- 实现UI测试
- 进行性能测试
- 用户接受测试

### 3. 发布准备
- 配置App Store Connect
- 准备应用截图
- 编写应用描述
- 设置隐私政策

### 4. 监控和分析
- 集成应用分析
- 设置错误报告
- 监控用户行为
- 收集用户反馈

## 扩展开发路线图

### 阶段1：基础功能（已完成）
- [x] 核心干预流程
- [x] 数据持久化
- [x] 基本通知系统

### 阶段2：增强功能
- [ ] 真实AI服务集成
- [ ] 社交分享功能
- [ ] 成就系统增强
- [ ] 多语言支持

### 阶段3：高级功能
- [ ] 健康数据集成（HealthKit）
- [ ] 专业医疗连接
- [ ] 个性化干预算法
- [ ] 社区支持功能

## 技术支持

如需技术支持：
1. 查看代码注释和文档
2. 检查常见问题部分
3. 联系开发团队
4. 提交Issue报告问题

## 更新日志

### v1.0.0 (初始版本)
- 完成核心戒烟干预功能
- 实现数据持久化和隐私保护
- 集成智能通知系统
- 提供完整的经济分析模块
- 遵循DTx合规设计原则

---

**重要提示**：本系统为戒烟辅助工具，不能替代专业医疗建议。用户在使用过程中如有任何健康问题，应及时咨询医疗专业人员。