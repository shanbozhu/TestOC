# 私有仓库
source 'https://gitcode.com/shanbozhu/PBASpec.git'
# 公共仓库（trunk）
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks! # 将 Pod 引入的源码编译成 framework，默认为动态库
platform :ios, '12.0'

target "TestOC" do
  # menta 国内版
  pod 'MentaUnifiedSDK',        '7.00.22'
  pod 'MentaVlionAdapter',      '7.00.22'
  pod 'MentaVlionSDK',          '7.00.22'
  pod 'MentaVlionBaseSDK',      '7.00.22'
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
