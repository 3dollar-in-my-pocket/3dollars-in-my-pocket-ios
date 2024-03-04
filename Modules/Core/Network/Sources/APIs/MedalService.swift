import Model

public protocol MedalServiceProtocol {
    func fetchMedals() async -> Result<[MedalResponse], Error>
}

public struct MedalService: MedalServiceProtocol {
    public init() { }

    public func fetchMedals() async -> Result<[MedalResponse], Error> {
        let request = FetchMedalsRequest()

        return await NetworkManager.shared.request(requestType: request)
    }
}
