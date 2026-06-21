---
title: "OC/Swift 环境搭建指南"
date: 2019-05-20T19:14:49+08:00
draft: false
---

[TOC]

## 1. 查看当前 Ruby 版本

`ruby --version`

macOS 系统默认自带 ruby，无需安装。

## 2. 如果 Ruby 版本过低，可以使用 Homebrew 安装最新版 Ruby

`brew install ruby`

在环境变量中配置优先使用 Homebrew 安装的 ruby

```
# 优先使用 brew 安装的 ruby，如果未使用 brew 安装 ruby，则使用 macOS 默认自带的 ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
```

## 3. 查看当前 Ruby 镜像源

`sudo gem sources -l`

## 4. 更换 Ruby 镜像源

`sudo gem sources -l`

`sudo gem sources --remove https://rubygems.org/`

`sudo gem sources -a https://mirrors.tuna.tsinghua.edu.cn/rubygems/`

## 5. 安装最新版 CocoaPods

`sudo gem install cocoapods`  
`sudo gem install -n /usr/local/bin cocoapods`

查看 CocoaPods 版本号

`pod --version`

## 6. 卸载 CocoaPods

`sudo gem uninstall cocoapods`

## 7. Podfile 缓存路径

```
// 是什么： Pod 的规格说明书（Ruby 格式），告诉 CocoaPods 这个库叫什么、从哪下载、有哪些依赖、怎么集成。
/Users/zhushanbo/.cocoapods/repos/gitcode-shanbozhu-pbaspec/PBHomeSDK/1.0.2-SNAPSHOT/PBHomeSDK.podspec

// 是什么： 上面那份 .podspec 被 CocoaPods 解析后缓存的 JSON 快照，方便下次直接用，不用重复解析 Ruby。
/Users/zhushanbo/Library/Caches/CocoaPods/Pods/Specs/Release/PBHomeSDK/1.0.2-SNAPSHOT-bf849.podspec.json

// 是什么： 根据 podspec 里 s.source 从 Git 仓库下载并解压后的实际产物，也就是 SDK 本体。
/Users/zhushanbo/Library/Caches/CocoaPods/Pods/Release/PBHomeSDK/1.0.2-SNAPSHOT-bf849/PBHomeSDK.framework
```

## 8. Podfile 里的库版本配置

```
# 取最新版本
pod 'MJRefresh',
# 取 3.1.12
pod 'MJRefresh', '3.1.12'
# [3.1.12, 3.2.0)
pod 'MJRefresh', '~>3.1.12'

# [3.1.12, ...)
pod 'MJRefresh', '>=3.1.12'
# (3.1.12, ...)
pod 'MJRefresh', '>3.1.12'
# [0.0.0, 3.1.12]
pod 'MJRefresh', '<=3.1.12'
# [0.0.0, 3.1.12)
pod 'MJRefresh', '<3.1.12'
```

## 9. 执行 pod install 命令安装依赖库

```
# 安装依赖库
pod install
# 更新依赖库
pod update

# 查看本地仓库列表
pod repo list
```

## 10. 常见问题

### 10.1 Mac 执行 pod install 命令出现错误 Couldn't determine repo type for URL

在 Mac 系统执行命令 pod install 时出现如下错误

Analyzing dependencies  
[!] Couldn't determine repo type for URL: `https://github.com/CocoaPods/Specs.git`: SSL_connect returned=1 errno=0 peeraddr=20.205.243.166:443 state=error: certificate verify failed (unable to get local issuer certificate)

执行如下 2 条命令解决问题

`export SSL_CERT_FILE=/etc/ssl/cert.pem`  
`pod repo update`

参考文档：[https://www.cnblogs.com/cadstudy/p/19607907](https://www.cnblogs.com/cadstudy/p/19607907)
