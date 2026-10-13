#
# shoplive_core - Flutter bridge for Shoplive iOS SDK 3.0.2 (DRAFT-flutter-sdk-302-ios design section 4).
# The SDK XCFrameworks are downloaded from the GitHub release at pod install, verified by sha256
# (SDK Package.swift constants) and vendored. Keep this file ASCII-only (pod install may run without a UTF-8 locale).
#
require 'yaml'
load File.join(__dir__, 'shoplive_ios_sdk.rb')

# YAML.safe_load(File.read(...)) instead of safe_load_file: works on the macOS system Ruby 2.6 (Psych 3.1).
pubspec = YAML.safe_load(File.read(File.join(__dir__, '..', 'pubspec.yaml')))

# Shoplive iOS SDK version - must be identical in the three Shoplive podspecs (checked by a test, I-D-05).
shoplive_ios_sdk_version = '3.0.2'
# XCFrameworks owned by this pod and their sha256 (https://github.com/shoplive/shoplive-sdk-ios/blob/3.0.2/Package.swift)
shoplive_ios_sdk_artifacts = {
  'ShopliveCore' => '0ead2c64147fc195dc647b93ac1c5da71c37b4e0bc98e40604b9dc0ada63f81c',
  'ShopLiveWebRTCHelperSDK' => '66238f7dcb0ffe7bc0eb8cd2bbdf617302d9f0585f41e543a5409daf49cd293f',
  'WebRTC' => '2e089365df502588e6fc8720ce09ca910d00011a7bdf6676f97c495d266f81ef',
}

ShopliveIosSdk.ensure!(pod_dir: __dir__, version: shoplive_ios_sdk_version, artifacts: shoplive_ios_sdk_artifacts)

Pod::Spec.new do |s|
  s.name             = 'shoplive_core'
  s.version          = pubspec['version']
  s.summary          = 'Shoplive core plugin for Flutter (initialize, user, conversion).'
  s.description      = 'Shoplive core plugin for Flutter (initialize, user, conversion). Built on Shoplive iOS SDK ' + shoplive_ios_sdk_version + '.'
  s.homepage         = 'https://github.com/shoplive/flutter-sdk-sample/tree/main/shoplive_core'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Shoplive' => 'ask@shoplive.cloud' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.vendored_frameworks = shoplive_ios_sdk_artifacts.keys.map { |name| "Frameworks/#{name}.xcframework" }
  s.platform         = :ios, '15.0'
  s.swift_version    = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
