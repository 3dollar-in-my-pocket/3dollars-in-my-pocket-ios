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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotificationsOnce() {
        guard !notificationSetup else { return }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        notificationSetup = true
    }
    
    private func initializeRemoteConfigIfNeeded() {
        guard remoteConfig == nil else { return }
        
        remoteConfig = RemoteConfig.remoteConfig()
        configureRemoteConfigOnce()
        setupNotificationsOnce()
    }
    
    private func configureRemoteConfigOnce() {
        guard !isConfigured, let remoteConfig = remoteConfig else { return }
        
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 60 // 1분
        #else
        settings.minimumFetchInterval = 3600 // 1시간
        #endif
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([:])
        
        isConfigured = true
    }
    
    @objc private func appWillEnterForeground() {
        Task {
            await fetchRemoteConfig()
        }
    }
    
    // MARK: - Public Methods
    public func fetchRemoteConfig() async {
        initializeRemoteConfigIfNeeded()
        guard let remoteConfig = remoteConfig else {
            return
        }
        
        do {
            let status = try await remoteConfig.fetch()
            _ = try await remoteConfig.activate()
            
            await updateExperimentContext()
        } catch {
            await updateExperimentContext()
        }
    }
    
    public func refreshRemoteConfig() {
        Task {
            await fetchRemoteConfig()
        }
    }
    
    @MainActor
    private func updateExperimentContext() {
        _experimentContext = createExperimentContextString()
    }
    
    private func createExperimentContextString() -> String {
        guard let remoteConfig = remoteConfig else { return "" }
        
        let allKeys = remoteConfig.allKeys(from: .remote)
       
        var experiments: [String: String] = [:]
        
        for key in allKeys {
            if isABTestKey(key) {
                let configValue = remoteConfig.configValue(forKey: key)
                let variant = configValue.stringValue
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
}
