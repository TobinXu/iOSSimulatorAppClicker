# iOS Simulator App Clicker

自动在 iOS 模拟器上打开指定 App 并点击底部导航栏的某个 tab。

## Requirements

- Xcode 已安装（提供 `simctl`）
- macOS
- 目标 App 已经安装到 iOS 模拟器

## Usage

```bash
# 直接运行（自动找第一个已启动的 iPhone 模拟器）
bash temu_click.sh

# 或者指定设备 UDID
bash temu_click.sh <device-udid>
```

## How it works

1. 自动找到或启动 iOS 模拟器
2. 通过 `simctl` 启动目标 App
3. 自动把 Simulator 窗口带到前台
4. 计算出底部导航栏目标 tab 坐标
5. 使用 Swift + CoreGraphics 发送鼠标点击事件

## Notes

- 请在脚本中修改目标 App 的 bundle ID
- 点击位置根据底部 tab 数量自动计算，如果 tab 数量不同需要调整百分比系数
