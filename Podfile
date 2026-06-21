# 私有仓库地址
source 'https://gitcode.com/shanbozhu/PBASpec.git'
# 公共仓库地址
source 'https://github.com/CocoaPods/Specs.git'

# 因为墙的原因，替换为国内「公共仓库」镜像源
#source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

use_frameworks! # 将 Pod 引入的源码编译成 framework，默认为动态库
platform :ios, '12.0'

target "TestOC" do
  # menta 海外版
  pod 'MentaMediationGlobal',      '1.0.27'
  pod 'MentaVlionGlobalAdapter',   '1.0.27'
  pod 'MentaVlionGlobal',          '1.0.27'
  pod 'MentaBaseGlobal',           '1.0.27'
  
  # menta 国内版
  pod 'MentaUnifiedSDK',        '7.00.22'
  pod 'MentaVlionAdapter',      '7.00.22'
  pod 'MentaVlionSDK',          '7.00.22'
  pod 'MentaVlionBaseSDK',      '7.00.22'
  
  ##################################
  
  # 测试
  pod 'PBHome', '1.0.2-SNAPSHOT' # 动态库，带资源
  pod 'PBMine', '1.0.2-SNAPSHOT' # 静态库，带资源
  pod 'PBNavigator', '1.0.2-SNAPSHOT' # 动态库，不带资源

  ##################################
  
  pod 'YYText', '1.0.7'
  pod 'YYModel', '1.0.4'
  pod 'YYImage', '1.0.4'
  pod 'YYWebImage', '1.0.5'
  pod 'YYCache', '1.0.4'
  
  pod 'AFNetworking', '~> 2.6.3'
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

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end

  # Xcode 26+ treats chained comparison (a < b < c) as a hard error in YYText.
  yytext_layout_file = File.join(installer.sandbox.root, 'YYText/YYText/Component/YYTextLayout.m')
  if File.exist?(yytext_layout_file)
    content = File.read(yytext_layout_file)
    new_content = content
      .gsub(
        'position = fabs(left - point.y) < fabs(right - point.y) < (right ? prev : next);',
        'position = (fabs(left - point.y) < fabs(right - point.y)) ? prev : next;'
      )
      .gsub(
        'position = fabs(left - point.x) < fabs(right - point.x) < (right ? prev : next);',
        'position = (fabs(left - point.x) < fabs(right - point.x)) ? prev : next;'
      )
    if new_content != content
      File.chmod(0644, yytext_layout_file)
      File.write(yytext_layout_file, new_content)
      puts "[Podfile] Fixed chained comparison in #{yytext_layout_file}"
    end
  end

  # Xcode 26+ marks netinet6/in6.h as a private header; netinet/in.h is sufficient.
  pods_root = installer.sandbox.root.to_s
  Dir.glob(File.join(pods_root, '**/*.{m,mm}')).each do |file|
    content = File.read(file)
    next unless content.include?('#import <netinet6/in6.h>')

    new_content = content.gsub("#import <netinet6/in6.h>\n", '')
    next if new_content == content

    File.chmod(0644, file)
    File.write(file, new_content)
    puts "[Podfile] Removed private netinet6/in6.h import from #{file}"
  end
end
