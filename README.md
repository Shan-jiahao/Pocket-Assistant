# Pocket Assistant · Pocket助手

用头部方向控制 Pocket 云台，用 iPhone 完成连接与拍摄操作。

Pocket助手是一款以头追控制为核心的中文 iPhone 应用。佩戴可提供运动数据的耳机，
连接 Pocket 相机，校准朝向后即可通过转头和点头控制云台。应用不提供视频监看页面。

当前阶段：开发验证版。支持范围以实际连接与运动数据为准，尚不承诺所有设备组合可用。

## 三个入口

| 页面 | 可以做什么 |
| --- | --- |
| 设备 | 蓝牙发现、配对、相机 Wi-Fi 连接引导、保存与重连、连接诊断 |
| 拍摄 | 开始/停止录制、手动摇杆、云台回中、旋转 180°、角度与相机状态 |
| 头追 | 启动条件、校准与停止、实时角度、快速/标准/轻柔预设、详细参数 |

界面使用简体中文，并跟随 iPhone 系统切换浅色与深色外观。

## 开始使用

1. 打开 Pocket，在“设备”页配对；按提示加入相机 Wi-Fi。
2. 戴上支持运动数据的耳机，启用头追，等待四项启动条件就绪。
3. 保持头部静止，点击“校准并锁定前方”，再缓慢转头或点头。
4. 点击停止即可结束头追；“拍摄”页可使用手动云台与录制控制。

完整操作、参数解释、故障处理与验证范围见 [产品介绍说明书](docs/product-guide.zh-CN.md)。

## 从源码构建

需要 macOS、Xcode、XcodeGen，以及用于真机安装的 Apple 开发签名。
工程最低部署版本为 iOS 17；兼容性仍需在对应手机与耳机上验证。

```sh
cd ios
xcodegen generate
open ./*.xcodeproj
```

在 Xcode 中选择 `PocketAssistant` scheme，配置自己的 Team 和 Bundle Identifier，
选择 iPhone 后运行。签名配置应使用开发者自己的 Team 和 Bundle Identifier。
免费 Personal Team 的相机 Wi-Fi 连接可能需要手动操作，详见说明书。

```sh
just check
```

## 项目边界与许可

当前对外产品为中文 iPhone 应用 Pocket助手。仓库中的其他开发目录不代表对应功能
已经作为 Pocket助手产品交付；实际功能与兼容范围以本说明和实机验证为准。

遵循 [Apache License 2.0](LICENSE)，保留 [NOTICE](NOTICE) 和
[第三方许可](THIRD-PARTY-NOTICES.md)。本项目不是 DJI 或 Apple 官方产品。
