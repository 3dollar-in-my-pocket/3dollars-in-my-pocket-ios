import Foundation

import AppInterface

final class MockRemoteConfigService: RemoteConfigProtocol {
    var experimentContext: String {
        return ""
    }

    func fetchRemoteConfig() async { }

    func refreshRemoteConfig() { }
}
