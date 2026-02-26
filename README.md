---
title: "OC/Swift 环境搭建指南"
date: 2019-05-20T19:14:49+08:00
draft: false
---

[TOC]

## 1. 查看当前 Ruby 镜像源

`sudo gem sources -l`

## 2. 更换 Ruby 镜像源

`sudo gem sources -l`

`sudo gem sources --remove https://rubygems.org/`

`sudo gem sources -a https://mirrors.aliyun.com/rubygems/`

## 3. 安装最新版 CocoaPods

`sudo gem install -n /usr/local/bin cocoapods --pre`

查看 CocoaPods 版本号

`pod --version`

若是安装指定版本 CocoaPods，使用下面命令

`sudo gem install -n /usr/local/bin cocoapods -v 1.2.0`

## 4. 卸载 CocoaPods

`sudo gem uninstall cocoapods`

## 5. 使用 CocoaPods 管理库

```
# 取最新版本
pod 'MJRefresh',
# 取3.1.12
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

## 6. 安装 CocoaPods 时的输出日志

```
-> ~ 10:35:00
 $ sudo gem install -n /usr/local/bin cocoapods --pre
Fetching ffi-1.17.0-x86_64-darwin.gem
Successfully installed ffi-1.17.0-x86_64-darwin
Successfully installed cocoapods-core-1.16.2
Successfully installed cocoapods-1.16.2
Parsing documentation for ffi-1.17.0-x86_64-darwin
Installing ri documentation for ffi-1.17.0-x86_64-darwin
Parsing documentation for cocoapods-core-1.16.2
Installing ri documentation for cocoapods-core-1.16.2
Parsing documentation for cocoapods-1.16.2
Installing ri documentation for cocoapods-1.16.2
Done installing documentation for ffi, cocoapods-core, cocoapods after 2 seconds
3 gems installed
-> ~ 10:44:55
```
