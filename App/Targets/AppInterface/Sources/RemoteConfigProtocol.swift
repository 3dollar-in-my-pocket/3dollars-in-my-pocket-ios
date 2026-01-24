public protocol RemoteConfigProtocol {
    var experimentContext: String { get }
    func fetchRemoteConfig() async
    func refreshRemoteConfig()
}
