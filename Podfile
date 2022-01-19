# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target '3dollar-in-my-pocket' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for 3dollar-in-my-pocket

  pod 'SnapKit', '~> 5.0.0'

  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'RxDataSources', '~> 4.0'
  pod 'ReactorKit'

  pod 'Kingfisher', '~> 5.0'

  pod 'Then'
  
  pod 'Alamofire', '~> 5.2'
  
  pod 'lottie-ios'
  
  pod 'KakaoSDKCommon'  # 필수 요소를 담은 공통 모듈
  pod 'KakaoSDKLink'  # 메시지(카카오링크)
  pod 'KakaoSDKTemplate'  # 메시지 템플릿
  pod 'RxKakaoSDKAuth'
  pod 'RxKakaoSDKUser'
  
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Messaging'
  
  pod 'Google-Mobile-Ads-SDK'
  
  pod 'NMapsMap'
  
  pod 'SwiftyBeaver'
  
  pod 'DeviceKit', '~> 4.0'
  
  pod 'SPPermissions/Camera'
  pod 'SPPermissions/Location'
  pod 'SPPermissions/PhotoLibrary'
  
  pod 'SwiftLint'
  pod 'R.swift'

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
  end
end
