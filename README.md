# iOS Simulator Temu "我的" Clicker

自动在 iOS 模拟器上打开 Temu app 并点击底部导航栏的 "我的" tab。

##  Requirements

- Xcode 已安装（提供 `simctl`）
- macOS
- Temu app 已经安装到 iOS 模拟器

## Usage

```bash
# 直接运行（自动找第一个已启动的 iPhone 模拟器）
bash temu_click.sh

# 或者指定设备 UDID
bash temu_click.sh <device-udid>
```

## How it works

1. 自动找到或启动 iOS 模拟器
2. 通过 `simctl` 启动 Temu app（bundle ID: `com.einnovation.temu.beta`）
3. 自动把 Simulator 窗口带到前台
4. 计算出底部 "我的" tab 坐标
5. 使用 Swift + CoreGraphics 发送鼠标点击事件

## Notes

- 如果你的 Temu bundle ID 不是 `com.einnovation.temu.beta`，修改 `temu_click.sh` 里的 `TEMU_BUNDLE`
- 点击位置根据 4-tab 布局（首页/类别/我的/购物车）计算，如果 tab 数量不同需要调整百分比系数
