import FirebaseRemoteConfig

protocol RemoteConfigProtocol {
    func fetchMinimalVersion() async throws -> String
}

struct RemoteConfigService: RemoteConfigProtocol {
    private let instance = RemoteConfig.remoteConfig()
    
    func fetchMinimalVersion() async throws -> String {
        let fetchStatus = try await instance.fetch(withExpirationDuration: 1800)
        
        switch fetchStatus {
        case .success:
            try await instance.activate()
            let minimumVersion = instance["minimum_version_ios"].stringValue ?? ""
            
            return minimumVersion
        default:
            throw BaseError.unknown
        }
        
    }
}
