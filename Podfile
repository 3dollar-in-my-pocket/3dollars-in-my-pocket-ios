# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target '3dollar-in-my-pocket' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for 3dollar-in-my-pocket
  pod 'Google-Mobile-Ads-SDK'
  pod 'NMapsMap'
  pod 'SwiftLint'

  target '3dollar-in-my-pocketTests' do
    inherit! :search_paths
    pod 'RxTest', '~> 5'
    pod 'RxNimble/RxTest'
  end
end

# M1에서 시뮬레이터 빌드를 하기위해 추가했습니다.
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    config.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
    config.build_settings["DEVELOPMENT_TEAM"] = "X975A2HM62"
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  end
end
