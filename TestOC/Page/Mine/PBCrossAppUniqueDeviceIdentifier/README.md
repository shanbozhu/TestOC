# 跨 App 统一设备标识接入示例

本目录是 `PBCrossAppUniqueDeviceIdentifier` 在 TestOC 中的接入示例。页面入口：

> TestOC → 我的 → `PBCrossAppUniqueDeviceIdentifierController`（进入后页面标题为“跨 App 设备标识”）

## 集成方式

SDK 位于仓库根目录 `PBCrossAppUniqueDeviceIdentifier/`，已通过 CocoaPods 本地路径接入 TestOC：

```ruby
pod 'PBCrossAppUniqueDeviceIdentifier', :path => './PBCrossAppUniqueDeviceIdentifier'
```

示例页只依赖公开头文件：

```objc
#import <PBCrossAppUniqueDeviceIdentifier/PBCrossAppUniqueDeviceIdentifier.h>
```

如果改用源码直接加入工程，请把 `PBCrossAppUniqueDeviceIdentifier/Sources/**` 加入 target，并把 `Sources/Public` 等目录加入 Header Search Paths。

## Demo 做了什么

| 区域 | 内容 |
| --- | --- |
| 身份概览 | 当前版本指纹、上一版本指纹、共享自建 ID、来源与生成时间 |
| 设备属性 | CAID API v1.15 的 14 个字段 + 屏幕/CPU/IDFV/IDFA MD5 等扩展，并标注是否参与当前/兼容版本指纹 |
| 验证操作 | 加载、强制刷新、复制身份 JSON、复制 Device JSON、复制 Device.ext、跨公司匹配、清除身份 |
| 广告请求示例 | `Device.ext` 预览与 `trackingParameters` 预览，点击可复制 |

页面使用固定 Demo salt：`testoc-crossapp-demo-salt`；关闭远端服务、关闭 IDFA 采集、打开旧版 `caid`/`caid_info` 输出。

## 跨公司匹配验证

点击“验证跨公司匹配”会：

1. 用 `PBCrossAdRequestAdapter` 生成拼多多 Device.ext；
2. 把 `ext.pb_cross_app` 还原为 `PBCrossIdentity`；
3. 运行 `PBCrossIdentityMatcher`：
   - 第一组保留 `shared_id`，预期命中 `shared_identifier`；
   - 第二组清空 `shared_id`，预期命中 `versioned_identifier`（当前/上一版本指纹）。

这说明媒体侧把 ext 原样交给广告主后，广告主侧可以用同一套字段、salt 和算法完成归因匹配。

## 运行与验证

1. 在仓库根目录执行 `pod install`（本示例已接入）。若 CocoaPods 报 Ruby `Unicode Normalization` 错误，请先执行 `export LANG=en_US.UTF-8`；
2. 打开 `TestOC.xcworkspace`，运行 `TestOC` scheme；
3. 从“我的”进入“跨 App 设备标识”；
4. 等待加载完成后：
   - 点击 ID/属性可复制；
   - 点击“复制 Device JSON”可查看拼多多 Device 对象；
   - 点击“验证跨公司匹配”查看匹配原因和置信度；
   - 点击“清除本地身份”后重新加载，共享 ID 会更新。

## 注意事项

- 当前版本指纹包含 `bootTimeInSec`，设备重启后会轮换；同 Team 的共享 UUID 不随重启变化。
- 同 Team 跨 App 共享需要在两个 App 的 entitlements 中配置相同的 Keychain Access Group / App Group，示例未配置，因此默认只在本 App 内稳定。
- Demo 不发送网络请求、不主动请求 ATT；正式接入时如需 IDFA，请链接 `AdSupport`/`AppTrackingTransparency` 并完成授权。
- 正式跨公司接入必须统一 salt、算法版本、字段集和采集开关；该 salt 仅为演示。
- 该页面会修改 SDK 的全局配置（salt 等），仅用于 Demo；正式 App 建议在启动阶段统一配置一次。
