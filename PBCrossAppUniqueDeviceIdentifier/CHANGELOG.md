# Changelog

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
