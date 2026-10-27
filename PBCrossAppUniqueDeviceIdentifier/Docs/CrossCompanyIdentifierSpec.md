# 跨公司统一设备标识规范（pb-xid-v1）

- 文档版本：1.0
- 算法标识：`pb-xid-v1`
- SDK 版本：PBCrossAppUniqueDeviceIdentifier 1.0.0
- 适用平台：iOS 12.0+

本文档是跨公司复现设备指纹的**规范性说明**。合作方可以不用本 SDK，而按本文档独立实现；只要字段集、规范化规则、版本号和 salt 完全一致，就会得到相同的 32 位十六进制 ID。

---

## 1. 范围与术语

| 术语 | 含义 |
| --- | --- |
| **设备属性（attribute）** | 从 iOS 系统采集的键值对，如 `machine`、`disk`、`bootTimeInSec`。 |
| **字段集（field set）** | 某个算法版本参与指纹计算的属性 Key 集合。 |
| **算法版本（version）** | 一个日期字符串，如 `20261001`，绑定字段集与可选独立 salt。 |
| **指纹 ID（fingerprint）** | 按本文档计算出的 128-bit 标识（32 位小写十六进制）。 |
| **共享 ID（shared_id）** | 通过 Keychain / App Group / 服务端下发、在多个 App 间共享的 UUID 或字符串。 |
| **兼容版本** | 字段集与 CAID API v1.15 5.1 节完全一致的版本 `20260301`。 |

指纹 ID 不是全局唯一设备号，也不是账号 ID；它是基于设备属性的**伪匿名、可复现**标识。其稳定性受字段可用性、重启、系统升级等因素影响。

---

## 2. 版本定义

SDK 默认同时生成两个版本，顺序为「当前版本、上一版本」：

### 2.1 当前版本 `20261001`

参与计算的字段（按 Key ASCII 升序排列后参与拼接）：

```
bootTimeInSec
deviceInitTime
deviceName
disk
machine
memory
mntId
model
processorCount
screenResolution
sysFileTime
```

设计理由：

- 包含启动时间、设备初始化时间、系统更新时间、mntId 等**设备级或单次开机级熵源**，避免仅靠机型/容量字段造成确定性的同机型碰撞；
- 排除 `systemVersion`、`timeZone`、`language`、`countryCode`、`carrierInfo` 等容易随系统升级、出差、换卡变化的字段；
- 单次开机内稳定，跨 App 一致；设备重启后 `bootTimeInSec` 变化，ID 会轮换（与 CAID 包含启动时间的行为一致）。

### 2.2 上一版本 / CAID 兼容版本 `20260301`

参与计算的字段与 CAID API v1.15 5.1 节完全一致：

```
bootTimeInSec
carrierInfo
countryCode
deviceInitTime
deviceName
disk
language
machine
memory
mntId
model
sysFileTime
systemVersion
timeZone
```

用途：和历史 CAID 数据、已按 CAID 14 字段实现的合作方做兼容匹配。

### 2.3 版本升级策略

- 新算法 = 新版本号；**不得修改已发布版本的字段集、规范化规则或 salt**。
- 新版本加入 `supportedVersions` 首位，旧版本继续保留。
- 每个 App 同时上报当前版本 + 上一版本；归因方任一版本 ID 命中即可。
- 双方发布节奏不一致时，至少保证有一个共同版本。

---

## 3. 输入字段与采集格式

### 3.1 字段定义

| Key | 类型 | 格式 | 采集方式（iOS） |
| --- | --- | --- | --- |
| `bootTimeInSec` | 整数秒 | 十进制，无前导零 | `sysctl` `CTL_KERN/KERN_BOOTTIME` 的 `tv_sec` |
| `countryCode` | 字符串 | ISO 3166-1 alpha-2，如 `CN` | `NSLocale.currentLocale[NSLocaleCountryCode]` |
| `language` | 字符串 | 首个 preferred language，如 `zh-Hans-CN` | `NSLocale.preferredLanguages.firstObject` |
| `deviceName` | 字符串 | 32 位小写 MD5 | `UIDevice.name` 的 MD5；iOS 16+ 返回通用名时照常使用 |
| `systemVersion` | 字符串 | 如 `13.1.1` | `UIDevice.systemVersion` |
| `machine` | 字符串 | `hw.machine`，如 `iPhone10,3` | `sysctlbyname("hw.machine")` |
| `carrierInfo` | 字符串 | 中文运营商名、`unknown` 或 `SIMULATOR` | CoreTelephony MCC/MNC 映射，见 3.2 |
| `memory` | 整数 | 字节，十进制 | `NSProcessInfo.physicalMemory` |
| `disk` | 整数 | 字节，十进制 | `NSFileManager` 文件系统 `NSFileSystemSize` |
| `sysFileTime` | 小数秒 | 6 位小数，如 `1595214620.383940` | `MCMeta.plist` 创建时间 |
| `model` | 字符串 | `hw.model`，如 `D22AP` | `sysctlbyname("hw.model")` |
| `timeZone` | 整数秒 | 相对 GMT 的偏移，可为负 | `NSTimeZone.systemTimeZone.secondsFromGMT` |
| `mntId` | 字符串 | 无前缀；可能为空 | `statfs("/")` 的 `f_mntfromname` 去掉 `com.apple.os.update-` 前缀 |
| `deviceInitTime` | 小数秒 | 9 位小数，如 `1632467920.301150749` | `stat("/var/mobile")` 的 `st_birthtimespec` |
| `screenResolution` | 字符串 | `宽x高@scale`，像素 | `UIScreen.nativeBounds` 与 `scale` |
| `processorCount` | 整数 | 十进制 | `NSProcessInfo.processorCount` |

采集失败时该字段视为空字符串（不参与值的区分，但仍按空值参与拼接）。

### 3.2 运营商映射

MCC 为 `460` 时按下表选择中文名：

| MNC | 名称 |
| --- | --- |
| 00 / 02 / 07 / 08 | 中国移动 |
| 01 / 06 / 09 | 中国联通 |
| 03 / 05 / 11 | 中国电信 |
| 04 | 中国卫通 |
| 20 | 中国铁通 |

其他情况使用 `CTCarrier.carrierName`；仍为空则 `unknown`。模拟器为 `SIMULATOR`。

双卡时按 MCC/MNC 字符串排序取第一张有效卡（与 CAID 示例一致）。

### 3.3 只上报、不参与指纹的扩展字段

以下字段进入身份 JSON / 广告请求 ext，但**不参与任何默认版本的指纹**：

`idfv`、`idfa_md5`、`timeZoneIdentifier`、`systemName`、`carrierMCC`、`carrierMNC`、`simulator`。

`idfa_md5` 的输入是标准大写 IDFA UUID（带连字符），例如 `D8A6...-...`；必须用户已授权且广告跟踪未关闭才存在。默认 MD5 输入为**大写 UUID**，合作方如需对齐请遵循同一规则。

---

## 4. 规范化（Canonicalization）

对某个版本 `V`：

1. 取字段集 `K = version.attributeKeys`，去重（保留首次出现）；
2. 按 Key 的 ASCII 字典序升序排序；
3. 对每个 Key 取属性值；缺失或 `nil` 视为 `""`；
4. 值规范化：
   - 去除首尾空白（空格、换行、制表符）；
   - 将 `|`、`\r`、`\n` 替换为一个空格；
   - 若 Key 属于数字字段集合 `{bootTimeInSec, memory, disk, timeZone, processorCount}`：
     - 仅当值完全由可选正负号和 ASCII 数字组成时，去掉前导零，保留负号；
     - 其他值原样保留；
   - 其他字段保持原值（大小写敏感；`deviceName` 已是小写 MD5）。
5. 按如下格式拼接 UTF-8 字符串：

```
pb-xid-v1|{version}|{key1}={value1}|{key2}={value2}|...|{keyN}={valueN}
```

说明：

- 即使值为空也输出 `key=`，保证字段集变化时字符串结构可区分；
- 不添加空格、不排序 value；
- 不对整个字符串做 URL 编码；
- 版本号参与拼接，因此同一字段集的不同版本会得到不同 ID。

### 4.1 规范化示例

当前版本 `20261001` 的测试输入规范化后：

```
pb-xid-v1|20261001|bootTimeInSec=1600607106|deviceInitTime=1632467920.301150749|deviceName=e910ddb2748c36b47fcde5dd720eec11|disk=127938088960|machine=iPhone10,3|memory=4047224832|mntId=80825948939346695D0D7DD52CB405D11A80344027A07803D5F8410346398776C879BF6BD67627@/dev/disk1s1|model=D22AP|processorCount=6|screenResolution=1170x2532@3|sysFileTime=1595214620.383940
```

> 注意 `deviceInitTime` 与 `deviceName` 的排序：ASCII 中 `I`(0x49) < `N`(0x4E)。

---

## 5. ID 计算

```
digest = HMAC-SHA256(key = salt_bytes, message = canonical_utf8_bytes)
id     = lowercase_hex(digest)[0:32]
```

- `salt` 为 UTF-8 字符串；默认值 `pb-xid-default-salt`。
- 每个版本可使用独立 salt（`PBCrossIdentifierVersion.salt`）；未设置时使用全局 salt。
- 输出固定 32 位小写十六进制（128 bit），与 CAID 长度一致。
- 比较 ID 时按 ASCII 大小写不敏感比较；上报统一使用小写。

伪代码：

```text
def pb_xid(attributes, version, salt):
    keys = sorted(unique(version.keys))
    parts = []
    for k in keys:
        v = normalize(attributes.get(k, ""), k)
        parts.append(k + "=" + v)
    canonical = "pb-xid-v1|" + version.name + "|" + "|".join(parts)
    digest = hmac_sha256(salt.encode("utf-8"), canonical.encode("utf-8"))
    return digest.hex()[:32].lower()
```

### 5.1 测试向量

#### 输入属性

| Key | Value |
| --- | --- |
| `bootTimeInSec` | `1600607106` |
| `countryCode` | `CN` |
| `language` | `zh-Hans-CN` |
| `deviceName` | `e910ddb2748c36b47fcde5dd720eec11` |
| `systemVersion` | `13.1.1` |
| `machine` | `iPhone10,3` |
| `carrierInfo` | `中国联通` |
| `memory` | `4047224832` |
| `disk` | `127938088960` |
| `sysFileTime` | `1595214620.383940` |
| `model` | `D22AP` |
| `timeZone` | `28800` |
| `mntId` | `80825948939346695D0D7DD52CB405D11A80344027A07803D5F8410346398776C879BF6BD67627@/dev/disk1s1` |
| `deviceInitTime` | `1632467920.301150749` |
| `screenResolution` | `1170x2532@3` |
| `processorCount` | `6` |

#### 当前版本 `20261001`

Salt：

```
pb-xid-default-salt
```

Canonical：

```
pb-xid-v1|20261001|bootTimeInSec=1600607106|deviceInitTime=1632467920.301150749|deviceName=e910ddb2748c36b47fcde5dd720eec11|disk=127938088960|machine=iPhone10,3|memory=4047224832|mntId=80825948939346695D0D7DD52CB405D11A80344027A07803D5F8410346398776C879BF6BD67627@/dev/disk1s1|model=D22AP|processorCount=6|screenResolution=1170x2532@3|sysFileTime=1595214620.383940
```

期望 ID：

```
820640c66e2c2009becf80c042afda97
```

#### 兼容版本 `20260301`

Salt 相同。

Canonical：

```
pb-xid-v1|20260301|bootTimeInSec=1600607106|carrierInfo=中国联通|countryCode=CN|deviceInitTime=1632467920.301150749|deviceName=e910ddb2748c36b47fcde5dd720eec11|disk=127938088960|language=zh-Hans-CN|machine=iPhone10,3|memory=4047224832|mntId=80825948939346695D0D7DD52CB405D11A80344027A07803D5F8410346398776C879BF6BD67627@/dev/disk1s1|model=D22AP|sysFileTime=1595214620.383940|systemVersion=13.1.1|timeZone=28800
```

期望 ID：

```
b045cceaf204a9e9846e2f5573dd12d8
```

> 兼容版本不使用 `screenResolution`、`processorCount`；输入中有这两个字段也不影响结果。

实现自检命令：`./Tools/verify_logic.sh`。

---

## 6. 跨 App / 跨公司一致性检查清单

双方 App 必须同时满足：

- [ ] `pb-xid-v1` 算法标识一致；
- [ ] 版本号与字段集一致（至少有一个共同版本）；
- [ ] 全局/版本 salt 一致；
- [ ] `collectsDeviceName`、`collectsCarrierInformation` 等采集开关一致；
- [ ] 规范化规则与数字/小数格式一致（直接使用本 SDK 可保证）；
- [ ] 同一次开机、同一台设备上采集（`bootTimeInSec` 必须相同；重启后需重新对齐）；
- [ ] 比较时同时检查当前版本 + 上一版本（任一命中）；
- [ ] 不把 App 级字段（bundle id、App 版本、IDFV）混入指纹。

调试建议：打印 canonical string 和 salt 的指纹（不要打印 salt 明文），对比两端的规范化字符串。

---

## 7. 匹配算法（归因 fallback）

输入为两个身份 JSON（媒体侧 `ext.pb_cross_app` 与广告主侧 `PBCrossIdentity.dictionaryRepresentation`）。按以下顺序：

1. **共享 ID**：双方 `shared_id` 非空且大小写不敏感相等 → matched，confidence 1.0，reason `shared_identifier`。
2. **版本化 ID**：双方任一 `identifiers[].id` 相等 → matched，confidence 1.0，reason `versioned_identifier`（记录命中的 version）。
3. **IDFA MD5**：双方 `attributes.idfa_md5` 非空且相等 → matched，confidence 0.99，reason `advertising_identifier`。
4. **属性相似度**：
   - 对下表每个字段，双方均有非空值才计入“可比”；
   - 值比较：去空白、ASCII 大小写不敏感；数字字段去前导零；
   - `similarity = 相等字段权重和 / 可比字段权重和`；
   - 当 `可比权重和 >= minimumComparableAttributeWeight`（默认 6）且 `similarity >= attributeMatchThreshold`（默认 0.9）时 matched，confidence = similarity。

默认权重：

| Key | 权重 |
| --- | --- |
| `machine` | 3 |
| `model` | 2 |
| `disk` | 2 |
| `memory` | 2 |
| `screenResolution` | 2 |
| `processorCount` | 1 |
| `deviceInitTime` | 3 |
| `sysFileTime` | 2 |
| `mntId` | 3 |
| `bootTimeInSec` | 1 |
| `systemVersion` | 1 |
| `deviceName` | 1 |
| `countryCode` | 0.5 |
| `language` | 0.5 |
| `timeZone` | 0.5 |
| `carrierInfo` | 0.5 |

注意：

- 属性匹配是精确 ID 未命中时的兜底，不应单独用于高价值结算；
- 双方采集能力不同（某些字段为空）会减少可比权重，可能降低置信度；
- 同机型设备在关键熵源全部缺失时可能无法区分。

---

## 8. 远端服务协议（可选）

与 CAID API v1.15 兼容：

请求：

```http
POST {endpoint}
Content-Type: application/json

{
  "dev_id": "{developerID}",
  "encrypted_device_info": "Base64(RSA_PKCS1(UTF8(JSON(14 字段；为空的可选项可省略))))"
}
```

响应：

```json
{
  "code": 0,
  "message": "ok",
  "data": "Base64(RSA_private_key_type1_padding(payload))"
}
```

解密后的 payload：

```json
[
  { "version": "20260101", "caid": "11111111111111111111111111111111" }
]
```

SDK 把 `caid`（或 `id`）映射为远端 ID，最多保留 2 个版本，并按 `version` 降序。请求频率与缓存建议遵循 CAID 文档：同一设备每天不超过 5 次，缓存不超过 24 小时。

注意：CAID 官方服务已下线（拼多多规范 V0.0.33，2026.07.03），此协议仅用于对接自建服务。

---

## 9. 安全与隐私

- salt 用于生态隔离，不是密码学密钥；持有 salt 的一方可复算全部 ID。建议合作方约定非公开 salt，并通过安全渠道分发。
- 指纹输出是 128-bit 截断 HMAC，碰撞概率与截断长度相关，不应作为支付/风控的唯一凭据。
- 禁止把明文设备名、IDFA、IDFV 等写入指纹字符串；SDK 只上报 `deviceName` 的 MD5 与 `idfa_md5`。
- 共享 ID 的 Keychain / App Group 仅能在同一 Apple Developer Team 内生效；不同公司必须使用指纹或远端服务。
- 需要用户同意、隐私政策披露、关闭/清除入口；SDK 默认不联网、不读 IDFA，并提供 `clearStoredIdentity`。
- 具体合规要求以业务所在司法辖区、Apple 审核规则和双方合同为准。

---

## 10. 变更记录

| 版本 | 日期 | 变更 |
| --- | --- | --- |
| 1.0 | 2026-10-27 | 初版；定义 pb-xid-v1、20261001 当前版本、20260301 CAID 兼容版本、匹配权重与测试向量。 |
