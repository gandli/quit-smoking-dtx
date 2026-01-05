# 戒烟数字疗法系统 (QuitSmokingDTx)

一个基于行为科学的戒烟数字疗法iOS应用，严格遵循DTx（数字疗法）合规要求。

## 🎯 产品概述

**一句话定义**：
> 以可解释行为模型为核心、以AI辅助表达为手段，在吸烟冲动关键窗口提供克制与支持的数字疗法级戒烟系统。

## 📱 核心功能

### 1. 首页（核心干预入口）
- 实时状态卡片显示风险等级
- 主操作按钮："我现在很想抽"触发即时干预
- 次级操作："我刚刚抽了一支"记录吸烟
- 今日统计卡片和快速提示

### 2. 即时干预页（黄金5分钟）
- 倒计时进度环（3-10分钟可配置）
- AI生成的鼓励文案
- 替代行为选择（喝水/深呼吸/走动/转移注意力）
- 成功/失败记录机制

### 3. 行为趋势页
- 吸烟vs忍住趋势图表
- 核心指标卡片（本周少抽X支、成功忍住X次）
- 详细统计和成就徽章系统

### 4. 个人行为洞察页（AI解释层）
- AI生成的行为模式识别
- 可解释的洞察卡片（时间模式、策略效果等）
- 自我反思辅助工具
- **合规设计**：AI仅用于解释，不参与决策

### 5. 经济消费分析模块
- 总节省金额显示和等价换算
- 消费趋势图表
- 机会成本分析（月度/年度/五年节省）
- 替代目标进度追踪
- 中性提示，非评判性语言

## 🏗️ 技术架构

### 项目结构
```
QuitSmokingDTx/
├── QuitSmokingDTxApp/
│   ├── App/
│   │   ├── QuitSmokingDTxApp.swift    # 应用入口
│   │   └── AppState.swift             # 全局状态管理
│   ├── Views/
│   │   ├── ContentView.swift          # 主TabView
│   │   └── Screens/                   # 四大核心页面
│   ├── Services/
│   │   ├── DataStorageService.swift   # 数据持久化
│   │   └── NotificationService.swift  # 通知服务
│   ├── Resources/
│   │   ├── Info.plist
│   │   ├── PrivacyInfo.xcprivacy      # 隐私清单
│   │   └── QuitSmokingDTx.entitlements
│   ├── Models/                        # 数据模型
│   └── Utilities/                     # 工具类
├── Package.swift                      # Swift Package配置
└── project.yml                        # XcodeGen配置（可选）
```

### 核心技术栈
- **SwiftUI**：现代声明式UI框架
- **@Observable**：Swift 6.0状态管理
- **Charts**：数据可视化
- **UserNotifications**：本地通知系统
- **UserDefaults**：本地数据存储

## 🛡️ 合规与安全

### AI使用合规性
- ✅ **允许**：文案表达、洞察解释、反思辅助
- ❌ **禁止**：行为判断、干预决策、个性化说服
- 🔒 **隔离设计**：LLM服务与决策引擎物理隔离

### 隐私保护
- 🔐 本地优先的数据存储
- 🗑️ 用户可随时删除或匿名化数据
- 📋 完整隐私清单配置
- 🚫 无第三方数据共享

## 🚀 快速开始

### 方式1：使用Xcode
1. 打开Xcode
2. 选择"File" → "New" → "Project"
3. 选择"iOS" → "App"
4. 配置项目信息：
   - Product Name: `QuitSmokingDTx`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `None` (使用内置的DataStorageService)
5. 将`QuitSmokingDTxApp`目录中的所有文件复制到新项目中
6. 添加必要的权限：
   - 在`Info.plist`中添加通知权限描述
   - 在Signing & Capabilities中添加Push Notifications

### 方式2：使用XcodeGen（推荐）
1. 安装XcodeGen：
   ```bash
   brew install xcodegen
   ```
2. 运行生成命令：
   ```bash
   cd QuitSmokingDTx
   xcodegen generate
   ```
3. 打开生成的`QuitSmokingDTx.xcodeproj`

### 方式3：使用Swift Package
1. 将`QuitSmokingDTx`作为依赖添加到你的项目中：
   ```swift
   // Package.swift
   dependencies: [
       .package(url: "https://your-repo/QuitSmokingDTx.git", from: "1.0.0")
   ]
   ```
2. 在目标中添加依赖：
   ```swift
   targets: [
       .target(
           name: "YourApp",
           dependencies: ["QuitSmokingDTx"]
       )
   ]
   ```

## 📋 配置要求

### 系统要求
- **iOS**: 18.0+
- **Xcode**: 16.0+
- **Swift**: 6.0+

### 权限配置
在`Info.plist`中添加：
```xml
<key>NSUserNotificationUsageDescription</key>
<string>发送戒烟提醒和鼓励通知</string>
```

## 🔧 自定义配置

### 修改用户默认设置
在`AppState.swift`中修改：
```swift
// 默认吸烟习惯
var cigarettesPerDay: Int = 10
var cigarettePrice: Double = 5.0

// 通知设置
var notificationsEnabled = true
var highRiskNotificationsEnabled = true
```

### 自定义AI洞察
在`InsightsScreen.swift`中修改`generateSampleInsights()`方法，或集成真实的AI服务。

### 经济分析设置
在`EconomyScreen.swift`中修改：
- 等价换算价格
- 替代目标金额
- 时间范围选项

## 🧪 测试

### 单元测试
项目包含可测试的组件：
- `DataStorageService`：数据持久化测试
- `NotificationService`：通知逻辑测试
- `AppState`：状态管理测试

### UI测试
使用SwiftUI Preview功能测试各个屏幕：
```swift
#Preview {
    HomeScreen()
        .environment(AppState())
}
```

## 📈 扩展开发

### 添加新功能
1. **社交支持**：添加朋友支持和鼓励功能
2. **医疗连接**：在合规前提下连接医疗专业人员
3. **多语言支持**：添加本地化字符串
4. **暗色模式**：完善主题系统

### 集成AI服务
1. 创建`AIService.swift`服务层
2. 实现合规的API调用
3. 添加AI输出日志和审计系统
4. 确保用户可关闭AI功能

## 🤝 贡献指南

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建Pull Request

## 📄 许可证

本项目采用MIT许可证。详见[LICENSE](LICENSE)文件。

## 🆘 支持

如有问题或建议，请：
1. 查看[Issues](https://github.com/your-repo/QuitSmokingDTx/issues)
2. 提交新的Issue
3. 或通过email联系维护者

## 🙏 致谢

- 基于行为科学和心理学原理
- 遵循数字疗法(DTx)最佳实践
- 感谢所有贡献者和测试用户

---

**健康提示**：本应用旨在辅助戒烟过程，不能替代专业医疗建议。如有健康问题，请咨询医生。