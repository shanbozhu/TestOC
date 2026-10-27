# PBCrossAppUniqueDeviceIdentifier

> iOS 跨 App、跨公司统一设备标识 SDK
>
> 版本：1.0.0 · 平台：iOS 12.0+ · 语言：Objective-C

## 1. 背景与目标

iOS 没有稳定、可跨 App / 跨公司共享的设备号。IDFA 受 ATT 限制且用户可关闭，IDFV 只在同一 Vendor 的 App 间一致，Keychain / App Group 也只能在同一 Apple Developer Team 内共享。

本 SDK 解决三件事：

1. **同 Team 多个 App**：通过 Keychain Access Group / App Group 共享同一个自建 UUID（`shared_id`）。
2. **不同媒体、不同开发者的 App**：用**同一套字段 + 同一套规范化规则 + 同一个盐值**拼接设备属性，在本地确定生成 128-bit 指纹 ID（`pb-xid-v1`），多个公司各自计算即可得到相同结果。
3. **需要中心化发号时**：通过兼容 CAID API v1.15 协议的自建 ID 服务下发版本化 ID；广告请求可用 `PBCrossAdRequestAdapter` 直接产出拼多多 Bid Request 的 Device 字段。

同时提供归因匹配器：媒体把广告请求中的 `ext.pb_cross_app` 原样回传，广告主侧还原为 `PBCrossIdentity` 后即可判断是否同一设备。

> **背景说明**：拼多多《媒体广告平台接入拼多多外投广告技术规范》从 V0.0.33（2026.07.03）起已下线 Caid 字段。本 SDK 不依赖 CAID 官方服务；默认纯本地生成、不发起网络请求。

## 2. 三种接入模式

| 模式 | 适用场景 | 稳定性 | 实现 |
| --- | --- | --- | --- |
| 共享自建 UUID | 同一 Team 的多款 App（同一开发者/同一集团） | 高，App 重装后通常仍保留（Keychain 系统行为） | Keychain Access Group + App Group，`shared_id` |
| 设备属性指纹 | 不同公司、不同开发者的 App 互相对齐 | 单次开机内稳定；重启后轮换（与 CAID 行为一致） | `pb-xid-v1`，当前版本 + 上一版本双 ID |
| 自建 ID 服务 | 需要中心化发号、跨公司强对齐、风控/归因 | 由服务端策略决定 | CAID API 兼容协议 + RSA，`remote` ID |

跨公司对齐的前提是：双方 App 使用**相同的 SDK 配置**——相同算法版本、相同字段集、相同 salt、相同采集开关。任一不同，指纹就会不同。算法规范见 [Docs/CrossCompanyIdentifierSpec.md](Docs/CrossCompanyIdentifierSpec.md)。

## 3. 快速开始

### 3.1 CocoaPods

```ruby
pod 'PBCrossAppUniqueDeviceIdentifier', :path => './PBCrossAppUniqueDeviceIdentifier'
```

或发布到私有 Specs 仓库后按版本引入。发布前请把 podspec 中的 `homepage` / `source` 改成实际仓库地址。

手动集成：把 `Sources/**/*.{h,m}` 加入工程，链接 `Foundation`、`UIKit`、`Security`、`CoreTelephony`，开启 ARC。

### 3.2 配置

```objc
#import <PBCrossAppUniqueDeviceIdentifier/PBCrossAppUniqueDeviceIdentifier.h>

NSError *error = nil;
BOOL ok = [[PBCrossAppUniqueDeviceIdentifierManager sharedManager]
           configureWithBlock:^(PBCrossConfiguration *configuration) {
    // 跨公司必须一致；建议由合作方约定一个非公开值
    configuration.salt = @"your-ecosystem-salt";

    // 同 Team 跨 App 共享；没有对应 entitlement 时留空即可
    configuration.keychainAccessGroup = @"ABCDE12345.com.example.pbcross";
    configuration.appGroupIdentifier = @"group.com.example.pbcross";

    // 默认 NO：不读取 IDFA、不弹 ATT 授权框
    configuration.allowsAdvertisingIdentifier = NO;

    // 默认 NO：不发起远端请求
    configuration.remoteConfiguration.enabled = NO;
} error:&error];
```

Entitlements 示例（两个 App 都要配置相同值）：

```xml
<key>keychain-access-groups</key>
<array>
    <string>$(AppIdentifierPrefix)com.example.pbcross</string>
</array>
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.example.pbcross</string>
</array>
```

> `keychainAccessGroup` 在运行时必须传展开后的完整值，例如 `ABCDE12345.com.example.pbcross`，不能直接传 `$(AppIdentifierPrefix)`。

### 3.3 加载身份

```objc
[[PBCrossAppUniqueDeviceIdentifierManager sharedManager]
 loadIdentityWithCompletion:^(PBCrossIdentity *identity, NSError *error) {
    if (!identity) { return; }

    NSLog(@"current=%@/%@", identity.currentIdentifier, identity.currentVersion);
    NSLog(@"previous=%@/%@", identity.previousIdentifier, identity.previousVersion);
    NSLog(@"shared=%@", identity.sharedID);
}];
```

同步接口 `identitySynchronously` 可能阻塞约 0.5 秒（运营商读取超时），不要在启动关键路径的主线程上反复调用；加载完成后 SDK 会做内存缓存（默认 300 秒）。

### 3.4 生成拼多多 Device 对象

```objc
PBCrossAdRequestContext *context = [[PBCrossAdRequestContext alloc] init];
context.userAgent = requestUserAgent;      // 宿主自行获取
context.ipAddress = clientIP;              // 宿主自行获取
context.connectionType = PBCrossConnectionTypeWiFi; // 宿主自行判断

PBCrossAdRequestAdapter *adapter =
    [[PBCrossAppUniqueDeviceIdentifierManager sharedManager]
     adRequestAdapterWithContext:context];

NSDictionary *device = [adapter deviceDictionary];
NSString *deviceExtJSON = device[@"ext"];

// 把 device 合并到 Bid Request：
// { "adx_id": "...", ..., "device": device }
```

> `deviceDictionary` 只负责设备标识相关字段；拼多多要求的 `ua`、`ip`、`connectiontype` 等请由宿主通过 `PBCrossAdRequestContext` 或请求构造逻辑补齐（`geo` 等可选字段也不在本适配器范围内）。

`deviceDictionary` 会输出：

- `make`、`model`、`os`、`osv`、`h`、`w`、`devicetype`、`connectiontype`、`carrier`；
- `idfa_md5`（默认只输出 MD5；明文 IDFA 需 `allowsAdvertisingIdentifier` + `emitsRawAdvertisingIdentifier`，并自行完成 ATT 授权）；
- `birth_time`、`boot_time`、`update_time`、`last_update_time`（CAID 兼容字段，映射自 `deviceInitTime`、`bootTimeInSec`、`sysFileTime`、上一次 `sysFileTime`）；
- `paid` / `paid_1_4`（宿主从拼多多 SDK 获取后填入 context）；
- `ext`：JSON 字符串，核心是 `pb_cross_app` 完整身份快照（即 `PBCrossIdentity.dictionaryRepresentation`）；
- 可选 `caid` / `caid_info`（默认关闭，仅用于仍消费 CAID 的平台）。

### 3.5 跨公司归因匹配

媒体侧把广告请求 Device.ext 原样回传或上报到服务端；广告主侧：

```objc
NSDictionary *ext = [NSJSONSerialization JSONObjectWithData:extData options:0 error:NULL];
PBCrossIdentity *mediaIdentity = [PBCrossIdentity identityWithAdRequestExtension:ext];

PBCrossIdentity *myIdentity =
    [[PBCrossAppUniqueDeviceIdentifierManager sharedManager] identitySynchronously];

PBCrossIdentityMatchResult *result =
    [[[PBCrossIdentityMatcher alloc] init] matchIdentity:myIdentity
                                            withIdentity:mediaIdentity];

if (result.matched) {
    // result.reason: shared_identifier / versioned_identifier /
    //                advertising_identifier / device_attributes
    // result.confidence: 1.0 / 0.99 / 属性相似度
}
```

服务端（Java/Go 等）可依据 [算法规范](Docs/CrossCompanyIdentifierSpec.md) 重新实现指纹与匹配逻辑。

## 3.6 TestOC 接入示例

本仓库的 TestOC 已通过本地 Pod 接入 SDK，示例页位于：

```
TestOC/Page/Mine/PBCrossAppUniqueDeviceIdentifier/
```

入口：`TestOC → 我的 → PBCrossAppUniqueDeviceIdentifierController`（页面标题“跨 App 设备标识”）。示例页演示身份加载、共享自建 ID、设备属性、广告 Device 对象、`Device.ext` 与跨公司匹配结果；详见该目录下的 README。

Podfile 配置：

```ruby
pod 'PBCrossAppUniqueDeviceIdentifier', :path => './PBCrossAppUniqueDeviceIdentifier'
```

## 4. 字段说明

### 4.1 CAID 兼容字段

| Key | 含义 | 格式/来源 | 当前版本 `20261001` | 兼容版本 `20260301` | PDD Device |
| --- | --- | --- | --- | --- | --- |
| `bootTimeInSec` | 设备启动时间 | `sysctl KERN_BOOTTIME`，秒 | ✅ | ✅ | `boot_time` |
| `countryCode` | 国家/地区 | `NSLocale`，如 `CN` | — | ✅ | — |
| `language` | 语言 | 首个 preferredLanguage，如 `zh-Hans-CN` | — | ✅ | — |
| `deviceName` | 设备名 MD5 | `UIDevice.name` 的 32 位小写 MD5 | ✅ | ✅ | — |
| `systemVersion` | 系统版本 | `UIDevice.systemVersion` | — | ✅ | `osv` |
| `machine` | 硬件标识 | `hw.machine`，如 `iPhone10,3` | ✅ | ✅ | `model`（可被 context 覆盖） |
| `carrierInfo` | 运营商 | MCC/MNC 映射中文名，或 `unknown`/`SIMULATOR` | — | ✅ | `carrier`（再映射枚举） |
| `memory` | 物理内存字节 | `NSProcessInfo.physicalMemory` | ✅ | ✅ | — |
| `disk` | 磁盘总容量字节 | `NSFileSystemSize` | ✅ | ✅ | — |
| `sysFileTime` | 系统更新时间 | `MCMeta.plist` 创建时间，6 位小数 | ✅ | ✅ | `update_time` |
| `model` | 硬件 Model | `hw.model`，如 `D22AP` | ✅ | ✅ | — |
| `timeZone` | 时区偏移秒 | `secondsFromGMT` | — | ✅ | — |
| `mntId` | 系统挂载标识 | `statfs("/")` 去掉 `com.apple.os.update-` 前缀 | ✅ | ✅ | — |
| `deviceInitTime` | 设备初始化时间 | `stat("/var/mobile")`，9 位小数 | ✅ | ✅ | `birth_time` |

### 4.2 扩展字段

| Key | 含义 | 是否参与指纹 |
| --- | --- | --- |
| `idfv` | identifierForVendor（小写） | 否（仅同 Vendor 一致，不能跨公司） |
| `idfa_md5` | IDFA 的 MD5（用户授权后才存在，MD5 输入为标准大写 UUID） | 否（匹配器可单独使用） |
| `screenResolution` | `宽x高@scale`（像素） | ✅ 当前版本 |
| `processorCount` | CPU 核心数 | ✅ 当前版本 |
| `timeZoneIdentifier` | 如 `Asia/Shanghai` | 否 |
| `systemName` | 如 `iOS` | 否 |
| `carrierMCC` / `carrierMNC` | 运营商 MCC/MNC | 否 |
| `simulator` | 是否模拟器 | 否 |

`PBCrossDeviceAttributes.CAIDDeviceInfoDictionaryIncludingEmptyValues:` 可直接得到 CAID 5.1 节的 14 字段字典，用于对接 CAID 兼容服务。缺失字段可用空串补齐。

### 4.3 数据格式注意事项

跨公司双方必须使用完全一致的格式：

- `memory`/`disk`/`processorCount`/`timeZone`：十进制整数，不带前导零（SDK 会比较前导零并归一化）；
- `sysFileTime`：秒 + 小数点后 6 位，如 `1595214620.383940`；
- `deviceInitTime`：秒 + 小数点后 9 位，如 `1632467920.301150749`；
- `screenResolution`：像素宽 `x` 像素高 `@` 缩放，如 `1170x2532@3`；
- `deviceName`：32 位小写 MD5；
- 空值：按空字符串参与拼接（`key=`）。

## 5. 指纹算法与版本

算法 `pb-xid-v1`：

1. 取当前版本配置的字段集；
2. 按 Key 的 ASCII 升序排列；
3. 拼接规范化字符串：

   ```
   pb-xid-v1|{version}|{key1}={value1}|{key2}={value2}|...
   ```

4. 以 salt 为 key 做 `HMAC-SHA256`；
5. 取十六进制小写结果前 32 位，得到与 CAID 长度一致的 128-bit ID。

示例（完整测试向量见算法规范）：

```
pb-xid-v1|20261001|bootTimeInSec=...|deviceInitTime=...|deviceName=...|...
salt = pb-xid-default-salt
id   = 820640c66e2c2009becf80c042afda97
```

默认同时生成两个版本：

| 版本 | 字段集 | 说明 |
| --- | --- | --- |
| `20261001`（当前） | 启动时间、设备名 MD5、设备初始化时间、系统更新时间、machine、model、disk、memory、screenResolution、processorCount、mntId | 单次开机内稳定，避开系统版本/时区/语言/运营商等易变字段；含设备级熵源，降低同机型碰撞 |
| `20260301`（上一版本/CAID 兼容） | CAID API 5.1 节全部 14 个字段 | 便于与历史 CAID 数据、已接入合作方兼容匹配 |

发布新算法版本时：把新版本放在 `supportedVersions` 最前面，保留旧版本；不要修改已发布版本的字段集或 salt。双方升级窗口不同时，靠“当前 + 上一版本”双 ID 任一命中。

## 6. 广告请求输出示例

```json
{
  "devicetype": 1,
  "make": "apple",
  "model": "iPhone10,3",
  "os": "ios",
  "osv": "13.1.1",
  "w": 1170,
  "h": 2532,
  "connectiontype": 2,
  "carrier": "unicom",
  "idfa_md5": "8356c484baee55db3144931bd2b3bfc6",
  "birth_time": "1632467920.301150749",
  "boot_time": "1600607106",
  "update_time": "1595214620.383940",
  "last_update_time": "1590000000.000000",
  "ext": "{\"pb_cross_app\":{\"algorithm\":\"pb-xid-v1\",\"id\":\"820640c66e2c2009becf80c042afda97\",\"version\":\"20261001\",\"previous_id\":\"b045cceaf204a9e9846e2f5573dd12d8\",\"previous_version\":\"20260301\",\"shared_id\":\"939ef7d9-1a4a-4f5e-a2f2-5126cb8af469\",\"sources\":[\"fingerprint\",\"shared_storage\"],\"identifiers\":[...],\"attributes\":{...},\"sdk_version\":\"1.0.0\"}}"
}
```

> 上例中的 ID/deviceName 来自测试向量，实际设备会不同。

S2S 上报/点击监测 URL 可追加 `trackingParameters`：

```
pb_xid=820640c66e2c2009becf80c042afda97
pb_xid_version=20261001
pb_xid_prev=b045cceaf204a9e9846e2f5573dd12d8
pb_xid_prev_version=20260301
pb_shared_id=939ef7d9-1a4a-4f5e-a2f2-5126cb8af469
pb_algorithm=pb-xid-v1
pb_xid_source=fingerprint,shared_storage
```

有远端 ID 时还会带 `pb_xid_remote`、`pb_xid_remote_version`。参数未做 URL 编码，请调用方自行编码。

`emitsLegacyCAIDFields = YES` 时会额外输出 `caid`（第一个 ID）与 `caid_info`（`[{caid, version}]`），仅供仍消费 CAID 的平台使用。

## 7. 归因匹配

匹配优先级：

1. `shared_id` 相同 → 100%；
2. 任一版本 ID 相同（当前/上一版本/远端）→ 100%；
3. IDFA MD5 相同 → 99%（双方都需授权）；
4. 设备属性相似度 ≥ 阈值（默认 0.9）且可比权重 ≥ 6 → 按相似度置信。

默认属性权重：

| 字段 | 权重 | 字段 | 权重 |
| --- | --- | --- | --- |
| `machine` | 3 | `model` | 2 |
| `disk` | 2 | `memory` | 2 |
| `screenResolution` | 2 | `processorCount` | 1 |
| `deviceInitTime` | 3 | `sysFileTime` | 2 |
| `mntId` | 3 | `bootTimeInSec` | 1 |
| `systemVersion` | 1 | `deviceName` | 1 |
| `countryCode` | 0.5 | `language` | 0.5 |
| `timeZone` | 0.5 | `carrierInfo` | 0.5 |

可通过 `attributeWeights` 覆盖、`attributeMatchThreshold` 调整阈值。属性匹配是精确 ID 都未命中时的兜底；重启、系统升级、字段不可用都会影响结果，不能替代服务端授权/风控。

## 8. 自建 ID 服务（CAID API 兼容）

默认关闭。需要中心化发号时：

```objc
PBCrossRemoteConfiguration *remote = configuration.remoteConfiguration;
remote.enabled = YES;
remote.endpointURL = [NSURL URLWithString:@"https://id.example.com/v1.0/get"];
remote.developerID = @"your-dev-id";
remote.publicKey = @"-----BEGIN CERTIFICATE-----..."; // 或 Base64 证书/公钥
remote.cacheTimeToLive = 24 * 60 * 60;  // 默认 24h
remote.dailyRequestLimit = 5;           // 默认 5 次/天
remote.requiresUserConsent = YES;
remote.userConsentGranted = YES;        // 用户同意隐私政策后再置 YES

// 手动请求一次（自动刷新默认开启，也可关闭 automaticallyRefreshesRemoteIdentity）
[[PBCrossAppUniqueDeviceIdentifierManager sharedManager]
 resolveRemoteIdentityWithCompletion:^(PBCrossIdentity *identity, NSError *error) {
    // 成功后会更新内存缓存；同时主线程发送
    // PBCrossAppUniqueDeviceIdentifierDidUpdateNotification
}];
```

请求/响应与 CAID API v1.15 一致：

```http
POST /v1.0/get
Content-Type: application/json

{"dev_id":"your-dev-id","encrypted_device_info":"BASE64(RSA-PKCS1(JSON(14 字段；mntId/deviceInitTime 为空时省略)))"}
```

```json
{"code":0,"message":"ok","data":"BASE64(RSA-私钥加密后的 [{version, caid}]）"}
```

SDK 行为：

- 使用公钥 RSA/PKCS#1 分段加密设备信息；
- 用公钥对响应做 Raw RSA 解密并去除 PKCS#1 Type 1 padding（与 CAID 客户端示例一致）；
- 解析 `data` 中的 `caid`/`id` 字段并映射为 `PBCrossIdentifierKindRemote`；
- 最多保留 2 个版本；
- 缓存、每日 5 次限流；
- 未同意隐私授权时不发请求。

公钥支持 X.509 证书（Base64/PEM）、PKCS#1 公钥、SPKI 公钥。生产环境建议把加解密放到服务端，客户端只拿结果，避免密钥与协议细节暴露。

> 默认指向自建服务；CAID 官方服务已于 2026.07 下线，请勿把 endpoint 配置为已停用的 CAID 地址。

## 9. 隐私与合规

- 默认**不采集 IDFA**、不弹 ATT；需要时由宿主链接 `AdSupport` / `AppTrackingTransparency`、完成 ATT 授权，并把 `allowsAdvertisingIdentifier` 置 YES。
- 默认**不发网络请求**；远端能力需显式启用并完成隐私授权。
- 仅采集设备级属性；设备名只保留不可逆 MD5，不保存/上报明文；IDFA 默认只输出 MD5。
- `idfv` 会出现在 ext/identity JSON 中，如产品认为敏感，可在上报前裁剪 `attributes`（但会影响属性匹配）。
- Keychain 数据在 App 卸载后通常仍保留；提供 `clearStoredIdentity` 清除（会清除同一 Keychain Access Group / App Group 内其他 App 的共享 ID，请谨慎调用）。
- 指纹 ID 是**伪匿名标识**，不是账号 ID，不应跨设备关联用户；salt 不是加密密钥，拿到 salt 的人可以复算 ID，它的作用是隔离生态/合作方。
- 上线前请按 PIPL、CCPA、Apple ATT/隐私清单等要求完成法务与隐私评估，并提供可关闭/清除入口。
- 本 SDK 使用了 `NSUserDefaults`、启动时间（`sysctl`）、文件时间戳、磁盘容量等 API，提交 App Store 时请按 Apple 的 Required Reason API 要求，在宿主 App 的 `PrivacyInfo.xcprivacy` 中声明与实际用途匹配的原因，并结合业务用途审核；仓库不附带可能不适用的隐私清单。

## 10. 稳定性与边界

| 情况 | 结果 |
| --- | --- |
| App 重装（未重启） | 指纹 ID 不变；共享 UUID 通常也不变（Keychain 保留） |
| 设备重启 | 当前/兼容指纹变化（`bootTimeInSec` 变化）；共享 UUID 不变；可用属性匹配兜底 |
| 系统升级 | `sysFileTime`/`deviceInitTime`/`systemVersion` 可能变化，指纹可能变化；属性匹配可能降级 |
| 同一机型多台设备 | 依赖启动时间、设备初始化时间、系统更新时间、mntId、设备名等熵源；这些字段都不可用时存在碰撞风险 |
| 不同公司配置不一致 | salt/版本/字段/service 不同 → ID 不同，这是设计行为 |
| 模拟器 | `machine=arm64`、运营商 `SIMULATOR`，不能作为真机 ID |
| `sysFileTime`/`mntId`/`deviceInitTime` 为空 | 仍可生成 ID；远端 CAID 兼容服务可能因必填校验失败 |

## 11. 目录结构

```
PBCrossAppUniqueDeviceIdentifier/
├── PBCrossAppUniqueDeviceIdentifier.podspec
├── README.md
├── CHANGELOG.md
├── LICENSE
├── Sources/
│   ├── PBCrossAppUniqueDeviceIdentifier.h        # 伞头文件
│   ├── Public/                                   # 公开 API
│   ├── Private/                                  # 内部实现头文件
│   └── Implementation/                           # .m
├── Docs/
│   └── CrossCompanyIdentifierSpec.md             # 跨公司算法规范（可交给合作方实现）
├── Tests/
│   └── PBCrossLogicVerification.m                # 纯逻辑自检（macOS 可运行）
└── Tools/
    └── verify_logic.sh
```

## 12. 编译与自检

```bash
# 在 PBCrossAppUniqueDeviceIdentifier 目录下
pod lib lint PBCrossAppUniqueDeviceIdentifier.podspec --allow-warnings --skip-tests

# 纯逻辑自检（指纹向量、匹配器、JSON 往返）
./Tools/verify_logic.sh
```

也可以把 `Sources` 直接加入现有 iOS 工程，使用 `TestOC.xcworkspace` 构建。

当前版本已验证：

- `pod lib lint`（CocoaPods 1.16.2 / Xcode 26.3）通过；
- `Tools/verify_logic.sh` 的指纹测试向量与匹配用例全部通过；
- iOS 26.3 模拟器运行验证：设备属性采集、身份生成、广告适配器、JSON 往返、服务端 ID 注入/清除、远端 ID 解析与缓存（本地 mock 服务 + RSA）。

## 13. FAQ

**Q: Keychain 返回 -34018 / 共享 ID 每次都不一样？**
A: 通常是 App 缺少 keychain-access-groups entitlement，或 `keychainAccessGroup` 未传展开后的 TeamID 前缀。请检查两个 App 的 entitlements 是否一致；临时可留空该配置，退回 App 私有存储。

**Q: 两个 App 的 `pb_xid` 不一致？**
A: 依次检查：`salt`、`supportedVersions`、`collectsDeviceName`、`collectsCarrierInformation`、采集时机（是否跨重启）、SDK 版本。调试时打印 `PBCrossIdentityGenerator` 的 canonical string（内部头文件）对比。

**Q: 重启后 ID 变了？**
A: 当前版本包含 `bootTimeInSec`，这是为了避免同机型设备仅靠硬件字段产生确定性碰撞。共享 UUID 不受影响；跨重启归因可用属性匹配或服务端 ID。

**Q: IDFA 为空？**
A: 默认不采集；开启后仍需 ATT 已授权且广告跟踪未关闭。系统也可能返回全零 UUID。

**Q: 远端解析返回“缺少必填设备属性”？**
A: CAID 协议要求 14 字段中除 `mntId`/`deviceInitTime` 外均有值；模拟器或受限沙箱可能拿不到 `sysFileTime`，请改用本地指纹或放宽自建服务校验。

**Q: 能否在 App Extension 中使用？**
A: 可以使用本地指纹与共享存储；运营商/Keychain 的可用性受 Extension 环境限制，建议在宿主 App 生成后通过 App Group 共享。

## 14. 参考资料

- 《CAID API 接入文档》v1.15（`api_v1.15.pdf`）：设备信息 14 字段、RSA 加解密、版本化 CAID、限流与缓存要求。
- 《媒体广告平台接入拼多多外投广告技术规范》0.0.34（`媒体广告平台接入拼多多外投广告技术规范[0.0.34].pdf`）：Device 对象字段、CAID 下线记录（V0.0.33）、运营商/联网类型枚举。
- [Docs/CrossCompanyIdentifierSpec.md](Docs/CrossCompanyIdentifierSpec.md)：跨公司实现规范与测试向量。
