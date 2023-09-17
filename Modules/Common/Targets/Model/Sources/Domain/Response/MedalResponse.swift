import Foundation

public struct MedalResponse: Decodable {
    public let medalId: Int?
    public let name: String
    public let iconUrl: String?
    public let disableIconUrl: String?
    public let introduction: String?
    public let acquisition: MedalAcquisitionResponse?
}

extension MedalResponse {
    public struct MedalAcquisitionResponse: Decodable {
        let description: String?
    }
}
