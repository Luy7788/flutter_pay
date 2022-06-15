#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_pay.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_pay'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter Pay plugin.'
  s.description      = <<-DESC
A new Flutter Pay plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.dependency 'WechatOpenSDK', '~> 1.8.7.1'
  s.static_framework = true
#  s.frameworks  = "Foundation", 'StoreKit'
  s.frameworks = ["Foundation", "SystemConfiguration", "CoreTelephony"]
  s.libraries = ["z", "sqlite3.0", "c++"]
  s.pod_target_xcconfig = {
#    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
#    'OTHER_LDFLAGS' => '$(inherited) -ObjC -all_load',
#    'OTHER_SWIFT_FLAGS' => '-Xcc -Wno-error=non-modular-include-in-framework-module'
  }
end
