import Foundation

public struct MedalResponse: Decodable {
    let medalId: Int
    let name: String
    let iconUrl: String
    let disableIconUrl: String
    let introduction: String
    let acquisition: MedalAcquisitionResponse
}

extension MedalResponse {
    public struct MedalAcquisitionResponse: Decodable {
        let description: String
    }
}
