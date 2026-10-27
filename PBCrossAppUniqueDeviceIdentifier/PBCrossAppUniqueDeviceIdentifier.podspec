Pod::Spec.new do |s|
  s.name             = 'PBCrossAppUniqueDeviceIdentifier'
  s.version          = '1.0.0'
  s.summary          = '跨 App、跨公司的 iOS 统一设备标识（自建 ID + 设备属性指纹）。'
  s.description      = <<-DESC
                        为不同媒体、不同开发者的 App 提供同一设备的识别能力：
                        共享 Keychain/App Group 自建 ID、按版本拼接设备属性生成跨公司一致指纹，
                        并可对接自建 ID 服务；内置广告请求适配与归因匹配器。
                       DESC
  s.homepage         = 'https://gitcode.com/shanbozhu/PBCrossAppUniqueDeviceIdentifier'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Shanbo Zhu' => 'shanbozhu@users.noreply.gitcode.com' }
  s.source           = { :git => 'https://gitcode.com/shanbozhu/PBCrossAppUniqueDeviceIdentifier.git',
                         :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.platform         = :ios, '12.0'
  s.requires_arc     = true

  s.source_files          = 'Sources/**/*.{h,m}'
  s.public_header_files   = 'Sources/PBCrossAppUniqueDeviceIdentifier.h', 'Sources/Public/*.h'
  s.private_header_files  = 'Sources/Private/*.h'

  s.frameworks = 'Foundation', 'UIKit', 'Security', 'CoreTelephony'

  s.pod_target_xcconfig = {
    'CLANG_WARN_DOCUMENTATION_COMMENTS' => 'NO',
  }
end
