### 1. 查看当前Ruby镜像源

`sudo gem sources -l`

### 2. 更换Ruby镜像源

`sudo gem sources -l`

`sudo gem sources --remove https://rubygems.org/`

`sudo gem sources -a https://gems.ruby-china.com/`

### 3. 安装最新版CocoaPods

`sudo gem install -n /usr/local/bin cocoapods --pre`

查看CocoaPods版本号

`pod --version`

若是安装指定版本CocoaPods，使用下面命令

`sudo gem install -n /usr/local/bin cocoapods -v 1.2.0`

### 4. 卸载CocoaPods

`sudo gem uninstall cocoapods`

### 5. 使用CocoaPods管理库

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

---
