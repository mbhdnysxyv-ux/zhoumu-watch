#!/bin/bash
# 手表版校验：周目计算逻辑断言 + watchOS 编译检查。
# 不需要真机，也不需要手表模拟器在跑。
set -euo pipefail
cd "$(dirname "$0")/.."

export SWIFT_MODULECACHE_PATH="$PWD/build/ModuleCache"
mkdir -p "$SWIFT_MODULECACHE_PATH"
CACHE="$SWIFT_MODULECACHE_PATH"

echo "==> 1/3 周目计算逻辑断言"
mkdir -p build
mkdir -p build/checkSrc
cat > build/checkSrc/main.swift <<'SWIFT'
import Foundation

var checks = 0, failures = 0
func expect(_ c: Bool, _ m: String) {
    checks += 1
    if c { print("  ✓ \(m)") } else { failures += 1; print("  ✗ \(m)") }
}
func expectEqual<T: Equatable>(_ a: T, _ b: T, _ m: String) {
    expect(a == b, "\(m)（期望 \(b)，实际 \(a)）")
}
func day(_ y: Int, _ mo: Int, _ d: Int) -> Date {
    SemesterCalculator.calendar.date(from: DateComponents(year: y, month: mo, day: d))!
}
func at(_ y: Int, _ mo: Int, _ d: Int, _ h: Int, _ mi: Int) -> Date {
    SemesterCalculator.calendar.date(from: DateComponents(year: y, month: mo, day: d, hour: h, minute: mi))!
}

// 1. 周目取模
let start = day(2026, 2, 23)
for (offset, expectWeek) in [(0, 1), (21, 1), (28, 2), (35, 3), (42, 1)] {
    let d = SemesterCalculator.calendar.date(byAdding: .day, value: offset, to: start)!
    if case .inSession(let i) = SemesterCalculator.phase(startDate: start, cycleWeeks: 3,
                                                         cyclingEnabled: true, referenceDate: d) {
        expectEqual(i.displayWeek, expectWeek, "距开学 \(offset) 天 → 显示第 \(expectWeek) 周")
    } else { expect(false, "距开学 \(offset) 天 应该 inSession") }
}

// 2. 未开学
if case .notStarted(let days) = SemesterCalculator.phase(startDate: day(2026, 9, 1),
                                                         cycleWeeks: 3, cyclingEnabled: true,
                                                         referenceDate: day(2026, 8, 25)) {
    expectEqual(days, 7, "未开学天数")
} else { expect(false, "应该 notStarted") }

// 3. 关闭循环
if case .inSession(let i) = SemesterCalculator.phase(startDate: start, cycleWeeks: 3,
                                                     cyclingEnabled: false,
                                                     referenceDate: day(2026, 3, 16)) {
    expectEqual(i.displayWeek, 4, "关闭循环后直接显示第 4 周")
}

// 4. 时间轴与状态机
var table = ScheduleTable(enabled: true, rotatesByWeek: false,
                          periodsPerDay: [2,0,0,0,0,0,0],
                          periodTimes: [PeriodTime(start: 8*60, end: 8*60+45),
                                        PeriodTime(start: 9*60, end: 9*60+45)],
                          subjects: [:])
table.setSubject("数学", row: 0, day: 0, period: 0)
table.setSubject("语文", row: 0, day: 0, period: 1)
let monday = day(2026, 9, 14)
let classes = ClassSchedule.classes(for: monday, tables: [.regular: table], displayWeek: 1)
expectEqual(classes.count, 2, "合并出 2 节课")
expectEqual(classes.first?.subject, "数学", "第一节是数学")

let st = ClassSchedule.state(at: at(2026, 9, 14, 8, 20), classes: classes)
if case .inClass(let cur, let nxt) = st {
    expectEqual(cur.subject, "数学", "8:20 正在上数学")
    expectEqual(nxt?.subject, "语文", "下一节语文")
} else { expect(false, "8:20 应该 inClass") }
expectEqual(st.ringProgress(at: at(2026, 9, 14, 8, 20)), 20.0/45.0, "环进度 20/45")

let rest = ClassSchedule.state(at: at(2026, 9, 14, 8, 50), classes: classes)
expectEqual(rest.ringProgress(at: at(2026, 9, 14, 8, 50)), 1.0, "课间环闭合")

// 5. 没填时间时，「当天第一节」回退（手表单表场景靠它）
var noTime = table
noTime.periodTimes = [nil, nil]
let fallback = ClassSchedule.firstSubject(day: 0, table: noTime, displayWeek: 1)
expectEqual(fallback, "数学", "没填时间时回退到当天第一节")

// 轮换表按周目取排
var rotating = noTime
rotating.rotatesByWeek = true
rotating.setSubject("历史", row: 2, day: 0, period: 0)
expectEqual(ClassSchedule.firstSubject(day: 0, table: rotating, displayWeek: 3), "历史",
            "轮换表第 3 周目取第 3 排")

// 关闭的表不参与
var disabled = noTime
disabled.enabled = false
expectEqual(ClassSchedule.firstSubject(day: 0, table: disabled, displayWeek: 1) == nil, true,
            "关闭的表返回 nil")

print("\n----------------------------------------")
if failures == 0 { print("全部通过：\(checks) 项检查 ✅"); exit(0) }
else { print("失败 \(failures) / \(checks) 项 ❌"); exit(1) }
SWIFT
swiftc -module-cache-path "$CACHE" -O build/checkSrc/main.swift \
  Shared/SemesterCalculator.swift Shared/ScheduleModel.swift -o build/check
./build/check

echo
echo "==> 2/3 watchOS App 编译检查"
xcodebuild -project ZhouMuWatch.xcodeproj -scheme ZhouMuWatch -sdk watchsimulator \
  -destination 'generic/platform=watchOS Simulator' -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO build 2>&1 | grep -E "error:|BUILD" | tail -3

echo
echo "==> 3/3 完成"
