import Foundation

import Networking

public final class EnviromentManager {
    public static let shared = EnviromentManager()
    
    public var networkConfiguration: NetworkConfiguration {
        didSet {
            NetworkManager.shared.configuration = networkConfiguration
        }
    }
    
    init() {
        self.networkConfiguration = .defaultConfig
    }
    
    public static func setEndPoint(_ url: String) {
        NetworkManager.shared.configuration.endPoint = url
    }
}
