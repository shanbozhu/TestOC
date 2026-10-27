# 设备持久标识 Demo

本目录在 TestOC 内实现应用范围的持久身份：Keychain 随机 UUID、安装 ID、IDFV，以及按授权状态获取的 IDFA。该模块仅依赖系统框架，不依赖 Menta 项目或广告 SDK；仅在本机展示及手动复制 JSON，不发送网络请求，也不使用设备属性生成指纹。

## 运行入口

打开 TestOC 项目的 `TestOC.xcworkspace`，选择 `TestOC` scheme 运行，在“我的”列表中进入 `PBUniqueDeviceIdentifierController`。

本目录没有额外的 App target、启动入口或独立工程。标识使用 TestOC 的 bundle ID 作为应用命名空间，原有 `PBUniqueIdentifier` 对比页面不受影响。TestOC 整体运行仍需其已有 Pods 依赖正常安装。

## 文件职责

| 文件 | 职责 |
| --- | --- |
| `PBDeviceIdentityStorage` | Keychain 存取、排除备份的安装文件、损坏和失败处理 |
| `PBDeviceIdentityManager` | 串行持久化、系统标识和 ATT 状态、不可变快照 |
| `PBUniqueDeviceIdentifierController` | 查看、复制、并发验证、模拟重装及重置 |

## 核心调用

```objc
#import "PBDeviceIdentityManager.h"

[PBDeviceIdentityManager.sharedManager refreshWithCompletion:^(PBDeviceIdentitySnapshot *snapshot) {
    // 主线程回调。payload 为 JSON 示例；diagnostics 仅供本地排错。
    NSDictionary *payload = snapshot.payload;
}];
```

页面出现、App 返回前台及受保护数据恢复可用时重新读取。`refresh` 不主动请求 ATT。只有点击“请求 ATT 授权”才弹系统授权框；宿主必须配置 `NSUserTrackingUsageDescription`。已拒绝的授权需由用户在系统设置中修改。

## 身份合同

| 字段 | 范围和生命周期 |
| --- | --- |
| `identity_version` | 当前方案版本为 1 |
| `identity_scope` | 固定为 `app` |
| `app_bundle` | 宿主 bundle ID；生产环境还需后端确认 tenant 和 environment |
| `app_device_id` | 随机 UUID，Keychain service 为 `<bundle_id>.pb.identity.v1`，account 为 `app_device_id` |
| `installation_id` | Application Support 下的 `PBUniqueDeviceIdentifier/installation_id.txt`，文件及目录排除备份 |
| `idfv` | 系统 vendor 范围值，每次刷新重读；暂不可用时省略，下次重试 |
| `att_status` | `not_determined`、`restricted`、`denied`、`authorized`；iOS 14 以下为 `not_required` |
| `idfa` | iOS 14+ 仅 ATT authorized 时读取并提供；较早系统需允许广告跟踪；全零及无效值省略 |
| `identity_status` | 两个本地持久标识均可用为 `available`，仅一个可用为 `partial`，均不可用为 `unavailable` |
| `app_device_id_status` / `installation_id_status` | 标识各自的 `available`、`temporarily_unavailable` 或 `unavailable` 状态 |

关键实现约束：

- Keychain 使用 `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`，不启用 iCloud 同步，不指定共享 access group；首次解锁前可能不可用。
- 仅在 `errSecItemNotFound` 时创建 UUID。锁定、权限错误和记录损坏均不会触发替换；写入失败也不返回尚未保存的候选值。
- 并发首次读取由共享 manager 的串行队列控制。Keychain 创建遇到 `errSecDuplicateItem`，重新读取胜出的记录。
- 安装文件只在确实不存在时创建；读写错误和损坏不会静默创建另一个身份。该存储仅用于当前 App 进程；扩展进程共享身份需要另行设计跨进程锁和受控共享容器。
- 不缓存 IDFA/IDFV 为永久身份。授权撤回后新快照不再提供 IDFA；业务也须停止相关使用及缓存处理。
- 不同 App 不通过型号、文件时间、IP 等推断为同一设备。Keychain ID 和 IDFV 不能作为拒绝 ATT 后的跨公司广告追踪替代品。
- `subject_id` 由后端分配，本 Demo 没有实现或伪造后端服务。建议内部主键独立于广告 ID；相同账号也不等于相同设备。

## 可操作的验证

| 操作 | 预期 |
| --- | --- |
| 刷新、50 次并发读取 | 两个本地标识各只有一个值 |
| 结束 App 后重新启动 | 两个本地标识均保持 |
| 升级 App、重启系统 | 正常情况下本地标识保持，受保护数据恢复后可重试 |
| 模拟重装 | 只删除本模块安装文件，安装 ID 改变，Keychain ID 保持 |
| 重置 Demo 身份 | 确认后删除本模块两个标识；新值与旧值不同，IDFV/IDFA 不被重置 |
| ATT 授权后再撤回 | 新快照中移除 IDFA |
| 真机删除后重装 | 安装 ID 应重建；Keychain 项可能保留，不能承诺必定保留 |
| 从其他设备备份恢复 | ThisDeviceOnly 的 Keychain 项不迁移，安装文件排除备份；应创建新身份，需真机验证 |

“模拟重装”只模拟安装文件丢失，不能替代真实删除重装、锁屏、抹机及换机验证。标识仅代表应用身份，不承诺永久识别物理设备。重置失败可能已部分生效，页面会报告错误，后续应刷新核对。

## TestOC 验证说明

本模块已加入 TestOC 的 Sources 编译阶段，“我的”菜单使用类名进入页面；页面内可执行 50 次并发读取、模拟重装和身份重置。

运行时保留正常签名。无签名进程可能得到 Keychain `-34018`，此时页面显示不可用和本地错误，不会创建替代身份。

重装、锁屏、跨设备恢复以及真实 ATT 允许/拒绝流程需使用真机按上表验证。服务端身份映射不在本模块实现范围内。
