---
title: "OC/Swift 环境搭建指南"
date: 2019-05-20T19:14:49+08:00
draft: false
---

[TOC]

## 1、查看当前 Ruby 版本

`ruby --version`

macOS 系统默认自带 ruby，无需安装。

## 2、如果 Ruby 版本过低，可以使用 Homebrew 安装最新版 Ruby

`brew install ruby`

在环境变量中配置优先使用 Homebrew 安装的 ruby

```
# 优先使用 brew 安装的 ruby，如果未使用 brew 安装 ruby，则使用 macOS 默认自带的 ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
```

## 3、查看当前 Ruby 镜像源

`sudo gem sources -l`

## 4、更换 Ruby 镜像源

`sudo gem sources -l`

`sudo gem sources --remove https://rubygems.org/`

`sudo gem sources -a https://mirrors.aliyun.com/rubygems/`

## 5、安装最新版 CocoaPods

`sudo gem install cocoapods`

查看 CocoaPods 版本号

`pod --version`

## 6、卸载 CocoaPods

`sudo gem uninstall cocoapods`

## 7、Podfile 配置

```ruby
#source 'https://github.com/CocoaPods/Specs.git'

# 因为墙的原因，替换为国内 Specs 镜像源
source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

#ali_source 'alibaba-specs' # 集团内部仓库
#ali_source 'alibaba-specs-mirror' # 官方镜像仓库

platform :ios, '8.0'

target "TestOC" do
  pod 'YYText', '1.0.7'
  pod 'YYModel', '1.0.4'
  pod 'YYImage', '1.0.4'
  pod 'YYWebImage', '1.0.5'
  pod 'YYCache', '1.0.4'
  
  pod 'AFNetworking', '~> 2.6.3'
  #pod 'AFNetworking', '2.6.3'
  #pod 'AFNetworking', '~> 3.0'
  
  pod 'SocketRocket', '0.5.1'
  
  pod 'SDWebImage', '5.9.5'
  pod 'SDWebImageFLPlugin', '0.4.0'
  pod 'SDWebImageLottiePlugin', '0.2.0'
  
  pod 'Masonry', '~> 1.1.0'
  pod 'FMDB', '~> 2.7.5'
  pod 'MJRefresh', '3.5.0'
  pod 'CocoaLumberjack', '3.6.2'
  pod 'HMSegmentedControl', '1.5.6'
  pod 'SDCycleScrollView', '1.82'
  
  # swift框架
  pod 'SnapKit', '4.2.0'
end
```

## 8、Podfile 里的库版本配置

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

## 9、执行 pod install 命令安装依赖库

```
# 安装依赖库
pod install
# 更新依赖库
pod update

# 查看本地仓库列表
pod repo list
```

## 10、常见问题

### 10.1 Mac 执行 pod install 命令出现错误 Couldn't determine repo type for URL

在 Mac 系统执行命令 pod install 时出现如下错误

Analyzing dependencies  
[!] Couldn't determine repo type for URL: `https://github.com/CocoaPods/Specs.git`: SSL_connect returned=1 errno=0 peeraddr=20.205.243.166:443 state=error: certificate verify failed (unable to get local issuer certificate)

执行如下 2 条命令解决问题

`export SSL_CERT_FILE=/etc/ssl/cert.pem`  
`pod repo update`

参考文档：[https://www.cnblogs.com/cadstudy/p/19607907](https://www.cnblogs.com/cadstudy/p/19607907)
