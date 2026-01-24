import FirebaseRemoteConfig
import FirebaseRemoteConfigInternal
import UIKit

public protocol RemoteConfigManagerProtocol {
    var experimentContext: String { get }
    func fetchRemoteConfig() async
    func refreshRemoteConfig()
}

public final class RemoteConfigManager: RemoteConfigManagerProtocol {
    static let shared = RemoteConfigManager()
    
    private let remoteConfig: RemoteConfig
    private var _experimentContext: String = ""
    
    // MARK: - Public Properties
    var experimentContext: String {
        return _experimentContext
    }
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        configureRemoteConfig()
        setupNotifications()
    }
    
    private func configureRemoteConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1시간
        remoteConfig.configSettings = settings
        
        // 기본값 설정
        remoteConfig.setDefaults([:])
    }
    
    private func setupNotifications() {
        // 앱 실행 시
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidFinishLaunching),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
        
        // BG → FG 전환 시
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidFinishLaunching() {
        Task {
            await fetchRemoteConfig()
        }
    }
    
    @objc private func appWillEnterForeground() {
        Task {
            await fetchRemoteConfig()
        }
    }
    
    // MARK: - Public Methods
    func fetchRemoteConfig() async {
        do {
            let status = try await remoteConfig.fetch()
            let activated = try await remoteConfig.activate()
            
            await updateExperimentContext()
        } catch {
            // 실패해도 현재 캐시된 값으로 experiment context 업데이트
            await updateExperimentContext()
        }
    }
    
    func refreshRemoteConfig() {
        Task {
            await fetchRemoteConfig()
        }
    }
    
    @MainActor
    private func updateExperimentContext() {
        _experimentContext = createExperimentContextString()
    }
    
    private func createExperimentContextString() -> String {
        let allKeys = remoteConfig.allKeys(from: .remote, namespace: .default)
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
        // ABT 키 식별 로직 (prefix 기반)
        return key.hasPrefix("abtest_") ||
               key.contains("experiment") ||
               key.contains("variant")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


