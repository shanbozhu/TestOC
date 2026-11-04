# PBCrossAppUniqueDeviceIdentifier 功能流程图

按当前源码整理，更新于 2026-11-04，包含本轮 P2 修复。图中的步骤表示当前实现；升级、跨 App 和兼容接口的边界列在第 10 节。

本文使用 Mermaid，可在支持 Mermaid 的 Markdown 阅读器中查看和维护。

## 导航

1. [功能总览](#1-功能总览)
2. [配置更新](#2-配置更新)
3. [身份加载、缓存与结果交付](#3-身份加载缓存与结果交付)
4. [共享 ID 读取与原子创建](#4-共享-id-读取与原子创建)
5. [设备属性采集与版本指纹](#5-设备属性采集与版本指纹)
6. [远端解析](#6-远端解析)
7. [广告授权与广告请求输出](#7-广告授权与广告请求输出)
8. [归因匹配](#8-归因匹配)
9. [缓存重置、身份清理与服务端注入](#9-缓存重置身份清理与服务端注入)
10. [当前实现边界](#10-当前实现边界)
11. [线程与源码索引](#11-线程与源码索引)

## 1. 功能总览

```mermaid
flowchart TD
    Host["宿主 App"] --> Config["配置 Manager"]
    Config --> Load["加载身份 / 强制刷新"]
    Load --> Cache{"内存缓存可用？"}
    Cache -->|是，且未强制刷新| Snapshot["PBCrossIdentity 身份快照"]
    Cache -->|否| Collect["采集设备属性"]
    Collect --> Shared["读取共享 ID<br/>Keychain 为持久化依据"]
    Collect --> Fingerprint["计算当前 / 兼容版本指纹"]
    Collect --> RemoteCache["读取已有远端 ID<br/>需启用服务并满足同意条件"]
    Shared --> Assemble["组合身份与来源"]
    Fingerprint --> Assemble
    RemoteCache --> Assemble
    Assemble --> Snapshot
    Snapshot --> Export["广告 Device / ext / 监测参数"]
    Snapshot --> Match["归因匹配器"]
    Snapshot -. "可选：异步解析远端 ID" .-> Remote["自建 ID 服务"]
    Remote --> Update["合并 remote ID<br/>更新缓存、通知与回调"]
    Update --> Snapshot
```

身份快照同时容纳多类标识，不是只选择其中一种：

| 数据 | 来源与用途 |
| --- | --- |
| `sharedID` / `shared_id` | 服务端显式注入的共享 ID 优先，否则使用 Keychain 自建 UUID；同 Team 可通过共享 Access Group 共享。 |
| `identifiers` 中的 `fingerprint` | 每个受支持版本独立计算；默认包含当前版本 `20261001` 和兼容版本 `20260301`。 |
| `identifiers` 中的 `remote` | 自建远端服务返回的版本化 ID；与本地指纹并存，不自动覆盖 `sharedID`。 |
| `attributes` | 设备属性；可选 IDFA MD5 用于匹配和广告输出，默认指纹字段不含 IDFA。 |

`currentIdentifier` 优先选择第一个本地指纹；`previousIdentifier` 选择后续第一个本地指纹。只有没有本地指纹时，`currentIdentifier` 才回退到标识数组首项。指纹是属性计算结果，不保证全局唯一或永久不变。

## 2. 配置更新

入口：`configureWithBlock:error:`。

```mermaid
flowchart TD
    Start["调用 configureWithBlock:error:"] --> Block{"block 存在？"}
    Block -->|否| Reject["返回 NO + 配置错误<br/>保持原配置"]
    Block -->|是| Copy["复制当前配置<br/>执行宿主配置 block"]
    Copy --> Validate{"配置校验通过？"}
    Validate -->|否| Reject
    Validate -->|是| Lock["在 Manager 锁内提交"]
    Lock --> InvalidateResolver["使旧 Resolver 失效并取消网络任务"]
    InvalidateResolver --> Replace["保存配置副本<br/>创建新 Store"]
    Replace --> Remote{"远端服务已启用？"}
    Remote -->|是| Resolver["创建新 Resolver"]
    Remote -->|否| NoResolver["Resolver 设为 nil"]
    Resolver --> Invalidate["清空内存身份缓存<br/>generation 加一"]
    NoResolver --> Invalidate
    Invalidate --> Drain["清除远端进行中标记<br/>取出并清空等待回调"]
    Drain --> Cancel["有等待者时：安排主线程取消回调"]
    Cancel --> Done["返回 YES"]
```

主要校验包括：salt 非空、版本数组非空、版本名和字段集有效且版本名不重复、Keychain service 非空、缓存时长非负，以及已启用远端服务的静态配置有效。配置 App Group 时必须同时配置共享 Keychain Access Group；仅 App Group 会校验失败。

重新配置不删除已有 Keychain 或 Defaults 数据。`generation` 用于阻止旧配置的加载结果提交到当前内存缓存、回调或通知；持久化边界见第 10 节。

## 3. 身份加载、缓存与结果交付

### 3.1 本地加载主流程

入口：`loadIdentityWithCompletion:`、`refreshIdentityWithCompletion:`、`identitySynchronously`。

```mermaid
flowchart TD
    Start["加载身份"] --> Context["原子捕获 Context<br/>配置 / Store / Resolver / generation"]
    Context --> Valid{"generation 仍有效？"}
    Valid -->|否| Cancel["本次加载取消"]
    Valid -->|是| Hit{"非强制刷新，且缓存未过期？"}
    Hit -->|是| Cached["检查当前广告授权<br/>按需移除缓存 IDFA / MD5"]
    Cached --> Return["进入结果交付流程"]
    Hit -->|否| Collect["采集设备属性"]
    Collect --> Remote["读取已缓存 remote ID<br/>需远端启用且满足同意条件"]
    Remote --> Shared["读取或创建 sharedID<br/>保留存储错误"]
    Shared --> History["维护系统更新时间历史"]
    History --> Generate["按 supportedVersions 计算指纹"]
    Generate --> Build["组合 sharedID、fingerprint、remote<br/>属性、来源、时间戳"]
    Build --> Commit{"提交时 generation 仍有效？"}
    Commit -->|否| Cancel
    Commit -->|是| Sanitize["检查当前广告授权"]
    Sanitize --> Error{"有共享 ID 存储错误？"}
    Error -->|是| Partial["不缓存本次身份<br/>返回无 sharedID 的快照 + 错误"]
    Error -->|否| Save["缓存身份与生成时间"]
    Partial --> Return
    Save --> Return
```

- 普通加载优先使用内存缓存，默认有效期 300 秒；设为 0 表示每次重新采集。
- 强制刷新绕过内存缓存，但仍使用持久化共享 ID 和已缓存的远端 ID，不强制发起网络请求。
- 本地加载允许带入已过期的远端缓存；远端 TTL 用于决定是否需要后台刷新，而不是立即删除旧远端 ID。
- `cachedIdentity` 返回最近快照，不检查缓存时效，但会检查当前广告授权。

### 3.2 同步、异步与取消

```mermaid
flowchart TD
    Result["本地加载产生结果"] --> Mode{"调用方式？"}
    Mode -->|同步| SyncCheck{"返回前 generation 有变化？"}
    SyncCheck -->|是| Retry["捕获最新 Context<br/>重新加载"]
    Retry --> Result
    SyncCheck -->|否| SyncAuth["重查广告授权"]
    SyncAuth --> SyncReturn["直接返回身份"]
    Mode -->|异步| Schedule["安排主线程 completion"]
    Schedule --> CallbackCheck{"交付前 generation 有变化？"}
    CallbackCheck -->|是| Cancel["completion：nil + OperationCancelled"]
    CallbackCheck -->|否| CallbackAuth["重查广告授权"]
    CallbackAuth --> Deliver["completion：身份 + 原加载错误"]
    Schedule -. "独立检查，不等待网络结果" .-> Auto{"加载无错误、版本有效<br/>自动刷新开关开启、远端可用<br/>同意条件满足、远端缓存不新鲜？"}
    Auto -->|是| Resolve["排队执行远端解析"]
    Auto -->|否| Finish["结束本次自动刷新检查"]
```

同步加载本身不触发自动远端请求。若 Keychain 失败，同步接口返回不含共享 ID 的快照，错误详情需通过异步加载获取。

## 4. 共享 ID 读取与原子创建

### 4.1 服务端 ID 优先

入口：Store 的 `sharedIDCreatingIfNeeded:serverIssued:error:`；Manager 的 `sharedID` 属性会以 `create=YES` 调用。

```mermaid
flowchart TD
    Start["读取 sharedID"] --> Server["读取 pb_server_shared_id<br/>不生成随机候选值"]
    Server --> ServerError{"有存储错误？"}
    ServerError -->|是| Fail["返回空串 + 错误<br/>不生成替代身份"]
    ServerError -->|否| HasServer{"存在服务端 ID？"}
    HasServer -->|是| ServerReturn["镜像 sharedID<br/>标记 serverIssued=YES 并返回"]
    HasServer -->|否| Local["读取 pb_shared_id<br/>按 create 参数决定能否创建"]
    Local --> LocalError{"有存储错误？"}
    LocalError -->|是| Fail
    LocalError -->|否| Mirror["有值时镜像到 Defaults<br/>返回 ID；无值则空串"]
```

### 4.2 单个 Key 的读取和原子新增

```mermaid
flowchart TD
    Start["读取指定 Keychain Key"] --> Read{"读取状态？"}
    Read -->|成功且数据有效| Existing["返回已存 ID"]
    Read -->|不可用 / 权限错误 / 数据损坏| Error["返回错误<br/>保留记录，不覆盖"]
    Read -->|errSecItemNotFound| Create{"允许创建？"}
    Create -->|否| Empty["返回无值"]
    Create -->|是| UUID["生成随机 UUID 候选值"]
    UUID --> Add["SecItemAdd 原子新增"]
    Add --> Status{"新增状态？"}
    Status -->|成功| Winner["返回已落盘候选值"]
    Status -->|errSecDuplicateItem| Reread["重新读取持久化胜出值"]
    Reread --> RereadOK{"读取成功且有效？"}
    RereadOK -->|是| Existing
    RereadOK -->|否| Error
    Status -->|其他错误| Error
```

并发首次创建依靠 Keychain 的原子新增确定胜出值，不返回未保存的随机候选值。Defaults 仅作镜像，并按 service/accessGroup 隔离；Keychain 缺失时不会从任何旧镜像恢复 ID。已有 Keychain 记录沿用，旧 Defaults 单独存留的 ID 不再迁移。

## 5. 设备属性采集与版本指纹

```mermaid
flowchart TD
    Start["Collector 开始采集"] --> UIKit["主线程读取 UIKit 属性<br/>设备名、系统版本、IDFV、屏幕"]
    UIKit --> System["读取系统属性<br/>启动时间、硬件、内存、磁盘、文件时间等"]
    System --> Optional["按开关处理设备名 MD5、运营商<br/>运营商读取最多等待 0.5 秒"]
    Optional --> IDFA["允许采集且广告授权有效时<br/>读取非全零 IDFA 并计算 MD5"]
    IDFA --> Attributes["生成不可变 Attributes"]
    Attributes --> Version["依次处理 supportedVersions"]
    Version --> Keys["对该版本的属性 Key 排序"]
    Keys --> Normalize["取值并规范化<br/>去首尾空白、替换分隔符和换行<br/>指定整数字段去前导零"]
    Normalize --> Canonical["拼接算法名、版本名与 key=value"]
    Canonical --> Salt{"该版本有独立 salt？"}
    Salt -->|是| VersionSalt["使用版本 salt"]
    Salt -->|否| GlobalSalt["使用全局 salt"]
    VersionSalt --> Hash["HMAC-SHA256"]
    GlobalSalt --> Hash
    Hash --> Truncate["取前 32 个十六进制字符<br/>128-bit 指纹"]
    Truncate --> Identifier["生成 kind=fingerprint 的版本标识"]
    Identifier --> More{"还有版本？"}
    More -->|是| Version
    More -->|否| Done["按配置顺序返回版本标识数组"]
```

规范字符串形式为：`pb-xid-v1|版本名|key=value|key=value`。缺失属性按空串参与；默认当前版本包含启动时间，设备重启后指纹会轮换。跨公司复现要求版本、字段集、salt、采集开关和实际采集值一致，详见 [算法规范](CrossCompanyIdentifierSpec.md)。

## 6. 远端解析

### 6.1 入口、请求合并与发起网络请求

入口：显式 `resolveRemoteIdentityWithCompletion:`，或异步本地加载后的自动刷新。

```mermaid
flowchart TD
    Start["Manager 排队执行远端解析"] --> Base["捕获 Context<br/>加载基础身份"]
    Base --> Storage{"有存储错误？"}
    Storage -->|是| ReturnError["主线程返回基础身份 + 错误"]
    Storage -->|否| Allowed{"已启用、Resolver 存在<br/>且满足用户同意条件？"}
    Allowed -->|否| ReturnError
    Allowed -->|是| Generation{"generation 仍有效？"}
    Generation -->|否| Cancel["主线程返回取消错误"]
    Generation -->|是| Inflight{"已有远端解析进行中？"}
    Inflight -->|是| Join["将 completion 加入等待数组<br/>共享同一次解析结果"]
    Inflight -->|否| Mark["标记进行中<br/>登记 completion"]
    Mark --> Validate{"Resolver 复核配置与同意条件<br/>是否通过？"}
    Validate -->|否| ResolverError["Resolver 生成错误结果"]
    Validate -->|是| Fresh{"有新鲜远端缓存？"}
    Fresh -->|是| Cached["直接返回缓存标识和解析时间"]
    Fresh -->|否| Prepare["校验 12 个必填属性<br/>解析 RSA 公钥并构造设备信息 JSON"]
    Prepare --> Encrypt["RSA PKCS#1 分段加密<br/>Base64 编码请求数据"]
    Encrypt --> Limit{"可登记今天的请求次数？"}
    Limit -->|否| ResolverError
    Limit -->|是| Request["NSURLSession POST<br/>dev_id + encrypted_device_info"]
    Prepare -. "字段或公钥错误" .-> ResolverError
    Encrypt -. "序列化或加密失败" .-> ResolverError
    Cached --> Result["进入 6.2 的 Resolver 回调与 Manager 合并流程"]
    ResolverError --> Result
    Request --> Response["网络响应进入 6.2 的响应解析流程"]
```

新鲜度默认 TTL 为 24 小时，请求上限默认每天 5 次，按设备本地日期计数。缓存和计数使用 `developerID + endpointURL` 派生的作用域。登记次数发生在网络请求前，网络失败也消耗已登记次数。

远端用户同意配置与 ATT 是两个独立条件。该请求使用 CAID 兼容设备信息字段，不包含 IDFA；SDK 默认关闭远端服务。

### 6.2 响应、持久化、合并与通知

```mermaid
flowchart TD
    Response["收到远端响应"] --> HTTP{"无网络错误、HTTP 2xx<br/>JSON 对象且 code=0？"}
    HTTP -->|否| Error["返回对应错误"]
    HTTP -->|是| Payload{"data 类型？"}
    Payload -->|数组 / 字典| Parse["解析版本化 ID"]
    Payload -->|Base64 字符串| Decrypt["RSA 公钥还原协议数据<br/>校验 Type 1 padding，解析 JSON"]
    Payload -->|其他| Error
    Decrypt --> Parse
    Decrypt -. "解码或解密失败" .-> Error
    Parse --> Valid{"存在有效 ID？"}
    Valid -->|否| Error
    Valid -->|是| Sort["版本字符串倒序排序<br/>最多保留 2 个"]
    Sort --> ResolverValid{"Resolver 仍有效？<br/>与 invalidate 使用同一把锁"}
    ResolverValid -->|否| Error
    ResolverValid -->|是| Persist["Store 持久化 identifiers + resolved_at"]
    Persist --> Callback["Resolver 在主线程返回结果"]
    Error --> Callback
    Callback --> Queue["Manager 切回工作队列"]
    Queue --> Generation{"请求 generation 仍有效？"}
    Generation -->|否| Discard["忽略旧结果<br/>配置 / 清理路径负责取消等待者"]
    Generation -->|是| Drain["清除进行中标记<br/>取出等待 completion"]
    Drain --> Base["取缓存身份，必要时重新加载"]
    Base --> RemoteIDs{"返回了远端 ID？"}
    RemoteIDs -->|否| Deliver["主线程交付当前身份 + 错误"]
    RemoteIDs -->|是| Merge["替换 remote 类标识<br/>保留共享 ID 与本地指纹"]
    Merge --> Commit["重查 generation 和广告授权<br/>存储无错误时更新内存缓存"]
    Commit --> Notify["主线程发送身份更新通知<br/>交付所有等待 completion"]
```

Manager 在重建、提交和主线程交付时也会复核 generation；期间版本变化时，已取出的等待回调仍会收到取消结果。配置更新、清理和成功注入会使旧 Resolver 失效并取消任务；失效与持久缓存写入互斥。清理在旧 Resolver 失效后删除缓存，再创建新的 Resolver，因此迟到响应无法重新填回旧数据。请求计数登记与任务发起也在失效锁内复核有效性。

## 7. 广告授权与广告请求输出

### 7.1 IDFA 采集及授权撤回

```mermaid
flowchart TD
    Start["设备属性采集"] --> Allows{"allowsAdvertisingIdentifier？"}
    Allows -->|否| Omit["不采集 IDFA"]
    Allows -->|是| Authorized{"当前广告授权有效？"}
    Authorized -->|否| Omit
    Authorized -->|是| Read["读取 AdSupport IDFA"]
    Read --> Valid{"跟踪未关闭且 UUID 非全零？"}
    Valid -->|否| Omit
    Valid -->|是| Keep["内存保留明文 IDFA<br/>attributes 保存 idfa_md5"]
    Keep --> Snapshot["身份快照"]
    Omit --> Snapshot
    Snapshot --> Access["读取 Manager 缓存 / 交付回调或通知"]
    Access --> Recheck{"仍获授权且配置允许采集？"}
    Recheck -->|是| Return["返回快照"]
    Recheck -->|否| Strip["复制快照并移除明文 IDFA 与 MD5"]
    Strip --> Return
```

iOS 14 及以上检查 ATT `authorized`；更早系统检查广告跟踪开关。框架不可用时按未授权处理。SDK 不主动弹出 ATT；授权请求由宿主处理。已交付给宿主的快照不可变，宿主须停止使用自己的旧快照；重新授权后需强制刷新才能重新采集。

### 7.2 广告适配与导出

```mermaid
flowchart TD
    Identity["PBCrossIdentity"] --> Adapter["PBCrossAdRequestAdapter"]
    Context["宿主 Context<br/>UA / IP / 网络类型 / 可选平台字段"] --> Adapter
    Adapter --> Device["deviceDictionary<br/>系统、机型、屏幕、运营商、时间字段"]
    Adapter --> Ext["extensionObject<br/>身份序列化为 pb_cross_app"]
    Adapter --> Tracking["trackingParameters<br/>当前 / 上一版本、shared、remote 等参数"]
    Device --> Auth{"导出时广告授权有效？"}
    Auth -->|否| NoIDFA["省略 idfa / idfa_md5"]
    Auth -->|是| Hash["存在 MD5 时输出 idfa_md5"]
    Hash --> Raw{"emitsRawAdvertisingIdentifier？"}
    Raw -->|否| DeviceDone["完成 Device 字段"]
    Raw -->|是| RawValue["输出 context 或 attributes 中的明文 IDFA"]
    RawValue --> DeviceDone
    NoIDFA --> DeviceDone
    Ext --> ExtAuth["导出时重查授权<br/>未授权则移除 attributes.idfa_md5"]
    ExtAuth --> JSON["序列化为 Device.ext JSON 字符串"]
    JSON --> DeviceDone
    DeviceDone --> Legacy["按开关附加 caid / caid_info"]
    Legacy --> Output["宿主合并到广告请求"]
    Tracking --> Monitor["宿主构造监测链接参数"]
```

Manager 工厂会获取当前身份并设置输出开关；手动创建适配器时使用调用方传入的快照。适配器会复制 Context，导出本身不发送网络请求。明文 IDFA 和旧版 CAID 字段默认均不输出。`deviceDictionary` 的 `ext` 为 JSON 字符串，`extensionObject` 为字典。

## 8. 归因匹配

入口：`matchIdentity:withIdentity:`。媒体回传的 `Device.ext` 可先通过 `identityWithAdRequestExtension:` 还原身份。

```mermaid
flowchart TD
    Input["本方身份 + 媒体身份"] --> Valid{"双方身份有效？"}
    Valid -->|否| None["未匹配<br/>confidence=0"]
    Valid -->|是| Shared{"双方 sharedID 非空且相同？"}
    Shared -->|是| SharedHit["shared_identifier<br/>confidence=1.0"]
    Shared -->|否| IDs{"任意标识值相同？"}
    IDs -->|是| IDHit["versioned_identifier<br/>confidence=1.0"]
    IDs -->|否| IDFA{"启用 IDFA 匹配<br/>且双方非空 MD5 相同？"}
    IDFA -->|是| IDFAHit["advertising_identifier<br/>confidence=0.99"]
    IDFA -->|否| Weights["合并默认和自定义属性权重"]
    Weights --> Compare["仅比较双方都有值且权重大于零的属性"]
    Compare --> Similarity["相似度 = 相等属性权重 / 可比较权重"]
    Similarity --> Threshold{"可比较权重至少 6.0<br/>且相似度至少 0.9？"}
    Threshold -->|是| AttrHit["device_attributes<br/>confidence=相似度"]
    Threshold -->|否| None
```

阈值和最小可比较权重可配置。共享 ID、版本标识和 IDFA MD5 的字符串比较均忽略大小写；版本标识匹配实际比较 `value`，不会额外要求 `version` 或 `kind` 相等。属性匹配会规范化部分数字字符串并输出逐字段比较结果。

匹配器消费传入快照，不在匹配时读取实时 ATT。图中 confidence 是当前代码返回的分值，不是经过统计校准的“同设备概率”。

## 9. 缓存重置、身份清理与服务端注入

### 9.1 重置内存缓存与清除持久身份

```mermaid
flowchart TD
    Start["宿主选择操作"] --> Kind{"调用哪个 API？"}
    Kind -->|resetIdentityCache| Reset["清空 cachedIdentity 和缓存时间"]
    Reset --> ResetDone["保留持久数据和 generation<br/>下次正常加载重新构建"]
    Kind -->|clearStoredIdentityWithError:| Invalidate["使旧 Resolver 失效并取消网络任务"]
    Invalidate --> Delete["尝试删除共享 / 服务端 Keychain ID<br/>记录删除错误，清除当前作用域镜像"]
    Delete --> Persistent["清除远端缓存、请求计数<br/>及系统更新时间历史"]
    Persistent --> Memory["清空内存身份<br/>清除远端进行中标记"]
    Memory --> Resolver["为当前配置创建新 Resolver"]
    Resolver --> Generation["generation 加一<br/>取出并清空等待回调"]
    Generation --> Cancel["安排主线程向等待者返回取消错误"]
    Cancel --> Result{"Keychain 删除均成功或无记录？"}
    Result -->|是| Done["返回 YES<br/>下次加载走共享 ID 创建流程"]
    Result -->|否| Failed["返回 NO + 删除错误<br/>页面展示未完成并允许重试"]
```

当前清理只移除当前 Keychain 命名空间内的 SDK 镜像、远端缓存、请求计数和系统更新时间历史。`resetIdentityCache` 不使在途任务失效；在途任务随后仍可能重新填充内存缓存。旧 `clearStoredIdentity` 保留兼容，但不返回删除错误；需要确认结果时使用 `clearStoredIdentityWithError:`。

### 9.2 显式注入服务端共享 ID

入口：`setServerIssuedSharedID:`。此接口与远端 Resolver 返回 `remote` 标识是两条独立路径。

```mermaid
flowchart TD
    Start["setServerIssuedSharedID:"] --> Empty{"传入 nil 或空串？"}
    Empty -->|是| Read["读取当前服务端 ID"]
    Read --> Copy["如有服务端 ID，先保存到共享 Key<br/>失败则保留服务端优先记录并返回 NO"]
    Copy --> Remove["删除服务端优先记录<br/>失败则返回 NO"]
    Remove --> MirrorPreserved["清除服务端镜像<br/>保留最后有效共享 ID"]
    MirrorPreserved --> Success["Store 返回 YES"]
    Empty -->|否| Validate["去首尾空白并校验 ID"]
    Validate --> Valid{"有效？"}
    Valid -->|否| Fail["返回 NO"]
    Valid -->|是| Server["单次覆盖写入服务端 Keychain 权威记录"]
    Server --> ServerOK{"写入成功？"}
    ServerOK -->|否| Fail
    ServerOK -->|是| Mirror["按命名空间更新 Defaults 镜像"]
    Mirror --> Success
    Success --> Reset["Manager 使旧 Resolver 失效<br/>清缓存、generation 加一、取消旧等待者"]
    Reset --> Done["返回 YES<br/>下次加载读取新持久化结果"]
```

注入非空值只写入服务端权威 Key，避免双写部分失败。传入空值会先把最后有效服务端 ID 保存在共享 Key，再移除优先记录，不主动轮换成随机 UUID；任一步骤失败都会返回 NO，服务端优先记录保留。成功变更会增加 generation，使旧加载结果失效。

## 10. 当前实现边界

本轮 P2 已按以下规则修复，使用时仍需理解接口范围。

| 关联流程 | 当前行为与边界 |
| --- | --- |
| 镜像与升级 | Keychain 是身份依据，旧 Defaults 不再自动恢复到 Keychain；仅存于旧镜像的 ID 不会继续沿用。 |
| 命名空间 | Defaults 使用 service/accessGroup 派生的前缀；其他命名空间的身份和镜像不受当前清理影响。旧无命名空间记录被忽略。 |
| 服务端注入 | 单条权威 Key 写入；成功后取消旧任务和等待者。空值用于移除优先标记，失败保持最后有效身份。 |
| 远端失效 | 同一 Manager 内，清理/配置/注入与旧 Resolver 的持久缓存提交互斥；不提供跨进程网络任务取消。 |
| 清理结果 | 新增带错误接口；删除失败可能已完成部分清理，应处理错误后重试。旧无错误接口仅作兼容。 |
| 其他 App | 清理共享记录影响后续持久化读取；不会主动清除其他进程已持有的内存身份快照，宿主须刷新。 |

## 11. 线程与源码索引

| 阶段 | 当前线程行为 |
| --- | --- |
| 配置、清理、服务端注入 | 在调用线程执行，关键状态由锁保护。 |
| 异步加载与 Manager 远端调度 | Manager 的串行 `workQueue`。 |
| 同步加载 | 主线程或 Manager 工作队列中直接执行；其他线程同步派发到工作队列。 |
| UIKit 属性读取 | 采集器同步切换到主线程。 |
| 运营商读取 | 独立串行队列，采集器最多等待 0.5 秒。 |
| 网络响应解析与持久缓存 | NSURLSession 回调线程；Resolver 再将结果派发到主线程。 |
| 远端身份合并 | Manager 将 Resolver 结果重新派发到 `workQueue`。 |
| 异步 completion / 身份更新通知 | 主线程，交付前复核版本与广告授权。 |
| 广告导出 / 匹配 | 调用线程执行，不自行发起网络请求。 |

| 功能 | 主要源码 |
| --- | --- |
| 入口、配置、缓存、generation、远端结果合并 | [PBCrossAppUniqueDeviceIdentifierManager.m](../Sources/Implementation/PBCrossAppUniqueDeviceIdentifierManager.m) |
| 配置校验与默认参数 | [PBCrossConfiguration.m](../Sources/Implementation/PBCrossConfiguration.m) |
| Keychain、Defaults、远端缓存与计数 | [PBCrossIdentityStore.m](../Sources/Implementation/PBCrossIdentityStore.m) |
| 属性采集 | [PBCrossDeviceAttributeCollector.m](../Sources/Implementation/PBCrossDeviceAttributeCollector.m) |
| 指纹计算 | [PBCrossIdentityGenerator.m](../Sources/Implementation/PBCrossIdentityGenerator.m) |
| 广告授权检查 | [PBCrossAdvertisingAuthorization.m](../Sources/Implementation/PBCrossAdvertisingAuthorization.m) |
| 远端协议 | [PBCrossRemoteResolver.m](../Sources/Implementation/PBCrossRemoteResolver.m) |
| RSA 协议处理 | [PBCrossRSACrypto.m](../Sources/Implementation/PBCrossRSACrypto.m) |
| 广告 Device、ext、监测参数 | [PBCrossAdRequestAdapter.m](../Sources/Implementation/PBCrossAdRequestAdapter.m) |
| 身份选择与序列化 | [PBCrossIdentity.m](../Sources/Implementation/PBCrossIdentity.m) |
| 归因匹配 | [PBCrossIdentityMatcher.m](../Sources/Implementation/PBCrossIdentityMatcher.m) |
