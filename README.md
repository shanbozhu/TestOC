#TestBundle

/*****************Git相关*****************/<br>
//git添加忽略文件<br>
1.git rm --cached UserInterfaceState.xcuserstate<br>
2.编辑.gitignore文件<br>
3.git commit -m "忽略跟踪指定的文件"<br>

//git解决rebase冲突<br>
1.git statue<br>
2.git add -u<br>
3.git rebase --continue<br>
4.git push -f<br>

/*****************CocoaPods相关*****************/<br>
//安装CocoaPods<br>
1.更换Ruby镜像源<br>
(1).gem sources --remove https://rubygems.org/<br>
(2).gem sources -a https://gems.ruby-china.org/<br>
2.查看当前镜像源<br>
(1).gem sources -l<br>
3.安装或更新CocoaPods<br>
(1).sudo gem install -n /usr/local/bin cocoapods --pre<br>

//使用CocoaPods导入三方框架,以AFNetworking为例<br>
1.搜索AFNetworking框架<br>
(1).pod search AFNetworking<br>
2.进入项目根目录<br>
(1).touch podfile<br>
(2).open podfile<br>
3.输入如下内容,注意下面为英文单引号<br>
target 'TestBundle' do<br>
pod 'AFNetworking', '~> 3.1.0'<br>
end<br>
4.导入三方框架<br>
(1).pod install<br>

//下面是简单的版本选择:<br>
//取最新版本<br>
pod 'MJRefresh',<br>
//取3.1.12<br>
pod 'MJRefresh', ‘3.1.12'<br>
//[3.1.12 ...]<br>
pod 'MJRefresh', ‘>=3.1.12'<br>
//(3.1.12 ...]<br>
pod 'MJRefresh', ‘>3.1.12'<br>
//[0.0.0 3.1.12]<br>
pod 'MJRefresh', ‘<=3.1.12'<br>
//[0.0.0 3.1.12)<br>
pod 'MJRefresh', ‘<3.1.12'<br>
//[3.1.12 3.2.0)<br>
pod 'MJRefresh', ‘~>3.1.12'<br>
