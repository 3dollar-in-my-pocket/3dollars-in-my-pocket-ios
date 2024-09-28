import Model

public protocol MedalRepository {
    func fetchMedals() async -> Result<[MedalResponse], Error>
}

public struct MedalRepositoryImpl: MedalRepository {
    public init() { }

    public func fetchMedals() async -> Result<[MedalResponse], Error> {
        let request = MedalApi.fetchMedals

        return await NetworkManager.shared.request(requestType: request)
    }
}
