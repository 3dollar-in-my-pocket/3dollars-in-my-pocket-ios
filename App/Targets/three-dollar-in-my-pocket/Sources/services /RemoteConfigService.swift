import FirebaseRemoteConfig
import Firebase
import UIKit
import AppInterface

public final class RemoteConfigService: RemoteConfigProtocol {
    public static let shared = RemoteConfigService()
    
    private var remoteConfig: RemoteConfig?
    private var _experimentContext: String = ""
    private var isConfigured = false
    private var notificationSetup = false
    
    // MARK: - Public Properties
    public var experimentContext: String {
        return _experimentContext
    }
    
    private init() {
        // 초기화 시점에는 아무것도 하지 않음 - 완전 lazy 초기화
        print("🟡 RemoteConfigManager init() called - no Firebase calls yet")
    }
    
    private func setupNotificationsOnce() {
        guard !notificationSetup else { return }
        
        // 백그라운드→포그라운드 전환 시에만 업데이트
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        notificationSetup = true
        print("🟡 Notifications setup completed")
    }
    
    private func initializeRemoteConfigIfNeeded() {
        guard remoteConfig == nil else { return }
        
        print("🟡 Attempting to initialize RemoteConfig...")
        
        // Firebase 초기화 확인을 다른 방식으로 시도
        do {
            print("🟡 Trying to create RemoteConfig directly...")
            remoteConfig = RemoteConfig.remoteConfig()
            configureRemoteConfigOnce()
            setupNotificationsOnce()
            print("✅ RemoteConfig initialized successfully")
        } catch let error as NSError {
            print("❌ RemoteConfig initialization failed: \(error)")
            print("❌ Error domain: \(error.domain), code: \(error.code)")
            print("❌ Error description: \(error.localizedDescription)")
            
            // Firebase가 초기화되지 않은 경우의 에러 코드 확인
            if error.domain.contains("Firebase") {
                print("❌ This is a Firebase configuration error")
            }
        }
    }
    
    private func configureRemoteConfigOnce() {
        guard !isConfigured, let remoteConfig = remoteConfig else { return }
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1시간
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([:])
        
        isConfigured = true
        print("🟡 RemoteConfig configuration completed")
    }
    
    @objc private func appWillEnterForeground() {
        print("🟡 App will enter foreground - refreshing RemoteConfig")
        Task {
            await fetchRemoteConfig()
        }
    }
    
    // MARK: - Public Methods
    public func fetchRemoteConfig() async {
        print("🟡 fetchRemoteConfig() called")
        
        initializeRemoteConfigIfNeeded()
        guard let remoteConfig = remoteConfig else {
            print("❌ RemoteConfig not initialized - cannot fetch")
            return
        }
        
        do {
            print("🟡 Starting RemoteConfig fetch...")
            let status = try await remoteConfig.fetch()
            let activated = try await remoteConfig.activate()
            print("✅ RemoteConfig fetch completed - status: \(status)")
            
            await updateExperimentContext()
        } catch {
            print("❌ RemoteConfig fetch failed: \(error)")
            // 실패해도 현재 캐시된 값으로 experiment context 업데이트
            await updateExperimentContext()
        }
    }
    
    public func refreshRemoteConfig() {
        print("🟡 refreshRemoteConfig() called")
        Task {
            await fetchRemoteConfig()
        }
    }
    
    @MainActor
    private func updateExperimentContext() {
        _experimentContext = createExperimentContextString()
        print("🟡 Experiment context updated: \(_experimentContext)")
    }
    
    private func createExperimentContextString() -> String {
        guard let remoteConfig = remoteConfig else { return "" }
        
        let allKeys = remoteConfig.allKeys(from: .remote)
       
        var experiments: [String: String] = [:]
        
        // ABT 관련 키들만 필터링하여 수집
        for key in allKeys {
            if isABTestKey(key) {
                let configValue = remoteConfig.configValue(forKey: key)
                let variant = configValue.stringValue ?? ""
                if !variant.isEmpty {
                    experiments[key] = variant
                }
            }
        }
        
        guard !experiments.isEmpty else { return "" }
        
        return experiments
            .map { "\($0.key)=\($0.value)" }
            .sorted()
            .joined(separator: ",")
    }
    
    private func isABTestKey(_ key: String) -> Bool {
        return key.hasPrefix("abtest")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("🟡 RemoteConfigManager deinitialized")
    }
}
