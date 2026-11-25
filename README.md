# DSH Client iOS 📱

DSH Go 风格的 iOS 客户端，使用 SwiftUI 构建。

## ✨ 功能

- 🔗 连接 DSH 实例（支持局域网和公网）
- 💬 聊天对话界面
- ⚡ 流式响应（SSE）
- 📋 多会话管理
- 💾 连接历史保存
- 🎨 简洁美观的 UI

## 📲 安装

### 方法一：TrollStore（巨魔）
1. 前往 [Releases](https://github.com/xuan666xuan2/dsh-ios-client/releases) 下载最新 IPA
2. 通过 TrollStore 安装 IPA
3. 打开 App 即可使用

### 方法二：自行编译
1. 安装 [XcodeGen](https://github.com/yonaskolb/XcodeGen)
2. 运行 `xcodegen generate`
3. 用 Xcode 打开 `DSHClient.xcodeproj`
4. 编译运行

## 🔧 使用方法

1. 打开 App
2. 输入 DSH 服务器地址（如 `http://192.168.1.100:57764`）
3. 如有 Token 则填入（可选）
4. 点击「连接」
5. 开始聊天！

### 获取服务器地址
- 在 DSH 桌面端打开「更多 → 手机连接」
- 查看访问地址
- 或扫描配对二维码（开发中）

## 🏗️ 技术栈

- SwiftUI
- iOS 16.0+
- URLSession (SSE 流式)
- XcodeGen 项目生成

## 📝 License

MIT
