# 周目 · watchOS

> **⚠️ 这个仓库是「副本」，不是主仓库。**
>
> 周目现在是一个**家族**：iPhone 应用和手表应用一起打包、一起安装。
> 所有代码的**主仓库在这里**：
>
> ### 👉 [mbhdnysxyv-ux/zhoumu](https://github.com/mbhdnysxyv-ux/zhoumu)
>
> 本仓库保留手表部分的**一份代码副本**，方便单独浏览和检索，
> **不发布 Release**（安装包在主仓库的 Release 里，一个 IPA 同时包含 iPhone 和手表应用）。
> 开发、提 issue、下载安装都请去主仓库。

---

## 手表部分包含什么

| 目录 | 内容 |
| --- | --- |
| `ZhouMuWatch/` | 手表 App：第 N 周 + 今天课表 + 设置 |
| `ZhouMuWatchWidget/` | 表盘复杂功能：circular / rectangular / inline / corner |
| `Shared/` | 与 iPhone 版共用的纯逻辑（周目计算、课表模型） |

## 怎么装

手表应用**不用单独装**——它被嵌在 iPhone 应用里：

```
ZhouMu.app                                  ← 装这个
├── PlugIns/ZhouMuWidget.appex              iOS 小组件 + 灵动岛
└── Watch/ZhouMuWatch.app                   手表应用（随 iPhone 应用一起装）
    └── PlugIns/ZhouMuWatchWidget.appex     表盘复杂功能
```

到 **[主仓库的 Release](https://github.com/mbhdnysxyv-ux/zhoumu/releases/latest)** 下载那个 IPA 就行。

## 主仓库里对应的位置

```
zhoumu/
├── ZhouMu/                  iPhone 应用
├── ZhouMuWidget/            iOS 小组件 + 灵动岛
├── ZhouMuWatch/             手表应用      ← 本仓库的副本来源
├── ZhouMuWatchWidget/       表盘复杂功能  ← 本仓库的副本来源
└── Shared/                  两边共用
```

## 校验

```bash
./Tools/verify.sh    # 16 项逻辑断言 + watchOS 编译检查
```

> 本仓库的校验脚本是为「独立开发」时期准备的，主仓库的
> [`Tools/verify.sh`](https://github.com/mbhdnysxyv-ux/zhoumu/blob/main/Tools/verify.sh)
> 才是现在用的那份。

## 许可证

[MIT](LICENSE)
