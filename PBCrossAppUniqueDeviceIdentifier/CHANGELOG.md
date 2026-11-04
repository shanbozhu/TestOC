# Changelog

## Unreleased

- 未配置 Access Group 时先解析系统默认组，所有 Keychain 操作均显式限定该组，避免清理或写入影响其他可访问共享组。
- 空值服务端注入改为原子更新同一记录的优先元数据，保留并发注入的新 ID；非空注入同步恢复服务端来源。
- App Group 可用时只读取共享 Defaults，缺项不再回退到私有副本，避免清理后的旧远端缓存复活。
- 每日请求额度改用 Keychain 原子占位，同命名空间跨 App 共享；存储失败透传错误，清理同时删除占位。升级当天从新额度开始，忽略旧 Defaults 计数；混用旧版 SDK 不参与新额度协调。
- 新增默认组解析故障、并发移除优先标记、共享缓存清理、跨 Store 额度竞争/重启/清理/日期回收的隔离回归。
- Defaults 镜像按 Keychain service/accessGroup 隔离；缺少 Keychain 记录时不再从旧镜像恢复身份，避免其他 App 将已清除 ID 写回。
- 服务端共享 ID 改为单条权威记录写入；成功注入使旧加载与远端请求失效，移除优先标记时保留最后有效 ID 并报告失败。
- 清理/重新配置使旧 Resolver 失效并取消请求；缓存提交与失效互斥，迟到响应不再恢复已删除远端缓存。
- 新增 `clearStoredIdentityWithError:`，页面展示真实 Keychain 删除错误并允许重试；保留原无错误返回的兼容接口。
- 扩充隔离存储回归，覆盖镜像复活、命名空间、注入竞争、写入/删除故障与迟到响应。
- 修复 ATT 撤回后继续输出缓存 IDFA 的问题；缓存、回调及已有广告适配器导出前重新检查授权。
- 加载绑定同一配置、存储与配置版本；旧配置结果不再污染新缓存，异步加载返回取消错误，同步加载按新配置重试。
- 配置 App Group 时强制要求共享 Keychain Access Group，拒绝仅 App Group 配置并保留原配置，避免两个 App 分别创建私有身份。
- 修复 Keychain 读取错误被当作无记录、导致临时生成其他共享 ID 的问题；存储错误返回给加载回调，恢复后重试。
- 修复多个 App 并发首次创建共享 ID 时相互覆盖的问题；使用 `SecItemAdd`，重复时读取已持久化的胜出值。
- 新增 `Tools/verify_storage.sh`，覆盖读取/写入失败、损坏记录、并发创建与缓存恢复。

## 1.0.0 — 2026-10-27

首个版本。

### Added

- `pb-xid-v1` 跨 App/跨公司设备指纹：
  - 当前版本 `20261001`：启动时间、设备名 MD5、设备初始化时间、系统更新时间、machine、model、disk、memory、screenResolution、processorCount、mntId；
  - CAID 兼容版本 `20260301`：CAID API v1.15 5.1 节 14 字段；
  - 32 位小写十六进制输出，HMAC-SHA256 + salt，多版本任一命中。
- Keychain Access Group / App Group 共享自建 UUID；服务端下发共享 ID。
- CAID API v1.15 兼容的远端 ID 服务客户端：
  - RSA 公钥证书/PKCS#1/SPKI 解析，PKCS#1 分段加密，Raw 公钥解密与 padding 去除；
  - 24 小时缓存、每设备每天 5 次限流、隐私同意开关。
- 拼多多 Bid Request Device 适配器：
  - `birth_time` / `boot_time` / `update_time` / `last_update_time`、`idfa_md5`、运营商/屏幕/机型等；
  - `ext.pb_cross_app` 身份快照；可选旧版 `caid` / `caid_info`；
  - 点击/曝光监测 URL 参数。
- 跨公司归因匹配器：共享 ID、版本 ID、IDFA MD5、属性加权相似度。
- 设备属性采集：CAID 14 字段 + 屏幕、CPU、IDFV、IDFA（可选）、MCC/MNC、时区标识等扩展字段。
- `clearStoredIdentity`、`resetIdentityCache`、配置校验、日志开关。
- 跨公司算法规范、README、逻辑自检脚本与测试向量。
