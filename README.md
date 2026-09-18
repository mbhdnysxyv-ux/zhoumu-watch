# 周目 · watchOS 版

**抬腕就知道今天是开学第几周、今天上什么课。**

这是 [周目](https://github.com/mbhdnysxyv-ux/zhoumu) 的**独立手表版**——自己一个仓库、自己管数据，
不依赖 iPhone 应用。iPhone 版仍然在原来的仓库里。

---

## 功能

### 主界面

- **第 N 周**大字显示，下面是本周进度条
- 标出「开学第 N 周 · M 周循环」，一眼看清循环位置
- **今天的课**逐节列出，有填时间就显示上课时刻

### 表盘复杂功能

四种样式，都能直接看到第几周：

| 样式 | 显示 |
| --- | --- |
| 圆形（Circul​​ar） | 本周进度圆环 + 中间的周目数字 |
| 矩形（Rectangular） | `第 3 周` + `今天：数学` |
| 行内（Inline） | `第 3 周 · 数学` |
| 角标（Corner） | 角落大号数字 + 「周」标签 |

### 设置

- 开学日期、周目循环（N 周）
- **今天各节的科目**：点一节改一格，只有「无」和「自定义」

> 手表屏幕小，所以课表只编辑**今天这一天**。完整的 7 × N 课表在 iPhone 版上编辑更合适。

---

## 和 iPhone 版的关系

**完全独立。** 两边各自维护一份设置：

- 手表版自己设开学日期和课表，装在手表上就能用
- iPhone 版的数据不会同步过来（这个是取舍：独立 = 不用配对，代价是设置要各设一次）
- 共享的纯逻辑（`SemesterCalculator.swift`、`ScheduleModel.swift`）两边各有一份副本

---

## 项目结构

```
ZhouMuWatch.xcodeproj/       工程（2 个 target）
ZhouMuWatch/                 手表 App
  ZhouMuWatchApp.swift         入口
  Models/WatchSettings.swift   设置读写（App Group 存储）
  Views/WeekView.swift         主界面：第几周 + 今天的课
  Views/WatchSettingsView.swift 设置页
ZhouMuWatchWidget/           表盘复杂功能
  ZhouMuWatchWidget.swift      四种 accessory 样式的实现
Shared/                      与复杂功能共用
  SemesterCalculator.swift     周目计算（纯逻辑）
  ScheduleModel.swift          课表模型 + 时间轴 + 状态机
  WatchStorage.swift           App Group 共享存储
Tools/verify.sh              一键校验
```

---

## 开发与校验

```bash
./Tools/verify.sh
```

两件事都不需要真机或手表模拟器：

1. **16 项逻辑断言** —— 周目取模、未开学、关闭循环、时间轴合并、状态机、
   环进度、没填时间时的回退、轮换表按周目取排、关闭的表不参与
2. **watchOS 编译检查** —— 完整构建 App + 复杂功能两个 target

### 在手表模拟器里看效果

```bash
open ZhouMuWatch.xcodeproj
```

选 Apple Watch 模拟器（本机有 Series 11 / Ultra 3 / SE 3），⌘R 运行。

---

## 安装到手表

**待补充。** 手表应用的安装路径和 iPhone 版不同（不能用自签 IPA 那一套），
需要 Xcode + 配对的 iPhone，这部分还没写。

---

## 许可证

[MIT](LICENSE)
